%% fastind2sub
% A faster version of MATLAB's "ind2sub" function.
% Courtesy of emrea at http://tipstrickshowtos.blogspot.com/

function [r, c] = fastind2sub(siz, ind)
r = rem(ind-1,siz(1))+1;
c = (ind-r)/siz(1) + 1;