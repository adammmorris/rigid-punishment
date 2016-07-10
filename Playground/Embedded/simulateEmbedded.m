%% simulateEmbedded
% Runs evolutionary simulation of the steal/punish game with embedded RL agents, using
% the cached outcomes from makeCache.m.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set parameters
load('cache_lr.mat');

nAgents = 100;
nGenerations = 10000;
invTemp = 1 / 100;
mutation = .1;

%% Run simulation
[distT_c, distP_c, population_full_costly] = runMoran(payoffs_costly, nAgents, nGenerations, invTemp, mutation);
[distT_nc, distP_nc, population_full_notcostly] = runMoran(payoffs_notcostly, nAgents, nGenerations, invTemp, mutation);

%% Plot
figure
subplot(1,2,1)
plot(distT_nc)
legend('0', '.01', '.02', '.05', '.1', '.2', '.3');
subplot(1,2,2)
plot(distP_nc);
legend('0', '.01', '.02', '.05', '.1', '.2', '.3');

%% Plot
figure
subplot(1,2,1)
plot(histc(population_full_costly', 1:3)')
set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 40);
set(gca, 'YTick', [0 100], 'XTick', [0 10000]);
hl = legend('(Steal bias: 0, Punish bias: +)', '(Steal bias: +, Punish bias: 0)', 'Other', ...
    'location', 'best');
legend('boxoff');
hlt = text(...
    'Parent', hl.DecorationContainer, ...
    'String', 'Genotype', ...
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