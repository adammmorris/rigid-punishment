function [r, c] = fastind2sub(siz, ind)
r = rem(ind-1,siz(1))+1;
c = (ind-r)/siz(1) + 1;