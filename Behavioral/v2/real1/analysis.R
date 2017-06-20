require(lme4)
require(lmerTest)
require(dplyr)
require(ggplot2)

# Load data, focus on persistent opponents
df <- read.csv('data.csv')

df.persist <- df %>% filter(oppPersistent == 1)
df.persist$rt <- log(df.persist$rt)
df.persist$rt <- df.persist$rt - mean(df.persist$rt)

df.persist = df.persist %>% mutate(paramCond = factor(ifelse(role == 0, stealCond, punCond)))

include_names = (df.persist %>% group_by(subject) %>% summarize(numObs = n()) %>% filter(numObs == 20))$subject

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

df.collapsed = df.persist %>% group_by(role, punCond, matchRound) %>% summarize(choice.se = sd(choice) / sqrt(length(choice)), choice = mean(choice))

pd <- position_dodge(0.1) # move them .05 to the left and right
ggplot(data = df.collapsed, aes(x = matchRound, y = choice, color = role, group = role)) +
  geom_line() +
  geom_errorbar(aes(ymin=choice - choice.se, ymax=choice + choice.se), width=.1, position = pd) +
  facet_wrap(~ punCond)

df.collapsed2 = df.persist %>% group_by(role, punCond, stealCond) %>% summarize(choice.se = sd(choice) / sqrt(length(choice)), choice = mean(choice))

pd <- position_dodge(0.1) # move them .05 to the left and right
ggplot(data = df.collapsed2, aes(x = punCond, y = choice, color = stealCond, group = stealCond)) +
  geom_line() +
  geom_errorbar(aes(ymin=choice - choice.se, ymax=choice + choice.se), width=.1, position = pd) +
  facet_wrap(~ role)

# Demo
pointsPerCent = 1
df.demo = read.csv('demo.csv')
df.demo = df.demo %>% mutate(total_time_actual = total_time / 60000, bonus = round(bonus / (pointsPerCent * 100), 2))
write.table(df.demo %>% select(WorkerID = subject, Bonus = bonus),
            'Bonuses - sp_v2_real1.csv', row.names = FALSE, col.names = FALSE, sep = ",")
# ANOVA

df.subj = df.persist %>% filter(subject %in% include_names) %>%
  mutate(matchRound_high = factor(matchRound > 3, c(T,F), c(1,0))) %>%
  group_by(subject, role, matchRound_high) %>% summarize(choice = mean(choice))

ezANOVA(data.frame(df.subj), choice, .(subject), .(matchRound_high), between = .(role))
