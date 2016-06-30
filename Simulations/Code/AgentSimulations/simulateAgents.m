%% runSimulation
% Runs agent-based evolutionary simulation of the steal-punish game using
% the cached outcomes from makeCache.m

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set parameters
load('cache.mat');

nAgents = 100;
nGenerations = 10000;
invTemp = 1 / 100;
mutation = .1;

%% Run simulation
[distSteal_costly, distPun_costly, population_full_costly] = runMoran(payoffs_costly, nAgents, nGenerations, invTemp, mutation);
[distSteal_notcostly, distPun_notcostly, population_full_notcostly] = runMoran(payoffs_notcostly, nAgents, nGenerations, invTemp, mutation);

%% Plot
figure
subplot(1,2,1)
plot(histc(population_full_costly', 1:3)')
legend('Always punish theft / Learn to stop stealing', ...
    'Always steal / Learn to stop punishing', ...
    'Other');
set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 40);
set(gca, 'YTick', [0 100], 'XTick', [0 10000]);
hl = legend('Always punish theft / learn to stop stealing', 'Always steal / learn to stop punishing', 'Other', ...
    'location', 'best');
legend('boxoff');
hlt = text(...
    'Parent', hl.DecorationContainer, ...
    'String', 'Strategy', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'Position', [0.5, 1.05, 0], ...
    'Units', 'normalized', ...
    'FontSize', 40, ...
    'FontWeight', 'bold');
xlabel('Generation');
ylabel('% of population');
subplot(1,2,2)
plot(histc(population_full_notcostly', 1:3)')
set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 40);
set(gca, 'YTick', [0 100], 'XTick', [0 10000]);
xlabel('Generation');