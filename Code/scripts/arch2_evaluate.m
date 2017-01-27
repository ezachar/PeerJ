function acc = arch2_evaluate(outpath)
%  acc = arch2_evaluate(outpath)
% It merges the features from each Convolution Neural Network and performs classification 
% using either SVM (linear and rbf) or kNN

netfnames=[{'angles0Dropout0relu1'}, {'angles1Dropout1relu1'}];  
imdbPath = fullfile(outpath,'..','..','Data');
iter = 0 ;
retrain = 1; % 0 if you want to use precalculated results

for i=1:length(netfnames)
    clear imdb net indtrain indtest

    netfname = netfnames{i};      
    angles = netfname(7); % string = '0' or '1'      
    load(fullfile(imdbPath,['imdb_' angles '.mat']), 'imdb') ; 
    imdb1 = imdb;
    indtrain = imdb.images.set == 1;
    indtest = imdb.images.set == 3;
    
    if str2num(angles)==0, 
        numNetworks = 8; 
    else
        numNetworks = 23;
    end
    outpaths = cell(numNetworks,1);
    for n=1:numNetworks
        outpaths{n}=fullfile(outpath,netfname, ['c' num2str(n)]);
    end

    for n=1:numNetworks        
        iter = iter +1;
        clear  imdb net   
        imdb = imdb1;
        imdb.images.data = imdb1.images.data(:,:,n,:);
        imdb.images.data_mean = imdb1.images.data_mean(:,:,n);

        %% Network initialization  
        load(fullfile(outpaths{n}, 'options.mat'), 'opts') ;
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

end
save(fullfile(outpath, ['FY_fold' num2str(opts.fold) '_arch2.mat']),'F_train','Y_train','F_test','Y_test');

%% Perform classification based on different fusion schemes
disp('************************************************************'); disp(' ');
acc = compareClassifiers(F_train, Y_train, F_test, Y_test);







 

