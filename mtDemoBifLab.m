function mtDemoBifLab()
%mtDemoBifLab
% Show BIFs for demonstration images

%% Set image directory
imDir = fullfile('.','images');

%% Car
filename = 'car.jpg';
im = imread(fullfile(imDir,filename));
bifs = mtBifs(im, 2, 0.015);
mtShowCaseBifs(filename,im,bifs,95:120,95:120);

%% Tunnel
filename = 'tunnel.jpg';
im = imread(fullfile(imDir,filename));
bifs = mtBifs(im, 3.5, 0.015);
mtShowCaseBifs(filename,im,bifs,40:75,40:75);