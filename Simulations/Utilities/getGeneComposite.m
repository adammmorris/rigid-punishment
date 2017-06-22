%% getGeneComposite
% Takes linear index and outputs [stealGene punishGene].
% Adam Morris, James MacGlashan, Michael Littman, & Fiery Cushman
% July 2016

function [stealGene, punishGene] = getGeneComposite(geneInd, nGenes)
[stealGene, punishGene] = fastind2sub([nGenes nGenes], geneInd);