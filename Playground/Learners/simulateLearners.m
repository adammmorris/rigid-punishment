%% learningMatches
% Plays two learning agents against each other in the steal/punish game many times,
% and records average results.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Initialize
nMatches = 100;

EXPLOITED = 1;
OTHER = 2;

%% Parameters

% Vary s and c
paramToVary = {'s', 'c'};
paramVals = {linspace(.1, 5, 50), linspace(0, .75, 50)};
nParamsToVary = length(paramToVary);
nParamVals = [length(paramVals{1}) length(paramVals{2})];

% Fix other parameters
N = 10000;
s = 2;
sp = 2;
c = 1;
p = 5;

lr = .2;
gamma = .95;
temp = 10;
stealBias = 0;
punishBias = 0;
pctPunCost = 1;
memory = 2;

%% Run sims
result_total = zeros(nParamVals(1), nParamVals(2), 3);
cutoff = .95;

for firstParamVal = 1:length(paramVals{1})
    for secondParamVal = 1:length(paramVals{2})
        eval(strcat(paramToVary{1}, ' = paramVals{1}(firstParamVal);'));
        eval(strcat(paramToVary{2}, ' = paramVals{2}(secondParamVal);'));
        
        result = zeros(nMatches, 1);
        
        parfor i = 1:nMatches
            [~, finalQpun, ~, thiefActions, punActions] = ...
                runMatch([N s sp c p], [lr gamma temp stealBias punishBias pctPunCost memory]);
            
            if mean(thiefActions((end-499):end) == 2) > cutoff && mean(punActions((end-499):end) == 2) < (1-cutoff)
                % If the thief is consistently stealing & the punisher is consistently
                %   not punishing..
                result(i) = EXPLOITED;
            elseif mean(thiefActions((end-499):end) == 2) < (1-cutoff) && all(mean(finalQpun([6 8], (end-499):end), 2) > 0)
                % If the thief is not stealing b/c the punisher prefers to punish
                %   if stolen from...
                result(i) = NOT_EXPLOITED;
            else
                result(i) = OTHER;
            end
        end
        
        result_total(firstParamVal, secondParamVal, :) = histc(result, 1:3) / nMatches;
    end
end

%% Draw
figure

if length(paramsToVary) == 2
    H=surf(paramVals{1}, paramVals{2}, result_total(:, :, 1)');
    zlim([0 1]);
    xlabel(paramToVary(1));
    ylabel(paramToVary(2));
    zlabel('Prob. that victim is exploited');
    set(gca, 'LineWidth', 4);
    set(gca, 'FontSize', 40);
else
    H = bar(result_total, 'stacked');
    set(H(1),'facecolor',[150 0 150] / 255);
    set(H(2),'facecolor',[50 150 0] / 255);
    set(H(3),'facecolor',[0 0 0]);
    set(H, 'edgecolor', [0 0 0]);
    xlim([0 nParamVals + 1]);
    ylim([0 1]);
    hl = legend('Punisher exploited', 'Thief exploited', 'Other', ...
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
    xlabel('% of punishment costliness');
    ylabel('Probability of outcome');
    set(gca, 'LineWidth', 4);
    set(gca, 'FontSize', 40);
end