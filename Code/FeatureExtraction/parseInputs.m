
function [datapath,outpath,ext,kernel,bin, modelfname,list] = parseInputs(varargin)
% function [datapath,outpath,ext,kernel,bin, modelfname,list] = parseInputs(varargin)
     
%=== Check for the right number of inputs
if rem(nargin,2)== 1
    error('IncorrectNumberOfArguments',...
        'Incorrect number of arguments to %s.',mfilename);
end

%=== Allowed inputs
okargs = {'datapath','outpath','ext','kernel','bin', 'modelfname','list'};

%=== Defaults
list = fullfile('..','Data','list.txt');
datapath = fullfile('..','Data');
modelfname = fullfile('..','Data','pdbmodel.mat');
outpath = datapath;
if ~exist(outpath,'dir')
    mkdir(outpath);
end

ext = ''; %'.pdb'; % extension of the pdb files 
kernel =  fspecial('gaussian') ; % ones(3, 3) / 9; % 3x3 mean kernel
bin = 20; % width of histogram bins in angles


for j=1:2:nargin
    [k, pval] = pvpair(varargin{j}, varargin{j+1}, okargs, mfilename);
    switch(k)
        case 1 % 
            datapath = pval;
            
        case 2 % 
           outpath = pval;
            
        case 3 % 
            ext = pval;
            
        case 4 % 
            kernel = str2num(pval);
            
        case 5 % 
           bin = str2num(pval); 
            
        case 6 %
           modelfname = pval;  
           
        case 7 %
           list = pval;              
    end
end
