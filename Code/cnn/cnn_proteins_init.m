function net = cnn_proteins_init(opts, varargin)
% CNN_MNIST_LENET Initialize a CNN similar for MNIST

% opts.useSPnorm = false ;
% opts.useDropout = false;
opts = vl_argparse(opts, varargin) ;

rng('default');
rng(0) ;

f=1/100 ;
net.layers = {} ;
numLastFilters = 500;
numFilters = 20; % number of filters
numLabels = 6;
if opts.angles
    FD=23;
    pad1=1;
else
    FD = 8; % 1;
    pad1=0;
end

net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(5,5,FD,numFilters, 'single'), zeros(1, numFilters, 'single')}}, ...
                           'stride', 1, ...
                           'pad', pad1) ;
net.layers{end+1} = struct('type', 'bnorm', ...
                            'weights', {{ones(numFilters, 1, 'single'), zeros(numFilters, 1, 'single')}});   
if opts.relu
    net.layers{end+1} = struct('type', 'relu') ;   
end                        
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [2 2], ...
                           'stride', 2, ...
                           'pad', 0) ;
                       
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(5,5,numFilters,50, 'single'),zeros(1,50,'single')}}, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'bnorm', ...
                            'weights', {{ones(50, 1, 'single'), zeros(50, 1, 'single')}});   
if opts.relu
    net.layers{end+1} = struct('type', 'relu') ;   
end                        
                        
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [2 2], ...
                           'stride', 2, ...
                           'pad', 0) ;
                       
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(2,2,50,numLastFilters, 'single'),  zeros(1,numLastFilters,'single')}}, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'bnorm', ...
                            'weights', {{ones(numLastFilters, 1, 'single'), zeros(numLastFilters, 1, 'single')}});
                       
net.layers{end+1} = struct('type', 'relu') ;
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{f*randn(1,1,numLastFilters,numLabels, 'single'), zeros(1,numLabels,'single')}}, ...
                           'stride', 1, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'softmaxloss') ;


% optionally insert Dropout layer
% if opts.Dropout
%   if ~opts.relu
%     net = insertDropout(net, 3) ;  
%     net = insertDropout(net, 7) ;
%     net = insertDropout(net, 11) ; %net = insertDropout(net, 10) ;
%   else
%     net = insertDropout(net, 4) ;  
%     net = insertDropout(net, 9) ;
%     net = insertDropout(net, 14) ;        
%   end
  
if opts.Dropout
  if ~opts.relu    
    net = insertDropout(net, 6) ;
    net = insertDropout(net, 10) ;
  else    
    net = insertDropout(net, 7) ;
    net = insertDropout(net, 12) ;        
  end
end





% --------------------------------------------------------------------
function net = insertSPnorm(net, l)
% --------------------------------------------------------------------
assert(isfield(net.layers{l}, 'weights'));
layer = struct('type', 'spnorm', 'param', [2 2 1 2]) ;
net.layers = horzcat(net.layers(1:l), layer, net.layers(l+1:end)) ;


% --------------------------------------------------------------------
function net = insertDropout(net, l)
% --------------------------------------------------------------------
layer = struct('type', 'dropout','rate', 0.2) ; %0.5
net.layers = horzcat(net.layers(1:l), layer, net.layers(l+1:end)) ;

