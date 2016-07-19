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
mutation = .15; % mutation rate

%% Run simulation
[~, ~, population_full_costly] = runMoran(payoffs_costly, nAgents, nGenerations, invTemp, mutation);
[~, ~, population_full_notcostly] = runMoran(payoffs_notcostly, nAgents, nGenerations, invTemp, mutation);

%% Plot results
figure
subplot(1,2,1)
plot(histc(population_full_costly', 1:3)')
set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 40);
set(gca, 'YTick', [0 100], 'XTick', [0 10000]);
hl = legend('(Steal bias: 0, Punish bias: +)', '(Steal bias: +, Punish bias: 0)', 'Other', ...
    'location', 'best');
legend('boxoff');
xlabel('Generation');
ylabel('% of population');
subplot(1,2,2)
plot(histc(population_full_notcostly', 1:3)')
set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 40);
set(gca, 'YTick', '', 'XTick', [0 10000]);
xlabel('Generation');
hlt = text(...
    'Parent', hl.DecorationContainer, ...
    'String', 'Genotype', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'Position', [0.5, 1.05, 0], ...
    'Units', 'normalized', ...
    'FontSize', 40, ...
    'FontWeight', 'bold');