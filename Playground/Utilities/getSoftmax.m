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
numerator = exp(vec * invTemp);

% Check for infinities & zeros
whichInf = isinf(numerator);
whichZero = numerator == 0;

if any(whichInf)
    % If there's infinities, make them all 1 and set everything else to zero
    numerator(whichInf) = 1;
    numerator(~whichInf) = 0;
elseif any(whichZero)
    % If there's no infinities but there are zeros, change them to realmin
    numerator(whichZero) = realmin;
end

% Normalize
prob = numerator / sum(numerator);