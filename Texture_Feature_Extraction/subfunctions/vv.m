function [vol_out, mask_out, vol_info, mask_info] = vv(vol_in,mask_in,cmap,coloraxis)
%  Volume Viewer, for loading in / displaying image & mask data

% INPUTS
%
% vol_in    = (optional) either a 3D matrix or string containing pathway to a
%            file of a 3D volume (either in .mha or .mat format). If empty, user will manually be able to select a file.
% mask_in   = (optional) either a 3D label matrix corresponding to vol or string containing pathway
%             to a mha file of the corresponding 3D mask.
% cmap      = (optional) 1D vector specifying the colormap to represent the
%            heatmap as. If 1 indicated, default is jet(128) with
%            Nans as black. Otherwise, a 1D colormap vector may be
%            supplied. Colorbar displayed as well. If left blank, no
%            heatmap will be displayed.
% coloraxis = (optional) = 2 element vector specifying the min and max
%             limits of the color display, in the format coloraxis = [min max].
%             Default is the min and max of the current slice displayed (essentially calls "caxis.m").

% OUTPUTS
%
% vol_out = (otpional) 3D matrix representation of volume file
%
% mask_out = (optional) 3D matrix representation of corresponding matrix file
% 
% vol_info = (optional) struct of volume information of vol_in
%
% mask_info (optional) struct of volume information of mask_in
%

% Jacob Antunes
% 20170109

%% Example Calls
%{
1) vol = vv(); <-- manually select vol file. loads in vol matrix. displays vol.
2) vol = vv(datapath); <-- loads in vol matrix.
3) [vol, mask] = vv(datapath, maskpath); <--loads in vol and mask matrices.
6) vv(vol); <-- displays vol
6) vv(vol,mask); <-- displays vol overlaid with mask 
7) vv(vol,[],cmap); %<--represents volume as a heatmap
8) vv(vol,[],cmap,coloraxis); %<--represents volume as a heatmap with optimal display parameters
%}



%%
if exist('mha_read_header.m','file')~=2
    error('Get mha_read_header.m into your path!');
end

if exist('mha_read_volume.m','file')~=2
    error('Get mha_read_volume.m into your path!');
end

%% loading data
if nargin == 0 %default. loading in volume file
    dir = cd();
    [file, path, ~] = uigetfile({'*.mha','Pick an MHA file.';'*.mat', 'Pick a MATRIX file.'});
    if isa(file,'char')
        vol_info = mha_read_header([path, file]);
        vol_out = cast(mha_read_volume(vol_info),'double');
        mask_out = [];mask_info = [];
    else
        vol_out = load([path, file]);vol_info = [];
        mask_out = [];mask_info = [];
    end
    cd(dir);%specific for uh_rectal_radiology project
    return
end


if nargin == 1 && ischar(vol_in) %if vol is actually the path to the file, load it.
    if exist(vol_in,'file')~=2
        error(['The file "' vol_in '" cannot be found in current path']);
    end
    vol_info = mha_read_header(vol_in);
    vol_out = cast(mha_read_volume(vol_info),'double');
    mask_out = [];mask_info = [];
    return
end


if nargin == 2 && ischar(vol_in) && ischar(mask_in) %if vol, mask are actually the path to the file, load them.
    if exist(vol_in,'file')~=2
        error(['The file "' vol_in '" cannot be found in current path']);
    end
   
    if exist(mask_in,'file')~=2
        error(['The file "' mask_in '" cannot be found in current path']);
    end
    
    vol_info = mha_read_header(vol_in);
    vol_out = cast(mha_read_volume(vol_info),'double');
    mask_info = mha_read_header(mask_in);
    mask_out = cast(mha_read_header(mask_info),'double');
    return
end

%% displaying data

if nargout == 0 && nargin == 1
    if numel(size(vol_in)) == 2 %prevent crashing if 2D image
        [a,b] = size(vol_in);
        vol_in = repmat(vol_in,1,1,2);
        vol_in(:,:,2) = zeros(a,b);
    end
    vol(:,:,:,1) = vol_in;
    display4D(double(vol),[],[],[]);
    vol_out = [];    mask_out = [];
    return;
end

if nargout == 0 && nargin == 2
    if length(unique(size(vol_in)~=size(mask_in)))>1
        error('Volume and mask files must be same size.');
    end
    if numel(size(vol_in)) == 2 %prevent crashing if 2D image
        [a,b] = size(vol_in);
        vol_in = repmat(vol_in,1,1,2);
        vol_in(:,:,2) = zeros(a,b);
        mask_in = repmat(mask_in,1,1,2);
        mask_in(:,:,2) = zeros(a,b);
    end
    vol(:,:,:,1) = vol_in;
    display4D(double(vol),double(mask_in),[],[]);
    vol_out = [];    mask_out = [];
    return;
end

if nargout == 0 && nargin >= 3
    if numel(size(vol_in)) == 2 %prevent crashing if 2D image
        [a,b] = size(vol_in);
        vol_in = repmat(vol_in,1,1,2);
        vol_in(:,:,2) = zeros(a,b);
    end
    vol(:,:,:,1) = vol_in;
    if nargin == 3
        display4D(vol,[],cmap,[]);
    elseif nargin == 4
        display4D(vol,[],cmap,coloraxis);
    end
    vol_out = [];    mask_out = [];
    return;
end

error('Invalid set of inputs or outputs');

end

%% subfunctions
function display4D(vol,mask,cmap,coloraxis)
maskcopy = mask;

if ~isempty(mask)

    begin_index = find(mask>0,1,'first');
    end_index = find(mask>0,1,'last');

    [~,~,begin_slice] = ind2sub(size(mask),begin_index);
    [~,~,end_slice] = ind2sub(size(mask),end_index);
    slice = round((end_slice+begin_slice)/2);
    
    showmask = uicontrol('Style','pushbutton','String','Hide Mask?','Units','normalized','Position',[0.001 0.3 .12 .05],'Callback',@changemask);

else
    if isempty(find(isnan(vol),1))
        begin_index = find(vol>0,1,'first');
        end_index = find(vol>0,1,'last');
    else
        begin_index = find(~isnan(vol),1,'first');
        end_index = find(~isnan(vol),1,'last');
    end
    [~,~,begin_slice] = ind2sub(size(vol),begin_index);
    [~,~,end_slice] = ind2sub(size(vol),end_index);
    slice = floor((end_slice+begin_slice)/2);
end    

%GUI objects
set(gcf,'Color','white');

rotbox = uicontrol('Style','pushbutton','String','Transpose?','Units','normalized','Position',[0.001 0.5 .12 .05],'Callback',@rotatebox);

slider = uicontrol('Style', 'slider',...
   'Max',size(vol,3),'Min',1,...
   'Units', 'normalized', ...
   'Position', [.25 .005 .4 .04],...
   'SliderStep', [1/(size(vol,3)-1) 1/(size(vol,3)-1)], ...
   'Value', slice, ...
   'Callback', @move_slider);

text_box = uicontrol('Style', 'text',...
   'Units', 'normalized', ...
   'Position', [.675 .006 .04 .04],...
   'String', num2str(slice));

set(gcf,'UserData',vol);
showmap(slice, vol, mask,cmap,coloraxis);


%callback to rotatebox
function rotatebox(~,~)
   vol = permute(vol,[2 1 3]);
   if ~isempty(mask)
       mask = permute(mask,[2 1 3]);
   end
   maskcopy = permute(maskcopy,[2 1 3]);
   showmap(slice,vol,mask,cmap,coloraxis);
end

%callback to changemask
function changemask(~,~)
   if strcmp(get(showmask,'String'),'Hide Mask?')
      set(showmask,'String','Show Mask?');
      mask = [];
   else
      set(showmask,'String','Hide Mask?');
      mask = maskcopy;
   end
   showmap(slice,vol,mask,cmap,coloraxis);
end


%callback to slider
function move_slider(~,~)
    slice = round(get(gcbo,'Value'));
    set(gcbo,'Value',slice);
    set(text_box,'String',num2str(slice));
    save_xlim = xlim;
    save_ylim = ylim;
    if exist('showmask','var')==1 && strcmp(get(showmask,'String'),'Hide Mask?')
        showmap(slice,vol,mask,cmap,coloraxis);
    else
        showmap(slice,vol,[],cmap,coloraxis);
    end
    xlim(save_xlim);
    ylim(save_ylim);
end

%where the images are displayed 
function showmap(slice,vol,mask,cmap,coloraxis)
   
    im = rescale(vol(:,:,slice));
    
    if ~isempty(mask)
        maskslice = mask(:,:,slice);
        if ~isempty(find(maskslice>0,1))
            colors = [0 1 0; 1 1 0; 1 2/3 0; 0 0 1; 1 0 0; 1 0 1; 0 1 1; 1 1 1;0 0 0; 1 .41 .70]; %[green yellow orange blue red magenta cyan white black]


           if length(find(unique(maskslice)>0)) > length(colors)
                error(['too many label colors! (max allowed = ', int2str(length(colors)),', currently)']);
           elseif max(unique(maskslice)) > length(colors)
               error(['Color value of a label is greater than current number of color bins!']);
           end

            %format the order in such a way that the biggest masks are displayed first, so that you can see all colors:)
            uvec = maskslice(maskslice>0);
            if ~isempty(uvec)
                u = unique(uvec);
                N = histcounts(uvec,length(u));
                [~,ind] = sort(N,'descend'); %*******descend, ascend (whichever helps see all colors!)********
                for i = 1:length(ind)
                    m = (maskslice==u(ind(i)));
                    [dx,dy] = gradient(m);
                    edgei=sqrt(dx.^2+dy.^2);
                    edgei=edgei~=0;
    %                 se=[0 1 0; 1 1 1; 0 1 0];
    %                 se=se~=0;
    %                 edgei=imerode(edgei,se);
                    im = rgbmaskrgb(im,edgei,colors(u(ind(i)),:));
                end
            end
            imagesc(im);colormap gray; axis off;hold on;
        else
            imagesc(im);axis off;colormap gray;
        end
    end
    
    if ~isempty(cmap)
        minval = min(vol(:));
        maxval = max(vol(:));
        vol(isnan(vol)) = minval - inf; %set nans to black!
        if cmap ==1 %default cmap
            cmap = colormap(jet(128));
            cmap(1,:) = [0 0 0];
        end
        imagesc(im);colormap(cmap);colorbar;axis off;
        if ~isempty(coloraxis)
            caxis(coloraxis);
        else
            caxis([minval maxval]);
        end
    end
    if isempty(mask) && isempty(cmap)%just display the volume as is
        imagesc(im);axis off;colormap gray;
    end
    
    title([ 'slice ' num2str(slice) ' of ' num2str(size(vol,3))])

end

end

%% Additional subfunctions

function Irgb=rgbmaskrgb(Irgb,mask,colorspec)
%RGBMASKRGB
%   IMASKED=rgbmaskrgb(I,MASK,COLORSPEC)
%
%   Mask NxM gray scale image I with the NxM logical, MASK. Output image,
%   IMASKED, with the *exact* color specified by COLORSPEC. COLORSPEC is a
%   3 element array indicating R, G and B intensities. For example, [1 0 0]
%   specified red, [0 1 0] specified green, and [1 1 0] specifies yellow.
%   COLORSPEC reflects the scale of the data (if using uint8 rather than
%   double, use [255 0 0] for example).
%
%   Input may also be a color image of size NxMx3. Grayscale input is
%   converted to color.
%
%   Output, Imasked, is an NxMx3 RGB image.
%   See original: \...REPO\repo_satish\general

% check if input is color, if not make color
if size(Irgb,3)==1,
    Irgb=repmat(Irgb,[1 1 3]);
end

if ~islogical(mask), error('Mask must be logical.'); end

Ic=Irgb(:,:,1);
Ic(mask)=colorspec(1);
Irgb(:,:,1)=Ic;

Ic=Irgb(:,:,2);
Ic(mask)=colorspec(2);
Irgb(:,:,2)=Ic;

Ic=Irgb(:,:,3);
Ic(mask)=colorspec(3);
Irgb(:,:,3)=Ic;

end

function Iout = rescale(I)
% RESCALE Rescale data into the range [0,1].
%   RESCALE(I) rescales the array I so that all elements fall in the range
%   [0,1]. The output is double precision.
%
%   See also RESCALE_RANGE.
%
%JC

% Convert input to double precision
% if ~isa(I,'double'),
%     I=double(I);
% end
if ~isfloat(I),
    I=double(I);
elseif isa(I,'single'),
    warning('rescale:gotSingleData','Input data is single precision.  Results may be inaccurate.');
end

% Make sure the data can be rescaled with the current machine precision
if (max(I(:)) - min(I(:))) > eps,
    % Iout = (I- min(I)) / range(I)
    Iout = (I-min(I(:)))/(max(I(:))-min(I(:)));
else
    Iout=I;
end

end

