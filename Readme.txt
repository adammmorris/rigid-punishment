This repository contains all the code & data used in "Persistent punishment and flexible theft", by Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman.

SIMULATIONS

The "Simulations" folder contains all the simulation code, and all the reported results. Before running anything else, run "paths.m" first; this sets the MATLAB path appropriately.

"Core" contains the main algorithms used in the simulations. "runMoran.m" simulates a Moran process, and "runMatch.m" simulates two RL agents playing the steal/punish game.

"Replicators" is where we simulate the evolutionary dynamics of the steal/punish game with an enlarged strategy space. "getPayoffs.m" returns the payoff matrix for any set of parameters, and "simulateReplicators" runs the simulations. "replicators.mat" has the reported results.

"Learners" is where we simulate two (unbiased) RL agents playing each other in the steal/punish game. "simulateLearners.m" runs the simulations (either with randomly sampled parameters or systematically varying the cost of punishment), and "learners_randparams.mat" and "learners_varyingcost.mat" store the results.

"Embedded" is where we embed the RL agents in an evolutionary system and let them evolve hedonic biases for theft/punishment. "makeCache.m" runs the agent vs agent simulations and caches the payoff results. "simulateEmbedded.m" runs the simulations, and the results are stored in "cache.mat". ("graphPayoffs.m" visualizes the cached payoffs, if you want to see what they look like.)

"Utilities" contains a bunch of background scripts used throughout the simulation code. See the scripts themselves for explanations.

BEHAVIORAL

The "Behavioral" folder contains all the data from the behavioral experiment, and the code to analyze it.

"data.csv" is the original data, with the following columns: "role" (0 is thief, 1 is victim), "opType" (0 is persistent, 1 is flexible), "choice" (0 is do nothing, 1 is steal), "payoffSubj1" / "payoffSubj2" are the payoffs to the subject after the thief's/victim's turn, "payoffOpp1" / "payoffOpp2" are the payoffs to the opponent, "rt" is the reaction time, "score" is the  subject's running total, "globalRound" is the total # of rounds that the subject has done, and "matchRound" is the total # of rounds played in this match.

"data.mat" is the data, imported into MATLAB. "makeGraph.m" creates the graph reported in the paper. "analysis.R" runs the statistical analysis.

"game.fla" is the code used to run the actual game, and "game.swf" is the game itself.