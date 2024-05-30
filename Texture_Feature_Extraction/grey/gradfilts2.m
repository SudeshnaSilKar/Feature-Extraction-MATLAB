function [gradfeats, feat_names] = gradfilts2(img)
% function gradfeats = gradfilts2(img)
% Calculate gradient features and gradient-like kernel filter operations (Sobel/Kirsch etc).
% IMG can only be a 2D matrix
% Satish Viswanath, Jul 2008
% Updated to use GRADFILTS3 as template, Jul 2013
% Jacob Antunes, Mar 2018
% Updated to reflect correct names. No longer using Kirsch kernels.
% see also: gradfilts3.m

[height, width, planes] = size(img);
if planes > 1, error('only 2D image supported, else see GRADFILTS3'); end

feat_names = {'Gradient sobelx','Gradient sobely','Gradient sobelxy','Gradient sobelyx','Gradient x','Gradient y','Gradient magnitude','Gradient dx','Gradient dy','Gradient diagonal'};

nfeatures=length(feat_names);
gradfeats=ones(height, width, nfeatures,class(img));

fprintf('Calculating x,y Sobel edge images.\n');
gradfeats(:,:,1) = sobelx(img);
gradfeats(:,:,2) = sobely(img);

fprintf('Calculating diagonal Sobel edge images.\n');
gradfeats(:,:,3) = sobelxydiag(img);
gradfeats(:,:,4) = sobelyxdiag(img);

fprintf('Calculating directional and magnitude gradients.\n');
[gradfeats(:,:,5),gradfeats(:,:,6)] = gradient(img);
gradfeats(:,:,7)=sqrt(gradfeats(:,:,5).^2 + ... 
    gradfeats(:,:,6).^2);
gradfeats(:,:,8)=dx(img);
gradfeats(:,:,9)=dy(img);
gradfeats(:,:,10)=ddiag(img); 

% gradfeats(:,:,5) = Get_Kirsch_1(img);
% gradfeats(:,:,6) = Get_Kirsch_2(img);
% gradfeats(:,:,7) = Get_Kirsch_3(img);


%% ******************************************************

function Y = sobelx(img)

sobel = [-1 0 1;-2 0 2;-1 0 1];
Y = conv2(img,sobel,'same');

%% -------------------------------------------------------------------------

function Y = sobely(img)

sobel = [1 2 1; 0 0 0; -1 -2 -1];
Y = conv2(img,sobel,'same');

%% -------------------------------------------------------------------------

function Y = sobelxydiag(img)

sobel = [0 1 2; -1 0 1; -2 -1 0];
Y = conv2(img,sobel,'same');

%% -------------------------------------------------------------------------

function Y = sobelyxdiag(img)

sobel = [0 1 2; -1 0 1; -2 -1 0];
sobel=flipdim(sobel,2);
Y = conv2(img,sobel,'same');

%% -------------------------------------------------------------------------

function Y = Get_Kirsch_1(img)

sobel = [3 3 3;3 0 3; -5 -5 -5];
Y = conv2(img,sobel,'same');

%% -------------------------------------------------------------------------

function Y = Get_Kirsch_2(img)

sobel = [-5 3 3;-5 0 3; -5 3 3];
Y = conv2(img,sobel,'same');

%% -------------------------------------------------------------------------

function Y = Get_Kirsch_3(img)

sobel = [3 3 3;-5 0 3; -5 -5 3];
Y = conv2(img,sobel,'same');

%% -------------------------------------------------------------------------

function Y = dx(img)

mask = [-1 1];
Y = conv2(img,mask,'same');

%% -------------------------------------------------------------------------

function Y = dy(img)

mask = [-1; 1];
Y = conv2(img,mask,'same');

%% -------------------------------------------------------------------------

function Y = ddiag(img)

mask = [-1 0;0 1];
Y = conv2(img,mask,'same');