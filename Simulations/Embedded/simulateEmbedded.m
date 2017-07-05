%% simulateEmbedded
% Runs evolutionary simulation of the steal/punish game with embedded RL agents, using
% the cached outcomes from makeCache.m.
% Systematically varies the cost of punishing, holding other parameters
% constant.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set parameters

load('cache.mat');

nSamplesPerVal = 100; % # of simulations to run per value of c
nAgents = 100;
nGenerations = 10000;

% Set either fixed, or random, selection intensity / mutation rate
w = repmat(1 / 1000, nParamVals, nSamplesPerVal);
%w = 1 / 10000 + rand(nParamVals, nSamplesPerVal) * (1 / 100 - 1 / 10000);
mu = repmat(.05, nParamVals, nSamplesPerVal);
%mu = .01 + rand(nParamVals, nSamplesPerVal)*.65;

%% Run simulation

% Initialize recording arrays
stealBias = zeros(nParamVals, nSamplesPerVal);
punishBias = zeros(nParamVals, nSamplesPerVal);

% For each value of theta..
parfor thisParamVal = 1:nParamVals
    pctPunCost = paramVals(thisParamVal);
    payoffs_cur = payoffs(:, :, :, :, thisParamVal);
    
    % Run all the samples
    for thisSample = 1:nSamplesPerVal
        [distSteal, distPun, population_full] = ...
            runMoran(payoffs_cur, nAgents, nGenerations, ...
            w(thisParamVal, thisSample), mu(thisParamVal, thisSample));
        
        % What % of the population must be a certain strategy to count the
        % simulation as having converged to that strategy?
        cutoff = 1 - mu(thisParamVal, thisSample) - .1;

        % Classify sample
        [thiefGene, victimGene] = getGeneComposite(population_full(1001:nGenerations, :), 3); % 1 = flexible, 2 = always, 3 = never
        if mean(mean(thiefGene == 2)) > cutoff
            stealBias(thisParamVal, thisSample) = 1;
        end
        
        if mean(mean(victimGene == 2)) > cutoff
            punishBias(thisParamVal, thisSample) = 1;
        end
    end
end

%% Plot

plot(paramVals, mean(punishBias, 2), paramVals, mean(stealBias, 2), '--', 'LineWidth', 4)
set(gca, 'XTick', [0 10], 'XTickLabel', [.1 10], 'YTick', [0 1], 'YTickLabel', [0 1]);
xlabel('Cost of punishing');
ylabel(sprintf('Prob. of evolving\nreward for action'));
%set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 60);
hl = legend('Punishment', 'Theft', ...
    'location', 'southeast');