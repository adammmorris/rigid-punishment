%% matchAnalysis
% Plays two learners against each other in the steal-punish game,
% and records Q values and behavior through the whole match.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Parameters
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
pctCostly = .2;

costly = false;

%% Do it
[rqt, rqp, earnt, earnp, actionst, actionsp] = runMatch([N s sp c p], [lr gamma temp stealBias punishBias pctCostly], costly);
num = 1+N*2;

legend_thiefTurn = {'NoSteal/NoPun', 'NoSteal/Pun', 'Steal/NoPun', 'Steal/Pun'};
legend_punTurn = {'NoPun/NoSteal', 'NoPun/Steal', 'Pun/NoSteal', 'Pun/Steal'};

% Thief: my turn
figure
subplot(3,2,1);
hold on
plot(1:num, rqt(1:4, :), '-');
legend(legend_thiefTurn{:});
xlim([0 num]);
xlabel('Round');
ylabel('Preference for stealing');
plot(1:num, zeros(num, 1), '-k', 'LineWidth', 1);
title('Thief: thiefs turn');
hold off

% Thief: opponent's turn
subplot(3,2,2);
hold on
plot(1:num, -rqt(5:8, :), '-');
legend(legend_punTurn{:});
xlim([0 num]);
xlabel('Round');
ylabel('Q value');
plot(1:num, zeros(num, 1), '-k', 'LineWidth', 1);
title('Thief: punishers turn'); 
hold off

% Punisher: opponent's turn
subplot(3,2,3);
hold on
plot(1:num, -rqp(1:4, :), '-');
legend(legend_thiefTurn{:});
xlim([0 num]);
xlabel('Round');
ylabel('Q value');
plot(1:num, zeros(num, 1), '-k', 'LineWidth', 1);
title('Punisher: thiefs turn');
hold off

% Punisher: my turn
subplot(3,2,4);
hold on
plot(1:num, rqp(5:8, :), '-');
legend(legend_punTurn{:});
xlim([0 num]);
xlabel('Round');
ylabel('Preference for punishing');
plot(1:num, zeros(num, 1), '-k', 'LineWidth', 1);
title('Punisher: punishers turn');
hold off

% Earnings
subplot(3, 2, 5);
bar([earnt earnp]);
title('Earnings');
set(gca,'XTickLabels', {'Thief', 'Punisher'});

% Actions
subplot(3, 2, 6);
hold on
bins = 1:10:N;
actionst_vis = zeros(length(bins)-1, 1);
actionsp_vis = zeros(length(bins)-1, 1);
for i = 1:(length(bins)-1)
    actionst_vis(i) = mean(actionst(bins(i):bins(i+1)) == 2);
    actionsp_vis(i) = mean(actionsp(bins(i):bins(i+1)) == 2);
end
plot(actionst_vis);
plot(actionsp_vis);
xlabel('Rounds (in 10s)');
ylabel('% of trials stealing/punishing');
title('Actions');
legend('Thief', 'Punisher');
hold off