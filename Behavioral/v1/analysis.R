require(lme4)
require(lmerTest)
require(dplyr)
require(ggplot2)

# Load data, focus on persistent opponents
df <- read.csv('data.csv')

df.persist <- df %>% filter(oppPersistent == 1)
df.persist$rt <- log(df.persist$rt)
df.persist$rt <- df.persist$rt - mean(df.persist$rt)

include_names = (df.persist %>% group_by(subject) %>% summarize(numObs = n()) %>% filter(numObs == 15))$subject

# Run mixed-effect model, compare to null
model = glmer(choice ~ role * matchRound + (1 + matchRound | subject),
              family = binomial, data = df.persist);
model.null = glmer(choice ~ role + matchRound + (1 + matchRound | subject),
                   family = binomial, data = df.persist);
anova(model, model.null)

# Run model with RT interaction
# (This is not actually reported in the paper, but there is a significant interaction with RT)
model.rt = glmer(choiceAction ~ roleVictim * matchRound * rt + (1 + matchRound * rt | subject),
              family = binomial, data = df.persist);
model.rt.null = glmer(choiceAction ~ roleVictim * matchRound + roleVictim:rt + matchRound: rt + (1 + matchRound * rt | subject),
                   family = binomial, data = df.persist);
anova(model.rt, model.rt.null)

df.collapsed = df.persist %>% filter(punCostly == 0) %>% group_by(role, matchRound) %>% summarize(choice = mean(choice))
df.collapsed

ggplot(data = df.collapsed, aes(x = matchRound, y = choice, color = role, group = role)) +
  geom_line()

# Demo
pointsPerCent = 10
df.demo = read.csv('demo.csv')
df.demo = df.demo %>% mutate(total_time_actual = total_time / 60000, bonus = round(bonus / (pointsPerCent * 100), 2))
write.table(df.demo %>% select(WorkerID = subject, Bonus = bonus),
            'Bonuses - sp_v1_real1.csv', row.names = FALSE, col.names = FALSE, sep = ",")

# ANOVA

df.subj = df.persist %>% filter(subject %in% include_names) %>%
  mutate(matchRound_high = factor(matchRound > 3, c(T,F), c(1,0))) %>%
  group_by(subject, role, matchRound_high) %>% summarize(choice = mean(choice))

ezANOVA(data.frame(df.subj), choice, .(subject), .(matchRound_high), between = .(role))
