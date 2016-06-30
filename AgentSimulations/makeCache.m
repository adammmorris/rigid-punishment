%% makeCache
% Simulates all agent phenotypes playing each other many times and caches
% all the outcomes. This cache is later used in the evolutionary
% simulation.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set params for costly
nMatches = 25;

N = 10000;
s = 2;
sp = 2;
c = 1;
p = 5;

lr = .2;
gamma = .95;
temp = 10;
pctCostly = .2;

stealBias = [0 4 -3]; % if steal & get punished, +1
punishBias = [0 2 -41]; % if punishment is costly, then we need >1 but <3. If punishment is not costly, then we need >pctCostly but < 2+pctCostly

nThiefGenes = length(stealBias);
nPunishGenes = length(punishBias);

%% Play costly!
payoffs_costly = zeros(length(stealBias), length(punishBias), 2, nMatches);

for thiefGene = 1:nThiefGenes
    for punishGene = 1:nPunishGenes
        
        earningsThief = zeros(nMatches, 1);
        earningsPun = zeros(nMatches, 1);
        
        thiefPheno = stealBias(thiefGene);
        punPheno = punishBias(punishGene);
        
        parfor thisMatch = 1:nMatches
            [~, ~, earningsThief(thisMatch), earningsPun(thisMatch)] = ...
                runMatch([N s sp c p], ...
                [lr gamma temp thiefPheno punPheno pctCostly], true);
        end
        
        payoffs_costly(thiefGene, punishGene, 1, :) = earningsThief;        
        payoffs_costly(thiefGene, punishGene, 2, :) = earningsPun';
    end
end

%% Do not costly
payoffs_notcostly = zeros(length(stealBias), length(punishBias), 2, nMatches);

for thiefGene = 1:nThiefGenes
    for punishGene = 1:nPunishGenes
        
        earningsThief = zeros(nMatches, 1);
        earningsPun = zeros(nMatches, 1);
        
        thiefPheno = stealBias(thiefGene);
        punPheno = punishBias(punishGene);
        
        parfor thisMatch = 1:nMatches
            [~, ~, earningsThief(thisMatch), earningsPun(thisMatch)] = ...
                runMatch([N s sp c p], ...
                [lr gamma temp thiefPheno punPheno pctCostly], false);
        end
        
        payoffs_notcostly(thiefGene, punishGene, 1, :) = earningsThief;        
        payoffs_notcostly(thiefGene, punishGene, 2, :) = earningsPun';
    end
end

%% Save
save('cache.mat', 'payoffs_costly', 'payoffs_notcostly');