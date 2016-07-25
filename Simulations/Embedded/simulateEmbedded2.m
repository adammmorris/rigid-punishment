%% simulateReplicators
% Simulates the stochastic evolution of a finite population of agents
% playing the steal/punish game, using the larger 5x5 strategy space (for
% each role, all 4 reactive strategies plus 1 learning strategy).

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set parameters

load('cache_full2.mat');

% Simulation parameters
nAgents = 100; % # of agents in population
nGenerations = 10000; % # of generations to simulate
invTemp = 1 / 1000; % inverse temperature of softmax selection function
mutation = .15; % mutation rate

% Vary pctPunCost
paramVals = linspace(.1, 1, 10);
nParamVals = length(paramVals);
nSamplesPerVal = 10;

%% Run simulation

% Initialize recording arrays
outcomes = zeros(nParamVals, nSamplesPerVal);

IND_FAMILIAR = 1;
IND_PARADOXICAL = 2;
IND_OTHER = 3;

% For each value of theta..
for thisParamVal = 1:nParamVals
    pctPunCost = paramVals(thisParamVal);
    payoffs_cur = payoffs(:, :, :, :, thisParamVal);
    
    % Run all the samples
    parfor thisSample = 1:nSamplesPerVal
        [~, ~, population_full] = ...
            runMoran(payoffs_cur, nAgents, nGenerations, invTemp, mutation);
        
        % What % of the population must be a certain strategy to count the
        % simulation as having converged to that strategy?
        cutoff = 1 - mutation - .1;

        % Classify sample
        if mean(mean(population_full(1001:nGenerations, :) == IND_FAMILIAR)) > cutoff
            outcomes(thisParamVal, thisSample) = IND_FAMILIAR;
        elseif mean(mean(population_full(1001:nGenerations, :) == IND_PARADOXICAL)) > cutoff
            outcomes(thisParamVal, thisSample) = IND_PARADOXICAL;
        else
            outcomes(thisParamVal, thisSample) = 3;
        end
    end
end

%% Draw (part 1)
figure

H=bar([mean(outcomes == IND_FAMILIAR, 2), mean(outcomes == IND_PARADOXICAL, 2), mean(outcomes == 3 | outcomes == 4 | outcomes == 5 | outcomes == 6, 2)], 'stacked');
set(H(1),'facecolor',[0 180 185] / 255);
set(H(2),'facecolor',[255 140 0] / 255);
set(H(3),'facecolor',[0 0 0] / 255);
set(H, 'edgecolor', [0 0 0]);
xlim([0 nParamVals + 1]);
ylim([0 1]);
hl = legend('Flexibly steal / Always punish theft', 'Always steal / Flexibly punish theft', 'Other', ...
    'location', 'northoutside');
legend('boxoff');

%% Draw (part 2)
hlt = text(...
    'Parent', hl.DecorationContainer, ...
    'String', 'Equilibrium', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'Position', [0.5, 1.05, 0], ...
    'Units', 'normalized', ...
    'FontSize', 40, ...
    'FontWeight', 'bold');
set(gca, 'XTickLabel', {'0', '', '', '', '', '', '', '', '', '', '1'}, 'YTick', [0 1], 'YTickLabel', [0 1]);
xlabel('Cost of punishment');
ylabel('Probability of equilibrium');
set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 40);