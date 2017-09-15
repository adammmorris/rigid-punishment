This repository contains all the code & data used in “The evolution of flexibility and rigidity in retaliatory punishment“, by Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman.

SIMULATIONS

The "Simulations" folder contains all the simulation code, and all the reported results. Before running anything else, run "paths.m" first; this sets the MATLAB path appropriately.

"Core" contains the main algorithms used in the simulations. "runMoran.m" simulates a Moran process, and "runMatch.m" simulates two RL agents playing the steal/punish game.

"Replicators" is where we simulate the evolutionary dynamics of the steal/punish game with an enlarged strategy space. "getPayoffs.m" returns the payoff matrix for any set of parameters, and "simulateReplicators" runs the simulations. The "results" folder has the reported results. Each filename specifies the selection intensity ("100" = 1 / 100, "1000" = 1 / 1000, etc) and mutation rate ("p05" = .05, etc). "Random" indicates that we randomly sampled the Moran parameters.

"Learners" is where we simulate two (unbiased) RL agents playing each other in the steal/punish game. "simulateLearners.m" runs the simulations, either with randomly sampled payoffs or systematically varying the cost of punishment. "random_payoffs.mat" stores the former result; "varying_cost.mat" stores the latter result (with either fixed or randomly varying Moran parameters).

"Embedded" is where we embed the RL agents in an evolutionary system and let them evolve hedonic biases for theft/punishment. "makeCache.m" runs the agent vs agent simulations, caches the payoff results, and stores the cache. "simulateEmbedded.m" runs the simulations, and the results are stored in the "Results" folder. The naming conventions are identical to those in "Replicators". "random_moran" indicates that we randomly sampled the Moran parameters; "random_RL" indicates that we randomly sampled the RL parameters; and "perceived" indicates that we manipulated the perceived, not actual, cost of punishment.

"Utilities" contains a bunch of background scripts used throughout the simulation code. See the scripts themselves for explanations.

BEHAVIORAL

The "Behavioral" folder contains all the data from the behavioral experiment, and the code to analyze it.

"data.csv" is the original data, with the following columns: "role" (1 if participant played as victim that match, 0 if thief), "orderCond" (0 if critical round was first, 1 if it was last) "oppType" (0 = always, 1 = flexible, 2 = never), "choice" (1 if the person chose to act [i.e. steal/punish], 0 if they chose to do nothing), "rt" is the reaction time, "score" is the  subject's running total, "globalRound" is the total # of rounds that the subject has done, "matchRound" is the total # of rounds played in this match, "oppChoice" is the opponent's choice, and "oppScore" is the opponent's score.

"analysis.R" runs the statistical analyses and creates the graph, and the .RData files are the result of "analysis.R".