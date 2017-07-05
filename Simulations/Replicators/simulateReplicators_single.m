%% simulateReplicators_single
% Simulates the stochastic evolution of a finite population of agents
% playing the steal/punish game, using the larger 5x5 strategy space (for
% each role, all 4 reactive strategies plus 1 learning strategy).
% Simulates a single population, rather than systematically varying theta.
% This is not actually used to produce any of the data or figures in the
% paper, but it's a useful testing tool.

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

% Set parameters
N = 10000;
mutation = .05;
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