require(lme4);
require(lmerTest);
require(dplyr);

df <- read.csv('data.csv')
df.inflex <- df %>% filter(opType == 0)

model = glmer(choice ~ role * matchRound + (1 + role * matchRound | subject), family = binomial, data = df.inflex);
model_null = glmer(choice ~ role + matchRound + (1 + role * matchRound | subject), family = binomial, data = df.inflex);
summary(model)
anova(model, model_null)