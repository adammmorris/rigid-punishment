%% getSoftmax
% Converts Q values into probabilities with a softmax function, with
% workarounds for floating point errors.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

%% Inputs
% vec: vector of length numActions, containing the Q values for each action
% invTemp: the inverse temperature of the softmax function

%% Outputs
% prob: vector of probabilities, one for each action

function [prob] = getSoftmax(vec, invTemp)
prob = exp(vec * invTemp - logsumexp(vec * invTemp));