function bifImage = mtBifs(inputImage, blurWidth, flatnessThreshold)

% Return invalid BIFs at all image pixels
bifImage = -1 * ones(size(inputImage));