arch=2;

EC = [{'EC3'},{'EC5'},{'EC6'},{'EC4'},{'EC1'},{'EC2'}];
numClasses = numel(EC);
allROC = [];
accuracy=zeros(5,2);

for fold=1:5
        
    if arch==1  %% Architecture 1
        load(['/home/eva/Work/CNN/results/perResidueNoRep/crossval_clearNoRep/fold' num2str(fold) '/FYall_fold' num2str(fold) '.mat'],'F_train','Y_train','F_test','Y_test');
        % USE NETWORKS 2 and 8 (angles0Dropout0relu1 & angles1Dropout1relu1)
        Ftrain=F_train(:,[7:12, 43:48]);  Ftest=F_test(:,[7:12, 43:48]); 
        
    else        %% Architecture 2
        load(['/home/eva/Work/CNN/results/perResidueNoRep/crossval_perChannel/fold' num2str(fold) '/angles0Dropout0relu1/FYall_fold' num2str(fold) '.mat'],'F_train','Y_train','F_test','Y_test');
        Ftrain = F_train;
        Ftest = F_test;       
        load(['/home/eva/Work/CNN/results/perResidueNoRep/crossval_perChannel/fold' num2str(fold) '/angles1Dropout1relu1/FYall_fold' num2str(fold) '.mat'],'F_train','Y_train','F_test','Y_test');
        Ftrain = [Ftrain F_train];
        Ftest = [Ftest F_test];      
    end
    
    [accuracy(fold,:), roc] = compareClassifiers(Ftrain, Y_train, Ftest, Y_test);
    allROC =[allROC; roc];  
    clear Ftrain F_train Y_train Ftest F_test Y_test 
end

f=figure;
for c=1:numClasses
    class= EC{c};
    fp=[];
    tp=[];
    AUC = zeros(5,1);
    for fold=1:5
        fp = [fp ; allROC(fold,c).fp];
        tp = [tp ; allROC(fold,c).tp];
        AUC(fold) = allROC(fold,c).auc;
    end    
    [fp,ind1]=sort(fp);
    tp = tp(ind1); clear ind1
    
    [ufp, ~, ind2] =uniquetol(fp, 0.01);    
    utp = zeros(size(ufp));   
    for i=1:numel(ufp)   
        utp(i) = mean(tp(ind2==i));
    end
    
    cl = str2num(class(end));
    h=subplot(2,3,cl);  plot(ufp,utp,'LineWidth',3);
    xlabel('False positive rate','FontSize',10)
    ylabel('True positive rate','FontSize',10)
    title(class); 
   
    t = annotation('textbox','FontSize',12,'LineStyle','none','VerticalAlignment','bottom','FitBoxToText','on');
    t.String = ['AUC = ' sprintf('%.2f', mean(AUC))];
    p = get(h,'pos'); % get position of axes
    t.Position = p + [0.1 0 0 0];
    disp('');
end
% print(f,['ROC_arch' num2str(arch)],'-dpng')

    
    
