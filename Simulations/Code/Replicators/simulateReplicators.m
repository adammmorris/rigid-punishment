%% simulateReplicators
% Simulates the stochastic evolution of a finite population of agents
% playing the steal/punish game, using the larger 5x5 strategy space (for
% each role, all 4 reactive strategies plus 1 learning strategy).

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Set parameters

% Simulation parameters
nAgents = 100;
nGenerations = 10000;
invTemp = 1 / 1000;

% Vary theta
thetaVals = linspace(0, 1, 101);
nThetaVals = length(thetaVals);
nSamplesPerVal = 100;

% Randomly sample other parameters
N = 10000;
mutation = .01 + rand(nThetaVals, nSamplesPerVal) * .65; % .1 to .66
s = .1 + rand(nThetaVals, nSamplesPerVal)*19.9; % .1 to 20
sp = .1 + rand(nThetaVals, nSamplesPerVal)*19.9; % .1 to 20
c = .1 + rand(nThetaVals, nSamplesPerVal)*19.19; % .1 to 20
p = s + rand(nThetaVals, nSamplesPerVal)*30; % s to s + 30

%% Run simulation

% Initialize recording arrays
outcomes = zeros(nThetaVals, nSamplesPerVal);

IND_FAMILIAR = 1;
IND_PARADOXICAL = 2;
IND_OTHER = 3;

for thisParamVal = 1:nThetaVals
    theta = thetaVals(thisParamVal);
    
    parfor thisSample = 1:nSamplesPerVal
        payoffs = getPayoffs(N, ...
            s(thisParamVal, thisSample), sp(thisParamVal, thisSample), ...
            c(thisParamVal, thisSample), p(thisParamVal, thisSample), ...
            theta);
        
        [~, ~, population_full] = ...
            runMoran(payoffs, nAgents, nGenerations, invTemp, mutation(thisParamVal, thisSample));
        
        cutoff = 1 - mutation(thisParamVal, thisSample) - .1;

        if mean(mean(population_full(1001:nGenerations, :) == IND_FAMILIAR)) > cutoff
            outcomes(thisParamVal, thisSample) = IND_FAMILIAR;
        elseif mean(mean(population_full(1001:nGenerations, :) == IND_PARADOXICAL)) > cutoff
            outcomes(thisParamVal, thisSample) = IND_PARADOXICAL;
        elseif mean(mean(population_full(1001:nGenerations, :) == 3)) > cutoff
            outcomes(thisParamVal, thisSample) = 3;
        elseif mean(mean(population_full(1001:nGenerations, :) == 4)) > cutoff
            outcomes(thisParamVal, thisSample) = 4;
        elseif mean(mean(population_full(1001:nGenerations, :) == 5)) > cutoff
            outcomes(thisParamVal, thisSample) = 5;
        else
            outcomes(thisParamVal, thisSample) = 6;
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
xlim([0 nThetaVals + 1]);
ylim([0 1]);
hl = legend('Always punish theft / Flexibly steal', 'Always steal / Flexibly punish theft', 'Other', ...
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
xlabel('theta');
ylabel('Probability of equilibrium');
set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 40);

%% Save
%save('replicators.mat');