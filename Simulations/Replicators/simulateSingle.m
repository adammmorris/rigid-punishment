%% simulateEmbedded
% Runs evolutionary simulation of the steal/punish game with embedded RL agents, using
% the cached outcomes from makeCache.m.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set parameters% Simulation parameters
nAgents = 100;
nGenerations = 10000;
invTemp = 1 / 1000;

% Vary theta
thetaVals = linspace(0, 1, 101);
nThetaVals = length(thetaVals);
nSamplesPerVal = 100;

% Randomly sample other parameters
N = 10000;
mutation = .1;
s = 1;
sp = 1;
c = 1;
p = 3;
theta = 0;

%% Run simulation
[~, ~, population] = runMoran(getPayoffs(N, s, sp, c, p, theta), nAgents, nGenerations, invTemp, mutation);

%% Plot results
results = histc(population', 1:25)';
H = plot(results);
legend(H)