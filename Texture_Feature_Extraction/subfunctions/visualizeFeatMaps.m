function visualizeFeatMaps(featImgs,featNames)

if numel(size(featImgs))>3, error('only meant for stack of 2 images!'); end

%GUI objects
figure;
set(gcf,'Color','white');

currslice = 1;
slider = uicontrol('Style', 'slider',...
   'Max',size(featImgs,3),'Min',1,...
   'Units', 'normalized', ...
   'Position', [.25 .005 .4 .04],...
   'SliderStep', [1/(size(featImgs,3)-1) 1/(size(featImgs,3)-1)], ...
   'Value', currslice, ...
   'Callback', @move_slider);

text_box = uicontrol('Style', 'text',...
   'Units', 'normalized', ...
   'Position', [.675 .006 .1 .04],...
   'String', [int2str(currslice) ' of ' int2str(length(featNames))]);

set(gcf,'UserData',featImgs);
showmap(currslice, featImgs, featNames);


%callback to slider
function move_slider(~,~)
    currslice = round(get(gcbo,'Value'));
    set(gcbo,'Value',currslice);
    set(text_box,'String',[int2str(currslice) ' of ' int2str(length(featNames))]);
    save_xlim = xlim;
    save_ylim = ylim;

    showmap(currslice,featImgs,featNames);
    xlim(save_xlim);
    ylim(save_ylim);
end

%where the images are displayed 
function showmap(slice,vol,names)
    
    im = vol(:,:,slice);

    if numel(unique(im(:))) == 1 || all(isnan(im(:)))
            imagesc(im);colormap gray;caxis([0 1]); axis image; axis off;hold on;
    else
        imagesc(im);colormap gray;caxis([min(im(:)),max(im(:))]); axis image; axis off;hold on;
    end
    title(names{slice}); hold off;
   
end

end
