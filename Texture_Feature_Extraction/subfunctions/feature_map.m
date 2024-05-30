function [] = feature_map(varargin)
% Function for visualizing feature heatmaps overlaid onto imaging data

% POSSIBLE INPUTS
%       1- img: 2D slice or 3D imgume of interest
%       2- mask: corresponding label mask for img
%       3- featvec: 1D vector of feature values extracted within mask
%       OR
%       2- featimg: corresponding feature map corresponding to img
%

% example calls:
%   feature_map(img,mask,featints)
%   OR
%   feature_map(img,featimg)

%% check inputs
if nargin > 3
    error('Too many inputs.');
end

if nargin == 3
    img = varargin{1};
    mask = varargin{2};
    featvec = varargin{3};
    if ~all(ismember(size(img),size(mask)))
        error('Size of MASK must equal size of IMG');
    end
    if length(featvec)~=length(find(mask>0))
        error('Length of FEATINTS must equal nonzero pixels in MASK');
    end
    featimg = createFeatVol(featvec,mask);
end

if nargin == 2
    img = varargin{1};
    featimg = varargin{2};
    if ~all(ismember(size(img),size(featimg)))
        error('Size of FEATVOL must equal size of IMG');
    end
    mask = [];
end

ndims = numel(size(img));

if ndims == 2 %must make 3D, for now
    img = repmat(img,[1 1 2]);
    mask = repmat(mask,[1 1 2]);
    featimg = repmat(featimg,[1 1 2]);
end

% Set all feature values > 95th percentile to that value - helps remove
% border intensities driving signal
v95 = prctile(featimg(~isnan(featimg)),98);
featimg(featimg>v95) = v95;
% and all things less than 5th percentile to that value
v5 = prctile(featimg(~isnan(featimg)),2);
featimg(featimg<v5) = v5;

% % Set all feature values beyond 3 stdev away from mean feature value to the
% % 3 stdev cutoffs; helps remove border of ROI from driving signal
% mv = mean(featimg(~isnan(featimg)));
% sv = std(featimg(~isnan(featimg)));
% featimg(featimg>mv+3*sv) = mv+3*sv;
% featimg(featimg<mv-3*sv) = mv-3*sv;

%Display map
fprintf('\tDisplaying Overlaid Map\n')
my4DMap(img,featimg,mask);

end

%GUI objects
function my4DMap(img,featimg,mask)
    maskcopy = mask;
    figure('Color','white');
    
    rotbox = uicontrol('Style','pushbutton','String','Transpose?','Units','normalized','Position',[0.48 0.8 .12 .05],'Callback',@rotatebox);
    
    if ~isempty(mask)
        showmask = uicontrol('Style','pushbutton','String','Hide Mask?','Units','normalized','Position',[0.048 0.8 .12 .05],'Callback',@changemask);
    end
    
    if isempty(find(isnan(featimg),1))
        begin_index = find(featimg>0,1,'first');
        end_index = find(featimg>0,1,'last');
    else
        begin_index = find(~isnan(featimg),1,'first');
        end_index = find(~isnan(featimg),1,'last');
    end
    [~,~,begin_slice] = ind2sub(size(featimg),begin_index);
    [~,~,end_slice] = ind2sub(size(featimg),end_index);
    slice = floor((end_slice+begin_slice)/2);
    
    slider = uicontrol('Style', 'slider',...
       'Max',size(img,3),'Min',1,...
       'Units', 'normalized', ...
       'Position', [.25 .005 .4 .04],...
       'SliderStep', [1/(size(img,3)-1) 1/(size(img,3)-1)], ...
       'Value', slice, ...
       'Callback', @move_slider);
    
    text_box = uicontrol('Style', 'text',...
       'Units', 'normalized', ...
       'Position', [.675 .006 .04 .04],...
       'String', num2str(slice));
   
    set(gcf,'UserData',featimg);
    showmap(slice, img, featimg,maskcopy);

%callback to rotatebox
function rotatebox(~,~)
   img = permute(img,[2 1 3]);
   featimg = permute(featimg,[2 1 3]);
   maskcopy = permute(maskcopy,[2 1 3]);
   showmap(slice, img, featimg,maskcopy);
end

%callback to changemask
function changemask(~,~)
   if strcmp(get(showmask,'String'),'Hide Mask?')
      set(showmask,'String','Show Mask?');
      maskcopy = [];
   else
      set(showmask,'String','Hide Mask?');
      maskcopy = mask;
   end
   showmap(slice, img, featimg,maskcopy);
end

%callback to slider
function move_slider(~,~)
slice = round(get(gcbo,'Value'));
set(gcbo,'Value',slice);
set(text_box,'String',num2str(slice));
save_xlim = xlim;
save_ylim = ylim;
showmap(slice,img,featimg,maskcopy);
xlim(save_xlim);
ylim(save_ylim);
end

end

%where the images are displayed 
function showmap(slice,imgdata,featdata,mask)

    %----original img + annotation-----%
    subplot(1,2,1);
    cla;
    if ~isempty(mask)
        maskslice = mask(:,:,slice);
        [dx,dy] = gradient(maskslice);
        edgei=sqrt(dx.^2+dy.^2);
        edgei=edgei~=0;
        imagesc(rgbmaskrgb(rescale(imgdata(:,:,slice)),edgei,[0 1 0]));colormap gray; axis off;
    else
        imagesc(imgdata(:,:,slice));colormap gray;axis off;
    end
    axis image
    title([ 'slice ' num2str(slice) ' of ' num2str(size(imgdata,3))])

    %----overlay of feature map onto img------%
    subplot(1,2,2);
    cla;colorbar off;
    imgslice = imgdata(:,:,slice);
    featslice = featdata(:,:,slice);
   
    imgslice = imgslice/max(imgslice(:));
    rgbslice = imgslice(:,:,[1 1 1]);

    bwROIlocations = ~isnan(featslice);
    g = imagesc(featslice);
    colormap(gca,'jet'); c = colorbar('south');
    c.Color = 'w'; c.FontSize = 12;
    
    alpha(g,1); 
    hold on; h = imagesc(rgbslice);
    set(h,'AlphaData',~bwROIlocations);
    axis image
    axis off
    title([ 'slice ' num2str(slice) ' of ' num2str(size(imgdata,3))])

end



