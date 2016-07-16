%% makeCache
% Simulates all RL phenotypes playing each other many times and caches
% the outcomes. This cache is later used in the evolutionary
% simulation.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set params
nMatches = 100;

N = 10000; % # of rounds in game
s = 2; % benefit of stealing
sp = 2; % cost of being stolen from
c = 1; % cost of punishing
p = 5; % cost of being punished

lr = .2; % learning rate
gamma = .95; % discount rate
temp = 100; % inverse temperature for softmax function
agentMemory = 2; % memory in agent state space

% Hedonic biases for stealing/punishing, in this order:
% [FS/FP AS/APT NS/NP]
stealBias = [0 4 -3];
punishBias = [0 2 -21];

nThiefGenes = length(stealBias);
nPunishGenes = length(punishBias);

%% Run sims
% Initialize payoff matrices
payoffs_costly = zeros(length(stealBias), length(punishBias), 2, nMatches);
payoffs_notcostly = zeros(length(stealBias), length(punishBias), 2, nMatches);

% Loop through all thief & victim genes
for thiefGene = 1:nThiefGenes
    for punishGene = 1:nPunishGenes
        earningsThief = zeros(nMatches, 1);
        earningsPun = zeros(nMatches, 1);
        
        % Get current phenotypes
        thiefPheno = stealBias(thiefGene);
        punPheno = punishBias(punishGene);
        
        % Run through all matches, once with punishment costly (pctPunCost
        % = 1) and not costly (pctPunCost = .2)
        parfor thisMatch = 1:nMatches
            [~, ~, payoffs_costly(thiefGene, punishGene, :, thisMatch)] = ...
                runMatch([N s sp c p], ...
                [lr gamma temp thiefPheno punPheno 1 agentMemory]);
            
            [~, ~, payoffs_notcostly(thiefGene, punishGene, :, thisMatch)] = ...
                runMatch([N s sp c p], ...
                [lr gamma temp thiefPheno punPheno .2 agentMemory]);
        end
    end
end

%% Save
save('cache_final.mat', 'payoffs_costly', 'payoffs_notcostly');