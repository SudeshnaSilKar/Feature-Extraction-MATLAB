function createAndVisualizeFeatMaps(img,roi,featVecs,featNames)

%check inputs
if nargin==4 && ~isempty(featNames) &&  length(featNames)~=size(featVecs,2), error('Length of FEATNAMES must equal number of cols of FEATVEC'); end
if ~all(size(img)==size(roi)), error('IMG and ROI must have same number of dimensions'); end

nFeats = length(featNames);
featImgs = createFeatVols(featVecs,roi);

%GUI objects
figure;
set(gcf,'Color','white');

currSlice = round(size(roi,3)/2);
currFeat = 1;

slider_feats = uicontrol('Style', 'slider',...
   'Max',size(featImgs,4),'Min',1,...
   'Units', 'normalized', ...
   'Position', [.25 .005 .4 .04],...
   'SliderStep', [0 0.5], ...
   'Value', currFeat, ...
   'Callback', @move_slider_feats);
% slider_feats = uicontrol('Style', 'slider',...
%    'Max',size(featImgs,4),'Min',1,...
%    'Units', 'normalized', ...
%    'Position', [.25 .005 .4 .04],...
%    'SliderStep', [1/(size(featImgs,4)-1) 1/(size(featImgs,4)-1)], ...
%    'Value', currFeat, ...
%    'Callback', @move_slider_feats);

text_box_feats = uicontrol('Style', 'text',...
   'Units', 'normalized', ...
   'Position', [.675 .006 .3 .04],...
   'String', ['Feature ' int2str(currFeat) ' of ' int2str(length(featNames))]);

if size(featImgs,3) > 1
    slider_slices = uicontrol('Style', 'slider',...
       'Max',size(featImgs,3),'Min',1,...
       'Units', 'normalized', ...
       'Position', [.05 .25 .04 .4],...
       'SliderStep', [1/(size(featImgs,3)-1) 1/(size(featImgs,3)-1)], ...
       'Value', currSlice, ...
           'Callback', @move_slider_slices);
    text_box_slices = uicontrol('Style', 'text',...
       'Units', 'normalized', ...
       'Position', [.05 .675 .1 .1],...
       'String', ['Slice ' int2str(currSlice) ' of ' int2str(size(featImgs,3))]);
end

set(gcf,'UserData',featImgs);
showmap(currSlice, currFeat, img,featImgs, featNames);

%callback to sliders
function move_slider_feats(~,~)
    currFeat = round(get(gcbo,'Value'));
    set(gcbo,'Value',currFeat);
    set(text_box_feats,'String',['Feature ' int2str(currFeat) ' of ' int2str(length(featNames))]);
    save_xlim = xlim;
    save_ylim = ylim;

    showmap(currSlice,currFeat,img,featImgs,featNames);
    xlim(save_xlim);
    ylim(save_ylim);
end
function move_slider_slices(~,~)
    currSlice = round(get(gcbo,'Value'));
    set(gcbo,'Value',currSlice);
    set(text_box_slices,'String',['Slice ' int2str(currSlice) ' of ' int2str(size(featImgs,3))]);
    save_xlim = xlim;
    save_ylim = ylim;

    showmap(currSlice,currFeat,img,featImgs,featNames);
    xlim(save_xlim);
    ylim(save_ylim);
end

%where the images are displayed 
function showmap(slice,featID,imgdata,featdata,names)
    imslice = imgdata(:,:,slice);
    fslice = featdata(:,:,slice,featID);

    imslice = imslice/max(imslice(:));
    rgbslice = imslice(:,:,[1 1 1]);
    
    bwROIlocations = ~isnan(fslice);
    
    if numel(unique(fslice(:))) == 1 || all(isnan(fslice(:)))
        g = imagesc(fslice);colormap jet;caxis([0 1]); axis image; axis off;hold on;
    else
        g = imagesc(fslice);colormap jet;caxis([min(fslice(:)),max(fslice(:))]); axis image; axis off;hold on;
    end
    title(names{featID}); 
    h = imagesc(rgbslice);
    set(h,'AlphaData',~bwROIlocations);
    axis image
    axis off
    hold off;
   
end

end
