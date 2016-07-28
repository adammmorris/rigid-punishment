%% getPayoffs
% Creates a matrix of the payoff structure of the larger 5x5 strategy
% space in the steal-punish game, for any given parameters.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Inputs
% N: # of rounds in the steal/punish game
% s: benefit of stealing
% sp: cost of being stolen from (absolute value)
% c: cost of punishing (absolute value)
% p: cost of being punished (absolute value)
% theta: probability that the thief continues stealing / punisher desists
%   (and not the other way around)

function [payoffs] = getPayoffs(N, s, sp, c, p, theta)

% 5 steal genes, 5 punish genes, 2 payoffs for each matchup (thief payoff & punisher payoff)
payoffs = zeros(5, 5, 2); 

% Always steal vs always punish
payoffs(1, 1, 1) = N * (s - p);
payoffs(1, 1, 2) = N * (-sp - c);

% Always steal vs always punish theft
payoffs(1, 2, 1) = N * (s - p);
payoffs(1, 2, 2) = N * (-sp - c);

% Always steal vs punish after non-steal
payoffs(1, 3, 1) = N * s;
payoffs(1, 3, 2) = -N * sp;

% Always steal vs never punish
payoffs(1, 4, 1) = N * s;
payoffs(1, 4, 2) = -N * sp;

% Always steal vs learn to punish
payoffs(1, 5, 1) = N * s;
payoffs(1, 5, 2) = -N * sp;

% Steal after punishment vs always punish
payoffs(2, 1, 1) = N * (s - p);
payoffs(2, 1, 2) = N * (-sp - c);

% Steal after punishment vs always punish theft
payoffs(2, 2, 1) = N / 2 * (s - p);
payoffs(2, 2, 2) = N / 2 * (-sp - c);

% Steal after punishment vs punish after non-steal
payoffs(2, 3, 1) = N / 2 * (s - p);
payoffs(2, 3, 2) = N / 2 * (-sp - c);

% Steal after punishment vs never punish
payoffs(2, 4, 1) = 0;
payoffs(2, 4, 2) = 0;

% Steal after punishment vs learn to punish
payoffs(2, 5, 1) = 0;
payoffs(2, 5, 2) = 0;

% Steal after non-punishment vs always punish
payoffs(3, 1, 1) = -N * p;
payoffs(3, 1, 2) = -N * c;

% Steal after non-punishment vs always punish theft
payoffs(3, 2, 1) = N / 2 * (s - p);
payoffs(3, 2, 2) = N / 2 * (-sp - c);

% Steal after non-punishment vs punish after non-steal
payoffs(3, 3, 1) = N / 2 * (s - p);
payoffs(3, 3, 2) = N / 2 * (-sp - c);

% Steal after non-punishment vs never punish
payoffs(3, 4, 1) = N * s;
payoffs(3, 4, 2) = -N * sp;

% Steal after non-punishment vs learn to punish
payoffs(3, 5, 1) = N * (-p * (c <= sp) + s * (c > sp));
payoffs(3, 5, 2) = -N * (c * (c <= sp) + sp * (c > sp));

% Never steal vs always punish
payoffs(4, 1, 1) = -N * p;
payoffs(4, 1, 2) = -N * c;

% Never steal vs always punish theft
payoffs(4, 2, 1) = 0;
payoffs(4, 2, 2) = 0;

% Never steal vs punish after non-steal
payoffs(4, 3, 1) = -N * p;
payoffs(4, 3, 2) = -N * c;

% Never steal vs never punish
payoffs(4, 4, 1) = 0;
payoffs(4, 4, 2) = 0;

% Never steal vs learn to punish
payoffs(4, 5, 1) = 0;
payoffs(4, 5, 2) = 0;

% Learn to steal vs always punish
payoffs(5, 1, 1) = N * (s - p);
payoffs(5, 1, 2) = N * (-sp - c);

% Learn to steal vs always punish theft
payoffs(5, 2, 1) = 0;
payoffs(5, 2, 2) = 0;

% Learn to steal vs punish after non-steal
payoffs(5, 3, 1) = N * s;
payoffs(5, 3, 2) = -N * sp;

% Learn to steal vs never punish
payoffs(5, 4, 1) = N * s;
payoffs(5, 4, 2) = -N * sp;

% Learn to steal vs learn to punish
%theta = ks > kp;
payoffs(5, 5, 1) = theta * N * s;
payoffs(5, 5, 2) = theta * -N * sp;