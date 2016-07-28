%% simulateEmbedded
% Runs evolutionary simulation of the steal/punish game with embedded RL agents, using
% the cached outcomes from makeCache.m.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Load the cached matches
load('cache_full2.mat');

%% Set parameters
nAgents = 100; % # of agents in population
nGenerations = 10000; % # of generations to simulate
invTemp = 1 / 1000; % inverse temperature of softmax selection function
mutation = .15; % mutation rate

%% Run simulation
%[~, ~, population_full_costly] = runMoran(payoffs_costly, nAgents, nGenerations, invTemp, mutation);
%[~, ~, population_full_notcostly] = runMoran(payoffs_notcostly, nAgents, nGenerations, invTemp, mutation);
[~, ~, population] = runMoran(payoffs(:, :, :, :, 100), nAgents, nGenerations, invTemp, mutation);

%% Plot results
plot(histc(population', 1:9)')