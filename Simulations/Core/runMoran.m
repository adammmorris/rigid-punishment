%% runMoran
% Simulates a Moran process with selection and mutation.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Inputs
% payoffs: a four dimensional matrix specifying the game's payoff structure.
%   Dimensions should be: nStealGenomes x nPunishGenomes x 2 x nSamples.
%   First dimension is which steal genome, second is which punishment genome,
%   third is whether you want the thief payoff (1) or punisher
%   payoff (2), and fourth is which sample to use.
%   If there's only one cached match (i.e. if you want static payoffs),
%   just ignore payoff's 4th dimension.
% nAgents: number of agents in population
% nGenerations: number of generations to simulate
% invTemp: inverse temperature of reproduction softmax function
% mutation: mutation rate

%% Outputs
% distributionSteal (nGenerations x nStealGenes): number of each steal gene
%   in each generation
% distributionPunish (nGenerations x nPunishGenes): number of each punish
%   gene in each generation
% population_combined (nGenerations x nAgents): for each agent, gives that
% agent's (thief gene, punish gene) pair. (FS, AP) is indexed as "1", (AS,
% FP) as "2", and anything else as "3".

function [distributionSteal, distributionPunish, population_combined] = runMoran(payoffs, nAgents, nGenerations, invTemp, mutation)

nStealGenes = size(payoffs, 1);
nPunishGenes = size(payoffs, 2);
nCachedMatches = size(payoffs, 4);

%% Randomly initialize population
population = zeros(nGenerations, nAgents, 2); % 1st is steal gene; 2nd is punish gene
population_combined = zeros(nGenerations, nAgents);
IND_THIEF = 1; IND_PUN = 2;

distributionSteal = zeros(nGenerations, nStealGenes);
distributionPunish = zeros(nGenerations, nPunishGenes);

population(1, :, IND_THIEF) = randi(nStealGenes, nAgents, 1);
population(1, :, IND_PUN) = randi(nPunishGenes, nAgents, 1);
for i = 1:nAgents
    population_combined(1, i) = getFullGene(squeeze(population(1, i, :)), nStealGenes);
end

randBuffer = randi(nCachedMatches, nGenerations, nStealGenes, nPunishGenes);

otherAgents = true(nAgents, nAgents);
for thisAgent = 1:nAgents
    otherAgents(thisAgent, thisAgent) = false;
end

%% Loop through generations
for thisGeneration = 1:(nGenerations - 1)
    % Get the distribution of steal & punish genes
    distributionSteal(thisGeneration, :) = ...
        histc(population(thisGeneration, :, IND_THIEF), 1:nStealGenes);
    distributionPunish(thisGeneration, :) = ...
        histc(population(thisGeneration, :, IND_PUN), 1:nPunishGenes);
    
    % Determine fitness
    % Each agent plays as a thief against all other punishers,
    % and as a punisher against all other thieves.
    fitness_genes = zeros(nStealGenes, nPunishGenes, 2);
    
    for i = 1:nStealGenes
        for j = 1:nPunishGenes
            fitness_genes(i, j, :) = payoffs(i, j, :, randBuffer(thisGeneration, i, j));
        end
    end
    
    fitness_matrix = fitness_genes(population(thisGeneration, :, IND_THIEF), population(thisGeneration, :, IND_PUN), :);
    fitness = (sum(fitness_matrix(:, :, 1), 2) + sum(fitness_matrix(:, :, 2), 1)' ...
        - diag(fitness_matrix(:, :, 1)) - diag(fitness_matrix(:, :, 2))) / nAgents;
    
    % Randomly pick an agent to die
    agentDie = randi(nAgents);
    
    % Pick an agent to reproduce (based on fitness)
    agentRep = fastrandsample(getSoftmax(fitness, invTemp)', 1);
    
    % Update population
    population(thisGeneration + 1, :, :) = population(thisGeneration, :, :);
    population_combined(thisGeneration + 1, :) = population_combined(thisGeneration, :);
    % If there's a mutation, choose randomly. Otherwise, agent reproduces.
    if rand() < mutation
        newStealGene = randi(nStealGenes);
        newPunGene = randi(nPunishGenes);
        
        % Make sure the mutated gene is not identical to the original.
        while newStealGene == population(thisGeneration, agentRep, IND_THIEF) && ...
                newPunGene == population(thisGeneration, agentRep, IND_PUN)
            newStealGene = randi(nStealGenes);
            newPunGene = randi(nPunishGenes);
        end
        
        population(thisGeneration + 1, agentDie, IND_THIEF) = newStealGene;
        population(thisGeneration + 1, agentDie, IND_PUN) = newPunGene;
    else
        population(thisGeneration + 1, agentDie, :) = ...
            population(thisGeneration, agentRep, :);
    end
    
    population_combined(thisGeneration + 1, agentDie) = getFullGene(squeeze(population(thisGeneration + 1, agentDie, :)), nStealGenes);
end

%% Get ending distribution
distributionSteal(nGenerations, :) = ...
    histc(population(nGenerations, :, IND_THIEF), 1:nStealGenes);
distributionPunish(nGenerations, :) = ...
    histc(population(nGenerations, :, IND_PUN), 1:nPunishGenes);

end