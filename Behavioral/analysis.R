require(lme4);
require(lmerTest);
require(dplyr);

# Load data, focus on persistent opponents
df <- read.csv('data.csv')
df.persist <- df %>% filter(oppPersistent == 1)
df.persist$rt <- log(df.persist$rt)
df.persist$rt <- df.persist$rt - mean(df.persist$rt)

# Run mixed-effect model, compare to null
model = glmer(choiceAction ~ roleVictim * matchRound + (1 + roleVictim * matchRound | subject),
              family = binomial, data = df.persist);
model.null = glmer(choiceAction ~ roleVictim + matchRound + (1 + roleVictim * matchRound | subject),
              family = binomial, data = df.persist);
anova(model, model.null)

# Exclude any matches after they've faced a non-persistent opponents
df.control <- df %>% tbl_df %>% group_by(subject) %>%
  mutate(seenOtherAsThief = min(which(roleVictim == 0 & oppPersistent == 0)),
         seenOtherAsVictim = min(which(roleVictim == 1 & oppPersistent == 0))) %>%
  filter(oppPersistent == 1)
df.control.before <- df.control %>% filter(globalRound < min(seenOtherAsThief, seenOtherAsVictim))

# Rerun models
model.control.before <- glmer(choiceAction ~ roleVictim * matchRound + (1 + roleVictim * matchRound | subject),
                              family = binomial, data = df.control.before);
model.control.null <- glmer(choiceAction ~ roleVictim + matchRound + (1 + roleVictim * matchRound | subject),
                              family = binomial, data = df.control.before);
anova(model.control.before, model.control.null)

# Run model with RT interaction
# (This is not actually reported in the paper, but there is a significant interaction with RT)
model.rt = glmer(choiceAction ~ roleVictim * matchRound * rt + (1 + roleVictim * matchRound * rt | subject),
              family = binomial, data = df.persist);
model.rt.null = glmer(choiceAction ~ roleVictim * matchRound + roleVictim:rt + matchRound: rt + (1 + roleVictim * matchRound * rt | subject),
                   family = binomial, data = df.persist);
anova(model.rt, model.rt.null)