%% demo_feature_extraction_3D_isovolumes_script
% Jacob Antunes 
% April 5, 2017

%% About
% extract 3D features from patient data
% framework can be easily adapted to other datasets
% see extract3DFeatureInfo.m

%*********************************NOTE:************************************
% Data should already be isotropic (same resolution in x, y and z!
% Otherwise, it doesn't make sense to implement 3D feature extraction, but
% instead, extract 2D features per slice (see extractFeatureInfoPerSlice.m)
%**************************************************************************
%% Setup
clear;clc;close all;

%add necessary pathways to other functions
addpath('G:\Shared drives\INVent\jacob\Code\feature_extraction\subfunctions');

%specify directories from which to load and save
patientdirectory = 'G:\Shared drives\INVent\jacob\Code\feature_extraction\demo_data\3D';
savedirectory = 'G:\Shared drives\INVent\jacob\Code\feature_extraction\demo_data\temp_out';

%specify other parameters
ROI = [1]; %label(s) of which mask values correspond to our region(s) of interest
ws_options = [3, 5, 7, 9, 11]; %window sizes from which to extract features
class_options = {'raw','gray','gradient','haralick','gabor','laws','collage'}; %list of desired feature familes

%% Run Feature extraction Code

if ~isfolder(savedirectory),mkdir(savedirectory); end

files = dir(patientdirectory);
files = files(3:end);

for i = 1:length(files)
    filename = files(i).name(1:end-4);
    fprintf('\n%s\n',filename);
    load(fullfile(files(i).folder,files(i).name),'img','mask');

    %if our mask has multiple labels, isolate just the label(s) we care about
    mask = double(ismember(mask,ROI));
    
    %call feature extraction code
    fprintf('\tCalling Feature Extraction Code\n');
    [featints, featnames, featstats, statnames] = extract3DFeatureInfo(img,mask,class_options,ws_options);
    fprintf('Saving featstats...');
    save(fullfile(savedirectory,[filename '_feats.mat']),'img','mask','featints','featnames','featstats','statnames');
    fprintf('Done.\n');
    
    clear  featints featnames featstats statnames img mask; %reset for next patient
end

fprintf('***COMPLETE***\n')

%% Optional: Visualize our feature maps

addpath('G:\Shared drives\INVent\jacob\Code\feature_extraction\subfunctions');

%we will load in our first patient for demo purposes
files = dir(savedirectory);
files = files(3:end);
load(fullfile(files(1).folder,files(1).name),'img','mask','featints','featnames');

createAndVisualizeFeatMaps(img,mask,featints,featnames);


