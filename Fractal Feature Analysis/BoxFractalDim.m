function FD = BoxFractalDim(data)
% This function calculates the Box-counting fractal dimension.
% ************* Inputs & Outputs ********************
% varargin : data (time series(one-dimensional signal))
%            cellmax(Box size, can be 2^n, n=1,2,4,8...,bigger than data)
% varargout: Box-counting fractal dimension (describe signal's complexity)
%            (FD = lim(log(N(e))/log(k/e))>=1)
% ************* Contact Information ***************
% Modified by Hao Liang
% Email : leolhboy@hotmail.com 
%% Read data(if needed)
% ************* Excel data (Windows 2003 edition) ***************
% xlsread Economic_data.xls; data=ans(:,4); % read closing price as samples
% ************* matlab data(.mat files) *************************
% load Economic_data; data=data(:,4);       % read closing price as samples
%% Box-counting fractal dimension
L = length(data);                           % Number of sample points
cellmax = ceil(L/2)*2;                      % Anto-generate cellmax
y = data;
y_min = min(y);
% Shift Operation, move data_min to zero points
y_shift = y - y_min;
% Resampling, get the total points equal to cellmax+1
x_ord = [0:L-1]./(L-1);                     % interpolating function
    %  ************* description *****************
    %  interpolating function: estimate approximate value of unknown points
    %  according to certain value under finite points with the function.
xx_ord = [0:cellmax]./(cellmax);
y_interp = interp1(x_ord,y_shift,xx_ord);   % interpolating function
% Scale y to its max value 2^^c
ys_max = max(y_interp);
factory = cellmax/ys_max;
yy = abs(y_interp*factory);

t = log2(cellmax)+1;                        % iterations
for e=1:t
    Ne = 0;                                 % sum of signal coverage boxes
    cellsize = 2^(e-1);                     % box size
    NumSeg(e) = cellmax/cellsize;           % NumSeg of divided hori.axis
    % count the span N(e) of vert.axis with the first NumSeg of hori.axis
    for j=1:NumSeg(e)
        begin = cellsize*(j-1)+1;
        tail = cellsize*j+1;
        seg = [begin:tail];                 % segment coordinates
        yy_max = max(yy(seg));
        yy_min = min(yy(seg));
        up = ceil(yy_max/cellsize);
        down = floor(yy_min/cellsize);
        Ns = up-down;                       % NumBox of this part segment
        Ne = Ne+Ns;                         % sum of signal coverage boxes
    end
    N(e)=Ne;                                % count N(e) with certain 'e' 
end

% one time curve fitting of the least square to log(N(e))and log(k/e)
% The scope of of this curve is defined as Box-counting fractal dimension.
r = -diff(log2(N));                         % remove points beyond r[1,2]
id = find(r<=2&r>=1);                       % reserve the data points
Ne = N(id);
e = NumSeg(id);

P = polyfit(log2(e),log2(Ne),1);      % scope & intercept of curve fitting
FD = P(1);
