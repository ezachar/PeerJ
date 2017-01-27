function [LABELS] = FindLabels(Y)
% function [LABELS] = FindLabels(Y)
% Y:    vector nx1 or 1xn where n the number of samples
% The 1xc vector LABELS shows what are the different labels included in Y,
% where c is the number of labels. 
% If Y is numeric the labels will be sorted, e.g. LABELS = [2 3 5]
% otherwise sorting is not possible, e.g. LABELS = ['yes' 'no']
% 
% Create by E.Zacharaki, UPENN-SBIA



numSamples=length(Y);	% e.g. subjects

numClasses=1;
if isnumeric(Y) % this calculation is faster
    Ys=sort(Y);    
    LABELS(numClasses)=Ys(1);
    for i=2:numSamples
        if Ys(i)~=LABELS(numClasses)     
            numClasses=numClasses+1;
            LABELS(numClasses)=Ys(i);        
        end
    end
    clear Ys

else
    Ys=sort(Y);    
    LABELS(numClasses)=Ys(1);
    for i=2:numSamples
        if ~ismember(Ys(i),LABELS)      
            numClasses=numClasses+1;
            LABELS(numClasses)=Ys(i);        
        end
    end
    clear Ys       
end

