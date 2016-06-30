function [ind] = fastsub2ind(siz, rows, cols)
ind = rows + (cols - 1) * siz(1);