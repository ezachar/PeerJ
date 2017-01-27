function [symbols] = aminoAcidSymbols()
% symbols = aminoAcidSymbols()
% It returns the 3-letter strings of the 20 standard amino acids 
% and the 3 ambiguous amino acids which indicate that it was not 
% possible to differentiate their type:
% 'ASX': asparagine/aspartic acid (whereas ASN is asparagine)
% 'GLX': glutamine/glutamic acid (whereas GLN is glutamine)
% 'UNK': unknown residue name


symbols = {'ALA', 'ARG', 'ASN', 'ASP', 'ASX', 'CYS', 'GLN', 'MET', ...
           'GLU', 'GLX', 'GLY', 'HIS', 'ILE', 'LEU', 'LYS', 'PHE', ...
           'PRO', 'SER', 'THR', 'TRP', 'TYR', 'UNK', 'VAL'};
