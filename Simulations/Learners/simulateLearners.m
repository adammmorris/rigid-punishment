%% learningMatches
% Plays two learning agents against each other in the steal/punish game many times,
% and records average results.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Parameters
% If useRandomParams is true, all params are randomly sampled.
% If it's false, they are fixed, and c is varied systematically
useRandomParams = false;

 % # of matches to simulate
if useRandomParams, nMatches = 10000;
else nMatches = 100;
end

if useRandomParams
    s = rand(nMatches,1)*10; % .1 to 20
    sp = s; % for simplicity, fix the cost of being stolen from (sp) at s
    c = rand(nMatches,1)*10; % .1 to 20
    p = s + rand(nMatches,1)*20; % s to s + 30
    
    % This doesn't matter here
    paramToVary = '';
    paramVals = 1;
else
    s = repmat(5, nMatches, 1);
    sp = s;
    c = repmat(5, nMatches, 1);
    p = repmat(15, nMatches, 1);

    % Vary c
    paramToVary = 'c';
    paramVals = linspace(.1, 10, 100);
end

nParamVals = length(paramVals);
N = 5000;

% Use either fixed, or random, RL parameters
lr = repmat(.2, nParamVals, nMatches); % learning rate
%lr = .05 + rand(nParamVals, nMatches) * .2;
gamma = repmat(.95, nParamVals, nMatches); % discount rate
%gamma = .75 + rand(nParamVals, nMatches) * (.99 - .75);
temp = repmat(20, nParamVals, nMatches); % inverse temperature of softmax policy function
%temp = 10 + rand(nParamVals, nMatches) * (100 - 10); 

stealBias = 0; % hedonic bias for stealing
punishBias = 0; % hedonic bias for punishing
pctPunCost = 1; % % of punishment's cost to be included in reward function (used to manipulate "perceived cost")
agentMemory = 2; % agent memory

%% Run sims
result_total = zeros(nParamVals, 3);
% what % of trials need to match a particular learning outcome
% in order to count the match as having converged to that outcome?
cutoff = .95;

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
        % which trials do we test for the above cutoff?
        cutoffRange = 1001:N;
        
        [~, finalQpun, ~, thiefActions, punActions] = ...
            runMatch([N s(i) s(i) c(i) p(i)], [lr(firstParamVal, i) gamma(firstParamVal, i) temp(firstParamVal, i) stealBias punishBias pctPunCost agentMemory]);
        
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
    xs = [s(good) c(good) p(good)];
    [b, ~, stats] = glmfit(xs, result(good) .* (1 - 1 * (result(good) == 2)), 'binomial');
    betas = b(2:end)' .* std(xs) ./ std(result(good));
end

%% Plot

if ~useRandomParams
    figure

    H = bar(result_total, 'stacked');
    set(H(1),'facecolor',[150 0 150] / 255);
    set(H(2),'facecolor',[50 150 0] / 255);
    set(H(3),'facecolor',[0 0 0]);
    xlim([0 nParamVals + 1]);
    ylim([0 1]);
    hl = legend('Thief learns to steal', 'Victim learns to punish', 'Other', ...
        'location', 'southeast');
    set(gca, 'XTick', [0 nParamVals/2 nParamVals + 1], 'XTickLabel', [.1 5 10], 'YTick', [0 1], 'YTickLabel', [0 1]);
    xlabel('Cost of punishing');
    ylabel(sprintf('Prob. of learning\noutcome'));
    set(gca, 'LineWidth', 4);
    set(gca, 'FontSize', 60);
end