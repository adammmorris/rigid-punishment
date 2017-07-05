%% simulateReplicators
% Simulates the stochastic evolution of a finite population of agents
% playing the steal/punish game, using the larger 5x5 strategy space (for
% each role, all 4 reactive strategies plus 1 learning strategy).
% Systematically varies theta while randomly sampling other parameters.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set parameters

% Vary theta
thetaVals = linspace(0, 1, 101);
nThetaVals = length(thetaVals);

nSamplesPerVal = 100; % # of simulations to run per value of c
nAgents = 100;
nGenerations = 10000;
N = 5000; % # of rounds in game

% Set either fixed, or random, selection intensity / mutation rate
w = repmat(1 / 1000, nThetaVals, nSamplesPerVal);
%w = 1 / 10000 + rand(nParamVals, nSamplesPerVal) * (1 / 100 - 1 / 10000);
mu = repmat(.05, nThetaVals, nSamplesPerVal);
%mu = rand(nThetaVals, nSamplesPerVal)*2/3;

% Randomly sample payoffs
s = rand(nThetaVals, nSamplesPerVal)*10; % .1 to 20
sp = s; % for simplicity, fix the cost of being stolen (sp) from at s
c = rand(nThetaVals, nSamplesPerVal)*10; % .1 to 20
p = s + rand(nThetaVals, nSamplesPerVal)*20; % s to s + 30

%% Run simulation

% Initialize recording arrays
outcomes = zeros(nThetaVals, nSamplesPerVal);

IND_FAMILIAR = 10;
IND_PARADOXICAL = 21;
IND_NOCONV = 0;

% For each value of theta..
parfor thisParamVal = 1:nThetaVals
    theta = thetaVals(thisParamVal);
    
    % Run all the samples
    for thisSample = 1:nSamplesPerVal
        payoffs = getPayoffs(N, ...
            s(thisParamVal, thisSample), sp(thisParamVal, thisSample), ...
            c(thisParamVal, thisSample), p(thisParamVal, thisSample), ...
            theta);
        
        [~, ~, population_full] = ...
            runMoran(payoffs, nAgents, nGenerations, w(thisParamVal, thisSample), mu(thisParamVal, thisSample));
        
        % What % of the population must be a certain strategy to count the
        % simulation as having converged to that strategy?
        cutoff = 1 - mu(thisParamVal, thisSample) - .1;

        % Classify sample
        for eq = 1:25
            if mean(mean(population_full(1001:nGenerations, :) == eq)) > cutoff
                outcomes(thisParamVal, thisSample) = eq;
                break;
            end
        end
    end
end

%% Plot

figure

H=bar([mean(outcomes == IND_FAMILIAR, 2), mean(outcomes == IND_PARADOXICAL, 2), ...
    mean(outcomes ~= IND_FAMILIAR & outcomes ~= IND_PARADOXICAL & outcomes ~= IND_NOCONV, 2), ...
    mean(outcomes == IND_NOCONV, 2)], 'stacked', 'BarWidth', 1);
set(H(1),'facecolor',[0 180 185] / 255);
set(H(2),'facecolor',[255 140 0] / 255);
set(H(3),'facecolor',[25 25 25] / 255);
set(H(4),'facecolor',[120 120 120] / 255);
set(H, 'edgecolor', [0 0 0]);
xlim([0 nThetaVals + 1]);
ylim([0 1]);
hl = legend('Rigid punishment', 'Rigid theft', 'Other', 'No convergence', ...
    'location', 'southeast');
set(gca, 'XTick', [0 nThetaVals + 1], 'XTickLabel', [0 1], 'YTick', [0 1], 'YTickLabel', [0 1]);
xlabel('Vulnerability of flexible victims (?)');
ylabel(sprintf('Probability of\nequilibrium'));
set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 60);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);