function [acc, roc] = compareClassifiers(F_train, Y_train, F_test, Y_test)
% acc = compareClassifiers(F_train, Y_train, F_test, Y_test)
% It performs classification based on 7 different fusion schemes
% 1) linear-SVM on 48 features 2) nearest neighbor


numClassifiers = 2;
acc = zeros(numClassifiers,1);
EC = [{'EC3'},{'EC5'},{'EC6'},{'EC4'},{'EC1'},{'EC2'}];


K=12;
[pred, scores] = knnclassify1(F_test, F_train, Y_train,K,'spearman'); % the column order in scores corresponds to labels 1 to 6. 
            % if the labels are not numeric and continuous and starting from 1, use grp2idx for sorting and indexing
scores = scores/K;
acc(1) = 100*sum(pred==Y_test)/length(pred);

if nargout>1
%     labels = FindLabels(Y_train);
    [Y,labels] = grp2idx(Y_train);    
    labels = str2num(char(labels));
    if sum(abs(Y-Y_train))~=0  
        error(['Labels need conversion from 1 to ' num2str(numel(labels))]); 
    end
    clear Y
    
    for c=1:numel(labels)       
        posclass = labels(c);
        try
            [fp,tp,~,auc] = perfcurve(Y_test==posclass,  scores(:,labels==posclass), 1);
            plot(fp,tp);
            xlabel('False positive rate')
            ylabel('True positive rate')
            title(['ROC for ' EC{c}])
            roc(c).fp=fp;
            roc(c).tp=tp;   
            roc(c).auc = auc;
            clear fp tp
        catch
           disp(['Class ' num2str(posclass) ' was not found']) 
        end
    end  
end

% model = svmtrain(Y_train, F_train, ' -s 0 -t 0 -c 1 -q ');          % model = svmtrain(Y_train, F_train, ' -s 0 -t 0 -c 1 -q -b 1'); 
% [~, accuracy, ~] = svmpredict(Y_test, F_test, model);      % [~, accuracy, scores] = svmpredict(Y_test, F_test, model, '-b 1');
% acc(2)= accuracy(1);

disp([num2str(K) 'NN:' num2str(acc(1)) '%     SVM  : '  num2str(acc(2)) '%']);
disp(' ');



