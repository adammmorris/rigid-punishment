%% simulateEmbedded_single
% Runs evolutionary simulation of the steal/punish game with embedded RL agents, using
% the cached outcomes from makeCache.m.
% Runs a single simulation for a specific cost of punishing, rather than
% systematically varying it.
% This is not actually used to produce any of the data or figures in the
% paper, but it's a useful testing tool.
% The indexing (i.e. what the legend shows) is the output of "getFullGene",
% for any strategy pair.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Load the cached matches
load('cache_c.mat');

%% Set parameters
% Simulation parameters
nAgents = 500;
invTemp = 1 / 1000;
nGenerations = 10000;
mutation = .05; % mutation rate

%% Run simulation
[~, ~, population] = runMoran(payoffs(:, :, :, :, 1), nAgents, nGenerations, invTemp, mutation);

%% Plot results
results = histc(population', 1:9)';
H = plot(results);
legend(H)