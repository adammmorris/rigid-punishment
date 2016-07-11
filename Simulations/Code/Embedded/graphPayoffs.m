%% graphPayoffs
% Visualizes the simulated payoffs for all instantiated RL strategy pairs in the
% steal/punish game.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

costly = false;

load('cache.mat');
figure

if costly
    payoffs = payoffs_costly;
else
    payoffs = payoffs_notcostly;
end

% AS vs APT
g1 = subplot(3,3,1);
hold on
histogram(payoffs(2,2,1,:), 'FaceColor', 'r')
histogram(payoffs(2,2,2,:), 'FaceColor', 'b')
title('Always punish theft');
ylabel('Always steal');
hold off

% AS vs NP
g2 = subplot(3,3,2);
hold on
histogram(payoffs(2,3,1,:), 'FaceColor', 'r')
histogram(payoffs(2,3,2,:), 'FaceColor', 'b')
title('Never punish');
hold off

% AS vs LPT
g3 = subplot(3,3,3);
hold on
histogram(payoffs(2,1,1,:), 'FaceColor', 'r')
histogram(payoffs(2,1,2,:), 'FaceColor', 'b')
title('Learn to punish theft');
hold off

% NS vs AP
g4 = subplot(3,3,4);
hold on
histogram(payoffs(3,2,1,:), 'FaceColor', 'r')
histogram(payoffs(3,2,2,:), 'FaceColor', 'b')
ylabel('Never steal');
hold off

% NS vs NP
g5 = subplot(3, 3, 5);
hold on
histogram(payoffs(3,3,1,:), 'FaceColor', 'r')
histogram(payoffs(3,3,2,:), 'FaceColor', 'b')
hold off

% NS vs LP
g6 = subplot(3, 3, 6);
hold on
histogram(payoffs(3,1,1,:), 'FaceColor', 'r')
histogram(payoffs(3,1,2,:), 'FaceColor', 'b')
hold off

% LS vs APT
g7 = subplot(3, 3, 7);
hold on
histogram(payoffs(1,2,1,:), 'FaceColor', 'r')
histogram(payoffs(1,2,2,:), 'FaceColor', 'b')
ylabel('Learn to steal');
hold off

% LS vs NP
g8 = subplot(3, 3, 8);
hold on
histogram(payoffs(1,3,1,:), 'FaceColor', 'r')
histogram(payoffs(1,3,2,:), 'FaceColor', 'b')
hold off

% LS vs LP
g9 = subplot(3, 3, 9);
hold on
histogram(payoffs(1,1,1,:), 'FaceColor', 'r')
histogram(payoffs(1,1,2,:), 100, 'FaceColor', 'b')
hold off

%linkaxes([g1 g2 g3 g4 g5 g6 g7 g8 g9], 'x');