function [ Xtrain, Ytrain, Xtest, Ytest, varargout ] = sampleTrainAndTestData( X, Y, p )
% [ Xtrain, Ytrain, Xtest, Ytest ] = sampleTrainAndTestData( X, Y, p)
% X: data matrix [numSamples x numFeatures]
% y: vector with class labels
%
% The data is split into train and test without balancing the classes
% For test p*100% number of samples are retained and for train (1-p)*100%.
% 
% Optional output:
% [..., indtrain, indtest ] = sampleBalancedTrainAndTestData( X, Y, p)
% indtrain, indtest: indices to rows of X for train and test samples respectively
%                    
% 
% 


rng('default');
rng(0) ;
[X, Y] = shuffle_data(X, Y);

numSamples = numel(Y);    
numtest = round(p*numSamples);
numtrain = numSamples-numtest;
indtrain = [1:numtrain];
indtest = [numtrain+1:numSamples];

Xtrain = X(indtrain,:);
Ytrain = Y(indtrain); 
Xtest = X(indtest,:);  
Ytest = Y(indtest);
if nargout>4
    varargout{1} = indtrain;
end
if nargout>5
    varargout{2} = indtest;
end


end

