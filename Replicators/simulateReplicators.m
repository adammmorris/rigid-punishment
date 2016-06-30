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

% Which parameter are we varying (if any)?
paramToVary = 'theta';
paramVals = linspace(0, 1, 11);
nSamplesPerVal = 100;
nParamVals = length(paramVals);

randomParameters = true;

N = 10000;
theta = 0;

if randomParameters
    mutation = .01 + rand(nParamVals, nSamplesPerVal) * .45;
    ks = 1 + rand(nParamVals, nSamplesPerVal) * 99;
    kp = 1 + rand(nParamVals, nSamplesPerVal) * 99;
    s = .5 + rand(nParamVals, nSamplesPerVal)*19.5; % .5 to 20
    sp = .5 + rand(nParamVals, nSamplesPerVal)*19.5; % .5 to 20
    c = .01 + rand(nParamVals, nSamplesPerVal)*1; % .01 to 1 (% of sp)
    p = s + rand(nParamVals, nSamplesPerVal)*30; % s to s + 30
    invTemp = 1 / 1000;
else
    mutation = repmat(.1, nParamVals, nSamplesPerVal);
    ks = repmat(10, nParamVals, nSamplesPerVal);
    kp = repmat(10, nParamVals, nSamplesPerVal);
    s = repmat(2, nParamVals, nSamplesPerVal);
    sp = repmat(2, nParamVals, nSamplesPerVal);
    c = repmat(1, nParamVals, nSamplesPerVal);
    p = repmat(5, nParamVals, nSamplesPerVal);
    invTemp = 1 / 100;
end

%% Run simulation

% Initialize recording arrays
outcomes = zeros(nParamVals, nSamplesPerVal);

IND_FAMILIAR = 1;
IND_PARADOXICAL = 2;
IND_OTHER = 3;

cutoff = 1 - mutation - .1;

for thisParamVal = 1:nParamVals
    eval(strcat(paramToVary, ' = paramVals(thisParamVal);'));
    
    parfor thisSample = 1:nSamplesPerVal
        payoffs = getPayoffs(N, ...
            s(thisParamVal, thisSample), sp(thisParamVal, thisSample), ...
            c(thisParamVal, thisSample), p(thisParamVal, thisSample), ...
            ks(thisParamVal, thisSample), kp(thisParamVal, thisSample), theta);
        
        [~, ~, population_full] = ...
            runMoran(payoffs, nAgents, nGenerations, invTemp, mutation);
        
        if mean(mean(population_full(1001:nGenerations, :) == IND_FAMILIAR)) > cutoff
            outcomes(thisParamVal, thisSample) = IND_FAMILIAR;
        elseif mean(mean(population_full(1001:nGenerations, :) == IND_PARADOXICAL)) > cutoff
            outcomes(thisParamVal, thisSample) = IND_PARADOXICAL;
        else
            outcomes(thisParamVal, thisSample) = IND_OTHER;
        end
    end
end

%% Draw
figure

H=bar([mean(outcomes == IND_FAMILIAR, 2), mean(outcomes == IND_PARADOXICAL, 2), mean(outcomes == IND_OTHER, 2)], 'stacked');
set(H(1),'facecolor',[0 180 185] / 255);
set(H(2),'facecolor',[255 140 0] / 255);
set(H(3),'facecolor',[0 0 0]);
set(H, 'edgecolor', [0 0 0]);
xlim([0 nParamVals + 1]);
ylim([0 1]);
hl = legend('Always punish theft / learn to stop stealing', 'Always steal / learn to stop punishing', 'Other', ...
    'location', 'northoutside');
legend('boxoff');
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
xlabel(paramToVary);
ylabel('Probability of equilibrium');
set(gca, 'LineWidth', 4);
set(gca, 'FontSize', 40);

%% Save
%save('replicators.mat', '-v7.3')