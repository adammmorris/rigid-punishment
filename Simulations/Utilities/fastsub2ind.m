%% fastsub2ind
% A faster version of MATLAB's "sub2ind" function.
% Courtesy of emrea at http://tipstrickshowtos.blogspot.com/

function [ind] = fastsub2ind(siz, rows, cols)
ind = rows + (cols - 1) * siz(1);