%% getFullGene
% Takes [stealGene punishGene] as input, and outputs a linear index of
% strategy pair.
% Important ones:
%   If nGenes == 3 (i.e. embedded RL simulations), then (LS, AP) = 4 and
%   (AS, LP) = 2.
%   If nGenes == 5 (i.e. replicator simulations), then (LS, AP) = 6 and
%   (AS, LP) = 2.

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

function [gene] = getFullGene(genes, nGenes)
% if nGenes == 5
%     if genes(1) == 5 && genes(2) == 2, gene = 1; % familiar (LS, APT)
%     elseif genes(1) == 1 && genes(2) == 5, gene = 2; % paradoxical (AS, LPT)
%     else gene = 3; % other
%     end
% elseif nGenes == 3
%     if genes(1) == 1 && genes(2) == 2, gene = 1; % familiar (LS, APT)
%     elseif genes(1) == 2 && genes(2) == 1, gene = 2; % paradoxical (AS, LPT)
%     elseif genes(1) == 2 && genes(2) == 3, gene = 3;
%     else gene = 4;
%     end
% else
%     error('nGenes must be 5 (replicator simulations) or 3 (embedded agent-based simulations).');
% end
gene = fastsub2ind([nGenes nGenes], genes(1), genes(2));