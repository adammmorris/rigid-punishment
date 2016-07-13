%% getSoftmax
% Converts Q values into probabilities with a softmax function. Includes
% checks for values outside of MATLAB's allowed ranges.

%% Inputs
% vec: vector of length numActions, containing the Q values for each action
% invTemp: the inverse temperature of the softmax function

%% Outputs
% prob: vector of probabilities, one for each action

function [prob] = getSoftmax(vec, invTemp)
% Get exponent
prob = exp(vec * invTemp - logsumexp(vec * invTemp));