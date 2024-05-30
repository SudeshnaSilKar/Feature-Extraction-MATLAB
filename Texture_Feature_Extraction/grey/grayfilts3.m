function [grayfeats,feat_names] = grayfilts3(vol,WindowSize)
% Calculate gray-level features using 3D window
% [grayfeats,feat_names] = grayfilts3(vol,WindowSize)

warning('Still testing for potential error with: medfilt3mex, stdfilt3mex, rangefilt3mex');

[height, width, planes] = size(vol);

if numel(WindowSize)==1, WindowSize=WindowSize([1 1 1]); end
if numel(WindowSize)~=3, error('WindowsSize must be 1 or 3 elements.'); end

nfeatures=4;
grayfeats=zeros(height, width, planes, nfeatures,class(vol));

% Extract features
fprintf('Calculating Mean Image.\n');
grayfeats(:,:,:,1) = meanfilt3(vol,WindowSize);

fprintf('Calculating Median Image.\n');
if isa(vol,'single')
    vold=double(vol);
%     tempfeat = medfilt3mexmt(vold,WindowSize);
%     tempfeat = medfilt3mex(vold,WindowSize); %Doesn't compute correctly when window extends beyond image borders. 
    tempfeat = medfilt3(vol,WindowSize); %limitation: pads array with mirror reflections of itself 
    grayfeats(:,:,:,2) = single(tempfeat);
else
%     grayfeats(:,:,:,2) = medfilt3mexmt(vol,WindowSize);
%     grayfeats(:,:,:,2) = medfilt3mex(vol,WindowSize);  %Doesn't compute correctly when window extends beyond image borders. 
      grayfeats(:,:,:,2) = medfilt3(vol,WindowSize);  %limitation: pads array with mirror reflections of itself 

end

fprintf('Calculating Standard Deviation Image.\n');
if isa(vol,'single')
    vold=double(vol);
%     tempfeat = stdfilt3mexmt(vold,WindowSize);
    tempfeat = stdfilt3mex(vold,WindowSize);
    grayfeats(:,:,:,3) = single(tempfeat);
else
%     grayfeats(:,:,:,3) = stdfilt3mexmt(vol,WindowSize);
    grayfeats(:,:,:,3) = stdfilt3mex(vol,WindowSize);
end

fprintf('Calculating Range Image.\n');
if isa(vol,'single')
    vold=double(vol);
%     tempfeat = rangefilt3mexmt(vold,WindowSize);
    tempfeat = rangefilt3mex(vold,WindowSize);
    grayfeats(:,:,:,4) = single(tempfeat);
else
%     grayfeats(:,:,:,4) = rangefilt3mexmt(vol,WindowSize);
    grayfeats(:,:,:,4) = rangefilt3mex(vol,WindowSize);
end

feat_names = {'Gray mean','Gray median','Gray std_dev','Gray range'};

end

% Filter subroutines
function Y = meanfilt3(vol,WindowSize)

mask = repmat(1/prod(WindowSize),WindowSize);
Y = convn(vol,mask,'same');

end
