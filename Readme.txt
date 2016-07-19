This repository contains all the code & data used in "Persistent punishment and flexible theft", by Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman.

SIMULATIONS

The "Simulations" folder contains all the simulation code, and all the reported results. Before running anything else, run "paths.m" first; this sets the MATLAB path appropriately.

"Core" contains the main algorithms used in the simulations. "runMoran.m" simulates a Moran process, and "runMatch.m" simulates two RL agents playing the steal/punish game.

"Replicators" is where we simulate the evolutionary dynamics of the steal/punish game with an enlarged strategy space. "getPayoffs.m" returns the payoff matrix for any set of parameters, and "simulateReplicators" runs the simulations. "replicators.mat" has the reported results.

"Learners" is where we simulate two (unbiased) RL agents playing each other in the steal/punish game. "simulateLearners.m" runs the simulations (either with randomly sampled parameters or systematically varying the cost of punishment), and "learners_randparams.mat" and "learners_varyingcost.mat" store the results.

"Embedded" is where we embed the RL agents in an evolutionary system and let them evolve hedonic biases for theft/punishment. "makeCache.m" runs the agent vs agent simulations and caches the payoff results. "simulateEmbedded.m" runs the simulations, and the results are stored in "cache.mat". ("graphPayoffs.m" visualizes the cached payoffs, and “createEmbeddedFigure” visualizes the simulation output.)

"Utilities" contains a bunch of background scripts used throughout the simulation code. See the scripts themselves for explanations.

BEHAVIORAL

The "Behavioral" folder contains all the data from the behavioral experiment, and the code to analyze it.

"data.csv" is the original data, with the following columns: "roleVictim" (1 if participant played as victim that match, 0 if thief), "oppPersistent" (1 if opponent was persistent, 0 if not), "choiceAction" (1 if the person chose to act [i.e. steal/punish], 0 if they chose to do nothing), "rt" is the reaction time, "score" is the  subject's running total, "globalRound" is the total # of rounds that the subject has done, and "matchRound" is the total # of rounds played in this match.

"data.mat" is the data, imported into MATLAB. "makeGraph.m" creates the graph reported in the paper. "analysis.R" runs the statistical analysis. "analysis.RData" is the result of "analysis.R".

"game.fla" is the code used to run the actual game, and "game.swf" is the game itself.