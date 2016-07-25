%% simulateEmbedded
% Runs evolutionary simulation of the steal/punish game with embedded RL agents, using
% the cached outcomes from makeCache.m.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Load the cached matches
load('cache.mat');

%% Set parameters
nAgents = 100; % # of agents in population
nGenerations = 10000; % # of generations to simulate
invTemp = 1 / 1000; % inverse temperature of softmax selection function
mutation = .2; % mutation rate

%% Run simulation
[~, ~, population_full_costly] = runMoran(payoffs_costly, nAgents, nGenerations, invTemp, mutation);
[~, ~, population_full_notcostly] = runMoran(payoffs_notcostly, nAgents, nGenerations, invTemp, mutation);

%% Plot results
createEmbeddedFigure(histc(population_full_costly', 1:3)', histc(population_full_notcostly', 1:3)')