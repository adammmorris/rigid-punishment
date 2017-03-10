%% makeCache
% Simulates all RL phenotypes playing each other many times and caches
% the outcomes. This cache is later used in the evolutionary
% simulation.
% Uses random parameters (must be loaded from 'learners_randparams' first).

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set params
nMatches = 100;

N = 10000; % # of rounds in game

lr = .2; % learning rate
gamma = .95; % discount rate
temp = 100; % inverse temperature for softmax function
agentMemory = 2; % memory in agent state space

% Hedonic biases for stealing/punishing, in this order:
% [FS/FP AS/APT NS/NP]
stealBias = [0 3 -2];
punishBias = [0 2 -11];

% Get the # of alleles for each gene component
nThiefGenes = length(stealBias);
nPunishGenes = length(punishBias);

% Systematically vary the subjective cost of punishing.
% 'c' will get multiplied by this value in the agent's reward function.
paramVals = linspace(.1, 2, 101);
nParamVals = length(paramVals);

%% Run sims
% Initialize payoff matrices
payoffs = zeros(length(stealBias), length(punishBias), 2, nMatches, nParamVals);

% Loop through all thief & victim genes
for thiefGene = 1:nThiefGenes
    for punishGene = 1:nPunishGenes
        for thisParamVal = 1:nParamVals
            % Set the subjective cost of punishment
            pctPunCost = paramVals(thisParamVal);
            
            % Get current phenotypes
            thiefPheno = stealBias(thiefGene);
            punPheno = punishBias(punishGene);

            % Run through all matches
            parfor thisMatch = 1:nMatches
                [~, ~, payoffs(thiefGene, punishGene, :, thisMatch, thisParamVal)] = ...
                    runMatch([N s(thisParamVal) sp(thisParamVal) c(thisParamVal) p(thisParamVal)], ...
                    [lr gamma temp thiefPheno punPheno pctPunCost agentMemory]);
            end
        end
    end
end

%% Save
save('cache.mat', 'payoffs', 'paramVals', 'nParamVals');