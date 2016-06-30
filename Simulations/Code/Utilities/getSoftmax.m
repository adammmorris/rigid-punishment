function [prob] = getSoftmax(vec, invTemp)
numerator = exp(vec * invTemp);
whichInf = isinf(numerator);
whichZero = numerator == 0;
if any(whichInf)
    numerator(whichInf) = 1;
    numerator(~whichInf) = 0;
elseif any(whichZero)
    numerator(whichZero) = realmin;
end
prob = numerator / sum(numerator);