function  ramtrainPerResidue(varargin)
% function  ramtrainPerResidue(varargin)
% This code extracts for each residue the histogram of the torsion (phi, psi) angles
% and the histogram of distances (contact map).
% 
% Default values:
% list      : filename of the list including the pdb entries (list.txt)
% datapath  : folder including pdb files if already downloaded (Data); if not 
%             downloaded, they will be accessed immediately from the PDB
% modelfname: output filename (pdbmodel.mat)
% ext =     : extension of the pdb files ('')
% kernel    : 3x3 mean kernel ('gaussian')
% bin       : width of histogram bins in angles
%
% Example:  ramtrainPerResidue('list','..\Data\list_example.txt');
%


%% parse input variables
[datapath,~,ext,kernel,bin, modelfname,list] =  parseInputs(varargin{:});

%% Extract histogram of the angles as signature for each protein structure %%
[IDs, classes] = textread(list,'%s%d%*[^\n]','delimiter',' ');
numproteins =length(IDs);
if ~isempty(ext)
    fnames = cell(numproteins,1);  
    for i=1:length(IDs)	   	
        fprintf('\n*** protein : %d (out of %d)  *** \n',i,length(IDs));    
        fnames{i}=[IDs{i}, ext];  
    end   
else
    fnames = IDs;
end

histsize=(360/bin)+1;
histAngles = zeros(numproteins,23,histsize,histsize);
contactMaps = zeros(numproteins,23,23,8);
ind2list = zeros(numproteins,1);
classLabels = zeros(numproteins,1);


j=1;
pathstr = fileparts(modelfname);
fid = fopen(fullfile(pathstr,'unsucessfulPDBs.txt'),'w');
for i=1:numproteins 
        
    clear angles contactMap class
    class = classes(i);
    disp([fnames{i} ' of class ' num2str(class)]);
    
    pdbfile = fullfile(datapath, fnames{i});
    try
        if ~exist( pdbfile,'file')
            s = getpdb(fnames{i}); 
        else
            s = pdbread(pdbfile); 
        end     
        angles = calcfeaturesPerResidue(s, kernel, bin);      
        contactMap = histContactMap(s);         
    catch
        fprintf(fid,'%s %d\n',fnames{i},classes(i));
        continue
    end
    classLabels(j) = class;          
      
    histAngles(j,:,:,:) = angles;
    contactMaps(j,:,:,:) = contactMap;
    ind2list(j) = i;
    j=j+1;    
end
fclose(fid);

if j-1<numproteins % if it failed for some proteins
    ind2list(j:end)=[];
    histAngles(j:end,:,:,:) = [];
    contactMaps(j:end,:,:,:) = [];
    classes = classes(ind2list);
    fnames = fnames(ind2list);
end
save(modelfname,'histAngles','contactMaps', 'classes', 'fnames', 'ind2list','-v7.3');
disp(['Training model saved as ' modelfname '. Finished.']);

classLabels(j:end)=[];
sum(classes~=classLabels)

end
