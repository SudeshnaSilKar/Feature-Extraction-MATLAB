%% Test code for feature extraction functions

close all;clear;clc;

% parameters to set
class_options = {'collage'};
%class_options = {'collage','haralick','gabor'}; %{'raw','gray','gradient','haralick','gabor','laws','collage'}; %(optional) feature classes to extract
%ws_options = 3:5;%:2;11; %(optional) window sizes from which to extract
ws_options=3;
% addpath('G:\Team Drives\INVent\jacob\Code\images');
% addpath('G:\Team Drives\INVent\jacob\Code\mha');

%% 2D
rng(0);
% ** TEST CASE ONE **
% img = wgn(100,100,0);
% mask = nan(100);
% mask(30:70,30:70) = 1;
% figure;imshow(img);
% figure;imshow(mask);

% ** TEST CASE TWO **
% img = rand(3,3);
% mask = ones(size(img));


%** TEST CASE THREE **
pic = double(imread('cameraman.tif'));
mask = zeros(size(pic));
mask(30:end-30,30:end-30) = 1;
%vv(pic,mask)
img = pic;
figure;imshow(imread('cameraman.tif'));
figure;imshow(mask);



% ** TEST CASE FOUR**
% img = rand(100,100,5);
% mask = nan(size(img));
% mask(20:40,20:40,2) = 1;
% mask(30:50,30:50,3) = 1;
% mask(40:60,40:60,4) = 1;
% figure;vv(img,mask);

[featints, featnames, featstats, statnames] = extract2DFeatureInfo(img,mask, class_options, ws_options);

maxslice_idx = 1;%findMaxSlice(mask);

featvol = nan(size(mask,1),size(mask,2),length(featints));
for i = 1:length(featints)
    fvol = createFeatVol(featints{i},mask);
    sl = fvol(:,:,maxslice_idx);
    featvol(:,:,i) = sl;
end

figure;
cmap = jet(256);
cmap(1,:) = [0 0 0];
vv(featvol,[],cmap,[0 1]); %each "slice" is a feature from img


%{
%% 3D

rng(0)

% ** TEST CASE ONE **
% vol = rand(100,100,5);
% mask = nan(100,100,5);
% mask(30:70,30:70,2:4) = 1;

% ** TEST CASE TWO **
% vol = rand(3,3,3);
% mask = ones(size(vol));

%** TEST CASE THREE **
pic = double(imread('cameraman.tif'));
% imagesc(pic);colormap('gray');axis image;axis off;
vol = repmat(pic,[1 1 5]);
noisy = rand(size(vol));
vol = vol+noisy;
mask = zeros(size(vol));
mask(30:end-30,30:end-30,1:3) = 1;

addpath('G:\Team Drives\INVent\jacob\Code\images');
addpath('G:\Team Drives\INVent\jacob\Code\mha')

%figure;vv(vol,mask);
    
[featints, featnames, featstats, statnames] = extract3DFeatureInfo(vol,mask,class_options, ws_options);

featvol4d = nan(size(mask,1),size(mask,2),size(mask,3),length(featints));
for i = 1:length(featints)
    temp = nan(size(mask));
    temp(mask>0) = featints{i};
    featvol4d(:,:,:,i) = temp;
end

featvol = squeeze(featvol4d(:,:,3,:));
figure;
cmap = jet(256);
cmap(1,:) = [0 0 0];
vv(featvol,[],cmap,[0 1]); %each "slice" is a feature from slice 3


fID = 2;
figure;feature_map(vol,mask,featints{fID}); % or view the whole volume (slice by slice) for a particular feature
%}