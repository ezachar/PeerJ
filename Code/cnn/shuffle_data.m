function [Xo, Yo, varargout] = shuffle_data(X, Y)
% [Xo, Yo]          = shuffle_data(X, Y)
% [Xo, Yo, indices] = shuffle_data(X, Y)
% Shuffle data to avoid ordering
%   X: first data set to shuffle the rows of
%   Y: second data set to shuffle the rows of, keeping the corresponding rows 
%      in X and Y aligned
%   indices: indicating the rows picked from X (optional output) 


    indices = randperm(size(X, 1));
    Xo = X(indices, :);
    Yo = Y(indices, :);
    if nargout>2
        varargout{1} = indices;
    end
    
end
