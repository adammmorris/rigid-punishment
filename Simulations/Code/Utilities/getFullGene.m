%% getFullGene
% Takes [stealGene punishGene] as input, and outputs:
%   1 if the pair is the familiar equilibrium (LS, APT)
%   2 if the pair is the paradoxical equilibrium (AS, LPT)
%   3 if the pair is anything else

% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

function [gene] = getFullGene(genes, nGenes)
if nGenes == 5
    if genes(1) == 5 && genes(2) == 2, gene = 1; % familiar (LS, APT)
    elseif genes(1) == 1 && genes(2) == 5, gene = 2; % paradoxical (AS, LPT)
    elseif genes(1) == 5 && genes(2) == 5, gene = 3; % (LS, LP)
    elseif genes(1) == 1 && genes(2) == 2, gene = 4; % (AS, APT)
    elseif genes(1) == 1 && genes(2) == 4, gene = 5; % (AS, NP)
    else gene = 6; % other
    end
elseif nGenes == 3
    if genes(1) == 1 && genes(2) == 2, gene = 1; % familiar (LS, APT)
    elseif genes(1) == 2 && genes(2) == 1, gene = 2; % paradoxical (AS, LPT)
    else gene = 3; % other
    end
else
    error('nGenes must be 5 (replicator simulations) or 3 (agent-based simulations).');
end