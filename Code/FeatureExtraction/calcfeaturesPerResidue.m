function sRhist = calcfeaturesPerResidue(pdb_struct, kernel, bin)
% function features = calcfeaturesPerResidue(pdb, kernel, bin)
% pdb   : PDBID or PDBFILE or PDBSTRUCT
% features : [numResidues x numBins x numBins] 3D matrix with the 2D histogram 
%           of the torsion angles for each residue (amino acid) => 
%           [23 x 19 x 19]
%

%% get pdb structure
try
    if (~isstruct(pdb_struct))
        if exist(pdb_struct,'file') % read it from the file
            s = pdbread(pdb_struct);
        else % get it from PDB
            s = getpdb(pdb_struct);
        end
    else % get it from structure
        s = pdb_struct; % s = convertpdbstruct(pdb_struct, mfilename);
    end
catch theErr
    if ~isempty(strfind(theErr.identifier,'getpdb')) 
        rethrow(theErr);
    end
    error(message('calcfeaturesForResidue:IllegalInput'));
end
 

%% Calculate ramanchandran plot and merge all chains  
warning off       
Rall = ramachandran(s, 'plot', 'none');
% warning on
R = Rall(1);     
for i=2:numel(Rall)
  if ~ismember(Rall(i).Chain,R.Chain)              
      R.Angles = [R.Angles; Rall(i).Angles];
      R.ResidueNum = [R.ResidueNum; Rall(i).ResidueNum];
      R.ResidueName = [R.ResidueName; Rall(i).ResidueName];
      R.Chain = [R.Chain; Rall(i).Chain];   
  end
end
clear R0
   

%% Clear errors or missing values
delete = find( isempty(R.ResidueName) | isnan(sum(R.Angles,2)) );
R.Angles(delete,:)=[];
R.ResidueNum(delete)=[];
R.ResidueName(delete)=[];       


%% Calculate unnormalized histogram
symbols = aminoAcidSymbols();
bins = [-180:bin:180]; % bins = linspace(-180, 180, 9);
sRhist = zeros(length(symbols), length(bins), length(bins)); 

for i=1:length(symbols)
    residueIndices = ismember(R.ResidueName, symbols{i});
    if ~isempty(residueIndices)
        angles = R.Angles(residueIndices,1:2);
        Rhist = hist3(angles, {bins bins});   
        sRhist(i,:,:) = conv2(Rhist, kernel, 'same'); % Convolve keeping size of ramachan
%         sRhist(i,:,:) = sRhist(i,:,:)/sum(sum(sRhist(i,:,:))); % normalize, better for all probabilistic methods 
    end
end

    
end
