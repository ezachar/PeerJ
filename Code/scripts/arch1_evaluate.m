function acc = arch1_evaluate(outpath)
%  acc = arch1_evaluate(outpath)
% It merges the features from all Convolution Neural Networks and performs classification 
% using either SVM (linear and rbf) or kNN


netfnames=[{'angles0Dropout0relu1'}, {'angles1Dropout1relu1'}];       
iter = 0 ;
retrain = 1; % 0 if you want to use precalculated results

for i=1:length(netfnames) 
    iter = iter +1;
    clear imdb net indtrain indtest

    netfname = netfnames{i};      
    angles = netfname(7); % string = '0' or '1'      
    load(fullfile(outpath, netfname,'options.mat'), 'opts') ;
    load(fullfile(opts.imdbPath,['imdb_' angles '.mat']), 'imdb') ;  
    indtrain = imdb.images.set == 1;
    indtest = imdb.images.set == 3;

    %% Network initialization  
    load(fullfile(opts.train.expDir, ['net-epoch-' num2str(opts.train.numEpochs) '.mat'])); % net, info loaded
    %vl_simplenn_display(net, 'batchSize', opts.train.batchSize) ;
    net.layers{end}.type = 'softmax'; % 'softmax', 'relu', 'sigmoid' % net.layers(end)=[];   

    %% Network evaluate on test data   
    res_test = vl_simplenn(net, imdb.images.data(:,:,:,indtest), [], [], 'accumulate', false, 'disableDropout', true) ;    
    features_test = double((squeeze(res_test(end).x))'); % [numSamples x 6]      
    features_test  = double(features_test);
    Y_test = double(imdb.images.labels(indtest))';

    % Fuse features from each network    
    if iter==1, F_test  = features_test; 
    else        F_test  = [F_test  features_test ]; 
    end        

    %% Network evaluate on train data
    if retrain         
        res_train = vl_simplenn(net, imdb.images.data(:,:,:,indtrain), [], [], 'accumulate', false, 'disableDropout', true) ;
        features_train = double((squeeze(res_train(end).x))'); % [numSamples x 6]   
        features_train = double(features_train);
        Y_train = double(imdb.images.labels(indtrain))';

        % Fuse features from each network    
        if iter==1,  F_train = features_train;              
        else         F_train = [F_train features_train];                
        end           
    end


end
save(fullfile(outpath, ['FY_fold' num2str(opts.fold) '_arch1.mat']),'F_train','Y_train','F_test','Y_test');

%% Perform classification based on different fusion schemes
disp('************************************************************'); disp(' ');
acc = compareClassifiers(F_train, Y_train, F_test, Y_test);





 

