%% makeCache
% Simulates all RL phenotypes playing each other many times and caches
% the outcomes. This cache is later used in the evolutionary
% simulation.
% Systematically varies the subjective cost of punishment.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set params
nMatches = 100;
N = 5000; % # of rounds in each match

s = 5; % .1 to 20
sp = 5; % for simplicity, fix the cost of being stolen from (sp) at s
c = 5; % .1 to 20
p = 15; % s to s + 30

pctPunCost = 1; % % of punishment's cost to be included in reward function (used to manipulate "perceived cost")

manipulate_perceived_cost = true;

if manipulate_perceived_cost
    % Systematically vary the subjective cost of punishing.
    % 'c' will get multiplied by this value in the agent's reward function.
    paramVals = linspace(.1, 2, 100);
else
    % Systematically vary the objective cost of punishing.
    paramVals = linspace(.1, 10, 100);
end
nParamVals = length(paramVals);

% Use either fixed, or random, RL parameters
lr = .2; % learning rate
%lr = .05 + rand(nParamVals, nMatches) * .2;
gamma = .95; % discount rate%temp = 20;
temp = 20; % inverse temperature of softmax policy function
%temp = 10 + rand(nParamVals, nMatches) * (100 - 10); 

agentMemory = 2; % memory in agent state space

% Hedonic biases for stealing/punishing, in this order:
% [FS/FP AS/APT NS/NP]
stealBias = [0 11 -6];
punishBias = [0 11 -52];

% Get the # of alleles for each gene component
nThiefGenes = length(stealBias);
nPunishGenes = length(punishBias);

%% Run sims
% Initialize payoff matrices
payoffs = zeros(length(stealBias), length(punishBias), 2, nMatches, nParamVals);

% Loop through all thief & victim genes
for thiefGene = 1:nThiefGenes
    for punishGene = 1:nPunishGenes
        for thisParamVal = 1:nParamVals
            % Set the cost of punishment
            if manipulate_perceived_cost
                pctPunCost = paramVals(thisParamVal);
            else
                c = paramVals(thisParamVal);
            end
            
            
            % Get current phenotypes
            thiefPheno = stealBias(thiefGene);
            punPheno = punishBias(punishGene);

            % Run through all matches
            for thisMatch = 1:nMatches
                [~, ~, payoffs(thiefGene, punishGene, :, thisMatch, thisParamVal)] = ...
                    runMatch([N s s c p], ...
                    [lr gamma temp thiefPheno punPheno pctPunCost agentMemory]);
            end
        end
    end
end

%% Save
save('cache.mat', 'payoffs', 'paramVals', 'nParamVals');