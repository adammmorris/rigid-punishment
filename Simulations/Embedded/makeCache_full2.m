%% makeCache
% Simulates all RL phenotypes playing each other many times and caches
% the outcomes. This cache is later used in the evolutionary
% simulation.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set params
nMatches = 20;

N = 10000; % # of rounds in game
s = 1; % benefit of stealing
sp = 1; % cost of being stolen from
c = 2; % cost of punishing
p = 3; % cost of being punished

lr = .2; % learning rate
gamma = .95; % discount rate
temp = 100; % inverse temperature for softmax function
agentMemory = 2; % memory in agent state space

% Hedonic biases for stealing/punishing, in this order:
% [FS/FP AS/APT NS/NP]
stealBias = [0 3 -2];
punishBias = [0 2 -11];

nThiefGenes = length(stealBias);
nPunishGenes = length(punishBias);

paramVals = linspace(.1, 1, 10);
nParamVals = length(paramVals);

%% Run sims
% Initialize payoff matrices
payoffs = zeros(length(stealBias), length(punishBias), 2, nMatches, nParamVals);

% Loop through all thief & victim genes
for thiefGene = 1:nThiefGenes
    for punishGene = 1:nPunishGenes
        for thisParamVal = 1:nParamVals
            pctPunCost = paramVals(thisParamVal);
            
            earningsThief = zeros(nMatches, 1);
            earningsPun = zeros(nMatches, 1);

            % Get current phenotypes
            thiefPheno = stealBias(thiefGene);
            punPheno = punishBias(punishGene);

            % Run through all matches, once with punishment costly (pctPunCost
            % = 1) and not costly (pctPunCost = .2)
            parfor thisMatch = 1:nMatches
                [~, ~, payoffs(thiefGene, punishGene, :, thisMatch, thisParamVal)] = ...
                    runMatch([N s sp c p], ...
                    [lr gamma temp thiefPheno punPheno pctPunCost agentMemory]);
            end
        end
    end
end

%% Save
save('cache_full.mat', 'payoffs', 'paramVals', 'nParamVals');