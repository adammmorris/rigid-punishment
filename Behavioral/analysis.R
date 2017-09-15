## PRELIMINARIES
# You should set the working directory to the current folder

require(lme4)
require(lmerTest)
require(dplyr)
require(ggplot2)
require(ez)

theme_adam = function() {
  theme_classic() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
             axis.text=element_text(size=22, colour = "black"), axis.title=element_text(size=24, face = "bold"), axis.title.x = element_text(vjust = 0),
             legend.title = element_text(size = 24, face = "bold"), legend.text = element_text(size = 20), plot.title = element_text(size = 26, face = "bold", vjust = 1),
             plot.margin = unit(c(3,3,3,3), "lines"))
}

se = function(x) {return(sd(x)/sqrt(length(x)))}
dodge <- position_dodge(width=0)

## ANALYSIS

fixed_payoffs = T

# Load data, focus on persistent opponents
df <- read.csv(ifelse(fixed_payoffs, 'fixed_payoffs.csv', 'random_payoffs.csv')) %>%
  mutate(role = factor(role, c(1, 0), c('Victim', 'Thief')))

if (fixed_payoffs) {
  df = df %>% filter(!(subject == 'A21ZMR7O42OSMI' & role == 'Victim' & oppType == 2))
}

df.persist <- df %>% filter(oppType == 2)

# Run mixed-effect model (with order), compare to null.
# In all analyses, we switch to the 'bobyqa' optimizer when the default does not converge
model = glmer(choice ~ role * matchRound * orderCond + (1 + matchRound | subject),
              family = binomial, data = df.persist, control = glmerControl(optimizer='bobyqa'));
model.null = glmer(choice ~ role + matchRound * orderCond + role:matchRound:orderCond + role:orderCond + (1 + matchRound | subject),
                   family = binomial, data = df.persist, control = glmerControl(optimizer='bobyqa'));
anova(model, model.null)

# Run mixed-effect model (without order), compare to null
model2 = glmer(choice ~ role * matchRound + (1 + matchRound | subject),
              family = binomial, data = df.persist);
model2.null = glmer(choice ~ role + matchRound + (1 + matchRound | subject),
                   family = binomial, data = df.persist);
anova(model2, model2.null)

# get effect size
df.simple = df.persist %>% filter(matchRound %in% c(0, 19)) %>%
  mutate(matchRound = factor(matchRound, c(0,19), c('First', 'Last'))) %>%
  select(subject, choice, role, matchRound) %>% arrange(subject)
anova.results = ezANOVA(df.simple, choice, subject, matchRound, between = .(role))
anova.results
ci.pvaf(anova.results$ANOVA$F[3], anova.results$ANOVA$DFn[3], anova.results$ANOVA$DFd[3], nrow(df.simple) / 2, .95)

# Plot
df.collapsed = df.persist %>%
  mutate(choice = choice * 100) %>%
  group_by(role, matchRound) %>%
  summarize(choice.m = mean(choice), choice.se = se(choice))
df.collapsed

ggplot(data = df.collapsed, aes(x = matchRound, y = choice.m, color = role, group = role, linetype = role)) +
  geom_line() +
  geom_errorbar(aes(ymax = choice.m + choice.se, ymin = choice.m - choice.se), width = .5, position = dodge) +
  theme_adam() + xlab('Round') + ylab('% Stealing or\npunishing') +
  scale_x_continuous(limits = c(-1,20), breaks = c(0,9,19), labels = c(1, 10, 20)) + scale_y_continuous(limits = c(0,100), breaks = c(0,50,100)) +
  theme(legend.title=element_blank(), legend.position = c(1,1), legend.justification = c(.9,.9)) +
  scale_colour_manual(values = c("Thief" = "Red", "Victim" = "Blue"))
ggsave('test.eps', width = 4.5, height = 4.5, units = "in")

## FOR RANDOM_PAYOFFS VERSION
if (!fixed_payoffs) {
  # Check whether people are sensitive to varying payoffs
  # For victim, only analyzing against persistent opponents (because this is the main opportunity to punish)
  
  model.thief.s = glmer(choice ~ s + (1 | subject),
                family = binomial, data = df %>% filter(role == 'Thief'));
  model.thief.c = glmer(choice ~ c + (1 | subject),
                        family = binomial, data = df %>% filter(role == 'Thief'));
  model.thief.p = glmer(choice ~ p + (1 | subject),
                        family = binomial, data = df %>% filter(role == 'Thief'));
  model.thief.null = glmer(choice ~ 1 + (1 | subject),
                           family = binomial, data = df %>% filter(role == 'Thief'));
  anova(model.thief.s, model.thief.null)
  anova(model.thief.c, model.thief.null)
  anova(model.thief.p, model.thief.null)
  
  # get thief effect sizes
  df.simple.thief = df %>% filter(role == 'Thief') %>% group_by(subject) %>%
    summarize(choice = mean(choice), s= mean(s), c= mean(c), p = mean(p))
  anova.thief.s.results = ezANOVA(data.frame(df.simple.thief), choice, subject, between = s) # es = .02
  ci.pvaf(anova.thief.s.results$ANOVA$F, anova.thief.s.results$ANOVA$DFn, anova.thief.s.results$ANOVA$DFd, nrow(df.simple.thief), .95)
  ezANOVA(data.frame(df.simple.thief), choice, subject, between = c) # es = .01
  ezANOVA(data.frame(df.simple.thief), choice, subject, between = p) # es = .01
  
  # had to switch optimizers for convergence
  model.victim.c = glmer(choice ~ c + (1 | subject),
                      family = binomial, data = df %>% filter(role == 'Victim' & oppType == 2),
                      control = glmerControl(optimizer='bobyqa'));
  model.victim.s = glmer(choice ~ s + (1 | subject),
                         family = binomial, data = df %>% filter(role == 'Victim' & oppType == 2),
                         control = glmerControl(optimizer='bobyqa'));
  model.victim.p = glmer(choice ~ p + (1 | subject),
                         family = binomial, data = df %>% filter(role == 'Victim' & oppType == 2),
                         control = glmerControl(optimizer='bobyqa'));
  model.victim.null = glmer(choice ~ 1 + (1 | subject),
                       family = binomial, data = df %>% filter(role == 'Victim' & oppType == 2),
                       control = glmerControl(optimizer='bobyqa'));
  anova(model.victim.c, model.victim.null)
  anova(model.victim.s, model.victim.null)
  anova(model.victim.p, model.victim.null)
  
  
  # get victim effect sizes
  df.simple.victim = df %>% filter(role == 'Victim') %>% group_by(subject) %>%
    summarize(choice = mean(choice), s= mean(s), c= mean(c), p = mean(p))
  ezANOVA(data.frame(df.simple.victim), choice, subject, between = s) # es = .001
  anova.victim.c.results = ezANOVA(data.frame(df.simple.victim), choice, subject, between = c) # es = .01
  ci.pvaf(anova.victim.c.results$ANOVA$F, anova.victim.c.results$ANOVA$DFn, anova.victim.c.results$ANOVA$DFd, nrow(df.simple.victim), .95)
  anova.victim.p.results = ezANOVA(data.frame(df.simple.victim), choice, subject, between = p) # es = .03
  ci.pvaf(anova.victim.p.results$ANOVA$F, anova.victim.p.results$ANOVA$DFn, anova.victim.p.results$ANOVA$DFd, nrow(df.simple.victim), .95)
}