function [imdb, fnamestrain, fnamestest] = convertMat2imdb(modelfname, angles, perc_test)
% [imdb, fnamestrain, fnamestest] = convertMat2imdb(modelfname, angles, perc_test)
% perc_test : percentage of samples to be used for testing. Use 0 for training, 
%             1 for testing and 0.2 for cross-validation

disp('Loading data...');
load(modelfname,'histAngles','contactMaps', 'classes', 'fnames');

if angles
    dim = size(histAngles); % dim(1) = numSamples
    X = reshape(histAngles, dim(1),dim(2)*dim(3)*dim(4)); % the 2nd dimensions is dim(2)*dim(3)*dim(4)
else
    dim = size(contactMaps);
    X = reshape(contactMaps, dim(1),dim(2)*dim(3)*dim(4)); % the 2nd dimensions is dim(2)*dim(3)*dim(4)    
end

disp('Dividing datasets...'); % such that Ytrain=classes(indtrain)    	    
%   [ Xtrain, Ytrain, Xtest, Ytest, indtrain, indtest ] = sampleBalancedTrainAndTestData( X, classes, perc_test);% class labels 1-6
[ Xtrain, Ytrain, Xtest, Ytest, indtrain, indtest ] = sampleTrainAndTestData( X, classes, perc_test);% class labels 1-6   	
if perc_test == 0  % sampleTrainAndTestData required also here b/c it shuffles data        
    Xtest = Xtrain(end,:);  Ytest = Ytrain(end);  indtest = indtrain(end); % use a single sample b/c cnn_train crashes when the 'val' set is empty
    Xtrain(end,:)=[];       Ytrain(end)=[];       indtrain(end)=[];
end

X = [Xtrain; Xtest];
y = [Ytrain; Ytest];
dim(1) = length(y);
m_train = size(Xtrain,1);
m_test = size(Xtest,1);

tmp = reshape(X',dim(2),dim(3),dim(4),[]); clear X
if angles % histAngles should become: [numProteins x 19 x 19 x 23]
    data=zeros(dim(3),dim(4),dim(2),dim(1)); 
    for i=1:dim(2), data(:,:,i,:)=tmp(i,:,:,:);end
else % contactMaps remain : [numProteins x 23 x 23 x 8]
    data=tmp;
end
data = single(data);
clear tmp

dataMean =single( mean(data, 4)); % mean(data(:,:,:,set == 1), 4);
data = bsxfun(@minus, data, dataMean) ;
imdb.images.data = data ;
imdb.images.data_mean = dataMean;
imdb.images.labels = y' ; % raw vector
imdb.images.set = [ones(1,m_train) 3*ones(1,m_test)] ; % determines train (value=1) and test (value=3) set
imdb.meta.sets = {'train', 'val', 'test'} ;
imdb.meta.classes = arrayfun(@(x)sprintf('%d',x),0:5,'uniformoutput',false) ;
fnamestrain = fnames(indtrain);
fnamestest = fnames(indtest);

