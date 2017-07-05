require(lme4)
require(lmerTest)
require(dplyr)
require(ggplot2)

theme_mprl <- function () { 
  theme_minimal() +
    theme(plot.title = element_text(vjust=3.5, size=18),
          axis.title.x = element_text(vjust=-2.5, size=16, face="bold"), 
          axis.title.y = element_text(vjust=3.5, size=16, face="bold"),
          axis.text = element_text(size = rel(1)),
          axis.line = element_line(),
          legend.text = element_text(size = 14),
          plot.margin = unit(c(3,3,3,3), "lines"),
          panel.grid.major = element_blank(), panel.grid.minor = element_blank())
}

theme_adam = function() {
  theme_classic() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
             axis.text=element_text(size=22, colour = "black"), axis.title=element_text(size=24, face = "bold"), axis.title.x = element_text(vjust = 0),
             legend.title = element_text(size = 24, face = "bold"), legend.text = element_text(size = 20), plot.title = element_text(size = 26, face = "bold", vjust = 1),
             plot.margin = unit(c(3,3,3,3), "lines"))
}


se = function(x) {return(sd(x)/sqrt(length(x)))}
dodge <- position_dodge(width=0)

lm.beta.lmer <- function(mod) {
  b <- fixef(mod)[-1]
  sd.x <- apply(getME(mod,"X")[,-1],2,sd)
  sd.y <- sd(getME(mod,"y"))
  b*sd.x/sd.y
}

# Load data, focus on persistent opponents
df <- read.csv('data.csv') %>%
  mutate(role = factor(role, c(1, 0), c('Victim', 'Thief')))
df.persist <- df %>% filter(oppType == 2) 

#include_names = (df.persist %>% group_by(subject) %>% summarize(numObs = n()) %>% filter(numObs == 20))$subject

# Run mixed-effect model, compare to null
model = glmer(choice ~ role * matchRound * orderCond + (1 + matchRound | subject),
              family = binomial, data = df.persist);
model.null = glmer(choice ~ role + matchRound * orderCond + role:matchRound:orderCond + role:orderCond + (1 + matchRound | subject),
                   family = binomial, data = df.persist);
anova(model, model.null)

# Test for order
model.order.null = glmer(choice ~ role * orderCond + matchRound * orderCond + role * matchRound + (1 + matchRound | subject),
                   family = binomial, data = df.persist);
anova(model, model.order.null)

df.collapsed = df.persist %>%
  mutate(choice = choice * 100) %>%
  group_by(role, matchRound) %>%
  summarize(choice.m = mean(choice), choice.se = se(choice))
df.collapsed

ggplot(data = df.collapsed, aes(x = matchRound, y = choice.m, color = role, group = role, linetype = role)) +
  geom_line() +
  geom_errorbar(aes(ymax = choice.m + choice.se, ymin = choice.m - choice.se), width = .5, position = dodge) +
  theme_adam() + xlab('Round') + ylab('% Stealing / punishing') +
  scale_x_continuous(limits = c(-1,20), breaks = c(0,9,19), labels = c(1, 10, 20)) + scale_y_continuous(limits = c(0,100), breaks = c(0,50,100)) +
  theme(legend.title=element_blank(), legend.position = c(1,1), legend.justification = c(.9,.9)) +
  scale_colour_manual(values = c("Thief" = "Red", "Victim" = "Blue")) +
  ggsave(file='test.eps')

# Different costs
df.costs = df %>% mutate(param = ifelse(role == 'Victim', c, s))
df.subj = df.costs %>% filter() %>%
  mutate(param = ifelse(role == 'Victim', c, s), choice = choice * 100) %>%
  group_by(subject, role) %>%
  summarize(choice.m = mean(choice), choice.se = se(choice), c = mean(c), s = mean(s))

ggplot(data = df.subj, aes(x = param, y = choice.m, color = role, group = role)) +
  geom_point() +
  theme_adam() + geom_smooth(method='lm',formula=y~x)

model.param = glmer(choice ~ role * param + (1 | subject),
              family = binomial, data = df.costs);
model.param.null = glmer(choice ~ role + param + (1 | subject),
              family = binomial, data = df.costs);
anova(model.param, model.param.null)

model.thief = glmer(choice ~ c + (1 | subject),
              family = binomial, data = df.costs %>% filter(role == 'Thief'));
model.thief.null = glmer(choice ~ 1 + (1 | subject),
                    family = binomial, data = df.costs %>% filter(role == 'Thief'));
anova(model.thief, model.thief.null)

# had to switch optimizers for convergence
model.victim = glmer(choice ~ p + (1 | subject),
                    family = binomial, data = df.costs %>% filter(role == 'Victim' & oppType == 2),
                    control = glmerControl(optimizer='bobyqa'));
model.victim.null = glmer(choice ~ 1 + (1 | subject),
                     family = binomial, data = df.costs %>% filter(role == 'Victim' & oppType == 2),
                     control = glmerControl(optimizer='bobyqa'));
anova(model.victim, model.victim.null)

# Demo
pointsPerCent = 1
df.demo = read.csv('demo.csv')
df.demo = df.demo %>% mutate(total_time_actual = total_time / 60000, bonus = round(bonus / (pointsPerCent * 100), 2))
write.table(df.demo %>% select(WorkerID = subject, Bonus = bonus),
            'Bonuses - sp_rp.csv', row.names = FALSE, col.names = FALSE, sep = ",")

# ANOVA

df.subj = df.persist %>% filter(subject %in% include_names) %>%
  mutate(matchRound_high = factor(matchRound > 3, c(T,F), c(1,0))) %>%
  group_by(subject, role, matchRound_high) %>% summarize(choice = mean(choice))

ezANOVA(data.frame(df.subj), choice, .(subject), .(matchRound_high), between = .(role))
