%% learningMatches
% Plays two learning agents against each other in the steal/punish game many times,
% and records average results.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Parameters

useRandomParams = false;

nMatches = 20;
N = 10000;

if useRandomParams
    s = .1 + rand(nMatches,1)*19.19; % .1 to 20
    sp = .1 + rand(nMatches,1)*19.9; % .1 to 20
    c = .1 + rand(nMatches,1)*19.19; % .1 to 20
    p = s + rand(nMatches,1)*30; % s to s + 30
    
    % This doesn't matter here
    paramToVary = '';
    paramVals = 1;
else
    s = 2 * ones(nMatches, 1);
    sp = 2 * ones(nMatches, 1);
    c = 1 * ones(nMatches, 1);
    p = 5 * ones(nMatches, 1);
    
    % Vary c
    paramToVary = 'c';
    paramVals = linspace(.1, 1, 21);
end

nParamVals = length(paramVals);
lr = .2;
gamma = .95;
temp = 10;
stealBias = 0;
punishBias = 0;
pctPunCost = 1;
memory = 2;

%% Run sims
result_total = zeros(nParamVals, 3);
cutoff = .90;
cutoffRange = 5001:N;

EXPLOITED = 1;
NOT_EXPLOITED = 2;
OTHER = 3;

for firstParamVal = 1:nParamVals
    if ~useRandomParams
        eval(strcat(paramToVary, '(:) = paramVals(firstParamVal);'));
    end
    
    result = zeros(nMatches, 1);
    
    parfor i = 1:nMatches
        [~, finalQpun, ~, thiefActions, punActions] = ...
            runMatch([N s(i) sp(i) c(i) p(i)], [lr gamma temp stealBias punishBias pctPunCost memory]);
        
        if mean(thiefActions(cutoffRange) == 2) > cutoff && mean(punActions(cutoffRange) == 2) < (1-cutoff)
            % If the thief is consistently stealing & the punisher is consistently
            %   not punishing..
            result(i) = EXPLOITED;
        elseif mean(thiefActions(cutoffRange) == 2) < (1-cutoff)
            % If the thief is not stealing...
            result(i) = NOT_EXPLOITED;
        else
            result(i) = OTHER;
        end
    end
    
    result_total(firstParamVal, :) = histc(result, 1:3) / nMatches;
end

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
    set(gca, 'XTick', [0 1], 'XTickLabel', {'.1', '', '1'}, 'YTick', [0 1], 'YTickLabel', [0 1]);
    xlabel('Cost of punishing');
    ylabel('Probability of learning outcome');
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