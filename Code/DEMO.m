
%% Install MatConvNet and libSVM
addpath(genpath('/home/eva/Software/MatConvNet/matconvnet-1.0-beta13')) 
run vl_setupnn   
addpath(genpath('/home/eva/Software/libsvm-3.20'), '-BEGIN'); 
%% Change to the Code directory and install the provided software
addpath(genpath(pwd)); 


%% Feature extraction
% For demo purposes a list is provided that includes only 20 proteins randomly selected from each class (list-example.txt). 
% If you want to reproduce the results of the paper you have to train the model using list_peerj.txt, but feature extraction and training will take long in this case.
rootpath = pwd;
modelfname = fullfile(rootpath,'..','Data','pdbmodel_demo.mat'); 
list = fullfile(rootpath,'..','Data','list_demo.txt');
ramtrainPerResidue('list',list, 'modelfname', modelfname);

%% Calculate the CNN by using 80% of the data for training and 20% for testing
% If you want the options of PeerJ paper, open cnn_protein.m and change first the option "demo = 1" to 0. 
% This option was used to speed up calculations in this DEMO. Also when 'list_demo.txt' is used with only 
% 120 samples, we cannot use the default option with batchSize = 1000.

fold = 1; % one out of 5 folds (80% training, 20% testing)
outpath = fullfile(rootpath,'..','Results','fold1');

%% Train 2 networks according to Architecture1
opts = run_cnn_proteins(modelfname,fold,1);

%% Fuse the networks and assess classification accuracy on the test set
% outpath = fullfile(opts.expDir,'..');  
acc = arch1_evaluate(outpath);


%% Train 2 networks according to Architecture2
opts = run_cnn_proteins(modelfname,fold,2); % outpath = fullfile('..','Results','fold1');

%% Fuse the networks and assess classification accuracy on the test set
% outpath = fullfile(opts.expDir,'..','..'); % 
acc = arch2_evaluate(outpath);



