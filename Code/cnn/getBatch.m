function [im, labels] = getBatch(imdb, batch)
% [im, labels] = getBatch(imdb, batch)
% im: [4D single], the last dimension is numSamples
% labels [1 x numSamples]

im = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.labels(1,batch) ;

