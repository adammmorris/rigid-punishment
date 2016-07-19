%% learningMatches
% Plays two learning agents against each other in the steal/punish game many times,
% and records average results.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Parameters
% If useRandomParams is true, all params are randomly sampled.
% If it's false, they are fixed, and c is varied systematically
useRandomParams = false;

nMatches = 100; % # of matches to simulate
N = 10000; % # of rounds in each match

if useRandomParams
    s = .1 + rand(nMatches,1)*19.19; % .1 to 20
    sp = .1 + rand(nMatches,1)*19.9; % .1 to 20
    c = .1 + rand(nMatches,1)*19.19; % .1 to 20
    p = s + rand(nMatches,1)*30; % s to s + 30
    
    % This doesn't matter here
    paramToVary = '';
    paramVals = 1;
else
    s = 1 * ones(nMatches, 1);
    sp = 1 * ones(nMatches, 1);
    c = 1 * ones(nMatches, 1);
    p = 3 * ones(nMatches, 1);
    
    % Vary c
    paramToVary = 'c';
    paramVals = linspace(.1, 2, 101);
end

nParamVals = length(paramVals);
lr = .2; % learning rate
gamma = .95; % discount rate
temp = 100; % inverse temperature of softmax policy function
stealBias = 0; % hedonic bias for stealing
punishBias = 0; % hedonic bias for punishing
pctPunCost = 1; % % of punishment's cost to be included in RF
agentMemory = 2; % agent memory

%% Run sims
result_total = zeros(nParamVals, 3);
% what % of trials need to match a particular learning outcome
% in order to count the match as having converged to that outcome?
cutoff = .95;
% which trials do we test for the above cutoff?
cutoffRange = 5001:N;

EXPLOITED = 1;
NOT_EXPLOITED = 2;
OTHER = 3;

for firstParamVal = 1:nParamVals
    % Systematically vary c (if useRandomParams is false)
    if ~useRandomParams
        eval(strcat(paramToVary, '(:) = paramVals(firstParamVal);'));
    end
    
    result = zeros(nMatches, 1);
    
    % Loop through matches
    parfor i = 1:nMatches
        [~, finalQpun, ~, thiefActions, punActions] = ...
            runMatch([N s(i) sp(i) c(i) p(i)], [lr gamma temp stealBias punishBias pctPunCost agentMemory]);
        
        if mean(thiefActions(cutoffRange) == 2) > cutoff && mean(punActions(cutoffRange) == 2) < (1-cutoff)
            % If the thief is consistently stealing & the punisher is consistently
            %   not punishing..
            result(i) = EXPLOITED;
        elseif mean(thiefActions(cutoffRange) == 2) < (1-cutoff)
            % If the thief is not stealing...
            result(i) = NOT_EXPLOITED;
        else
            % Otherwise...
            result(i) = OTHER;
        end
    end
    
    result_total(firstParamVal, :) = histc(result, 1:3) / nMatches;
end

% If useRandomParams is true, do logistic regression to determine the
% influence of the param values on the outcome
if useRandomParams
    good = result ~= OTHER;
    xs = [s(good) sp(good) c(good) p(good)];
    [b, ~, stats] = glmfit(xs, result(good) .* (1 - 1 * (result(good) == 2)), 'binomial');
    betas = b(2:end)' .* std(xs) ./ std(result(good));
end

%% Draw (part 1)
if ~useRandomParams
    figure

    H = bar(result_total, 'stacked');
    set(H(1),'facecolor',[150 0 150] / 255);
    set(H(2),'facecolor',[50 150 0] / 255);
    set(H(3),'facecolor',[0 0 0]);
    set(H, 'edgecolor', [0 0 0]);
    xlim([0 nParamVals + 1]);
    ylim([0 1]);
    hl = legend('RL victim exploited', 'RL thief exploited', 'Other', ...
        'location', 'northoutside');
    legend('boxoff');
    %set(gca, 'XTick', [0 nParamVals + 1], 'XTickLabel', [.1 1], 'YTick', [0 1], 'YTickLabel', [0 1]);
    xlabel('Cost of punishing');
    ylabel('Probability of outcome');
    set(gca, 'LineWidth', 4);
    set(gca, 'FontSize', 40);
end

%% Draw (part 2)
if ~useRandomParams
    hlt = text(...
        'Parent', hl.DecorationContainer, ...
        'String', 'Outcome', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'Position', [0.5, 1.05, 0], ...
        'Units', 'normalized', ...
        'FontSize', 40, ...
        'FontWeight', 'bold');
end