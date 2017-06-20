%% getFullGene
% Takes [stealGene punishGene] as input, and outputs a linear index of
% strategy pair.
% Important ones:
%   If nGenes == 3 (i.e. embedded RL simulations), then (LS, AP) = 4 and
%   (AS, LP) = 2. Order: Flex Always Never.
%   If nGenes == 5 (i.e. replicator simulations), then (LS, AP) = 6 and
%   (AS, LP) = 2.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

function [gene] = getFullGene(genes, nGenes)
gene = fastsub2ind([nGenes nGenes], genes(1), genes(2));