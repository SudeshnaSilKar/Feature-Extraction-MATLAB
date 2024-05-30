 function [features,description] = marjanSara_FD_feat(mask,img,patientName,tileNo)
% compute all Fractal features 

description = {'patientName','tileNo','FD_2D_img_Avg','FD_2D_img_STD', 'FD_2D_img_Med',...
    'FD_2D_img_SKW','FD_2D_img_min','FD_2D_img_max', ...
    'FD_2D_mask_Avg','FD_2D_mask_STD','FD_2D_mask_Med' ...
    'FD_2D_mask_SKW','FD_2D_mask_min','FD_2D_mask_max'...
    'FD1_mask','entropy','GMM1','GMM2','GMM3','delay','entropy_MI','Signal_variance','Signal_average'};

cc=bwconncomp(mask);

mask_size=size(mask);
img_size=size(img);
if mask_size(1:2)~=img_size(1:2)
    error('the size of image and mask must be same')
end
blast_ind=1;
 for blast_ind=1:cc.NumObjects
    roi_ind=cc.PixelIdxList{blast_ind};
    [ROI_row,ROI_colm]=ind2sub(mask_size,roi_ind);
    dim = mask(min(ROI_row):max(ROI_row),min(ROI_colm):max(ROI_colm));
    org_blast_r=img(min(ROI_row):max(ROI_row),min(ROI_colm):max(ROI_colm),1);
    org_blast_g=img(min(ROI_row):max(ROI_row),min(ROI_colm):max(ROI_colm),2);
    org_blast_b=img(min(ROI_row):max(ROI_row),min(ROI_colm):max(ROI_colm),3);
    org_blast=cat(3,org_blast_r,org_blast_g,org_blast_b);
    img2=rgb2gray(org_blast);

%     bounds=DLMask2bounds_function_noorginput(dim);
    
    
%     Fractal 2D of image
    [r,n] = boxcount(img2);
    D = -diff(log(n))./diff(log(r));
    FD_multi = mean(D(find(D>0)));
    FD_multi_STD=std(D(find(D>0)));
    FD_multi_Med=median(D(find(D>0)));
    FD_multi_SKW=skewness(D(find(D>0)));
    FD_multi_min=min(D(find(D>0)));
    FD_multi_max=max(D(find(D>0)));
    
%     Fractal 2D of mask

    [r1,n1] = boxcount(dim(find(dim>0)));
    D1 = -diff(log(n1))./diff(log(r1));
    FD_mask = mean(D1(find(D1>0)));  
    FD_mask_STD=std(D1(find(D1>0)));
    FD_mask_Med=median(D1(find(D1>0)));
    FD_mask_SKW=skewness(D1(find(D1>0)));
    FD_mask_min=min(D1(find(D1>0)));
    FD_mask_max=max(D1(find(D1>0)));
    
%     Fractal 1D of mask
    a=(find(dim>0));
    data= a(1:1:numel(a));
    FD1 = BoxFractalDim(data);
    
    %img(data)
%     mex mutual.c
%     delay tau
%     tau = mutual_tau(data');
%     entropy
    

[tau,entropy_MI] = Mutual_Inform(data)

    signal = data;
    av = mean(signal);
    variance = var(signal);
    minimum = min(signal);
    maximum = max(signal);
    interval = maximum-minimum;
    len = length(signal);
    partitions = 5;
    for i = 1:1:len
        signal(i) =(signal(i)- minimum)/interval;
    end
    for i = 1:1:len
        if signal(i) > 0 
            array(i) = ceil(signal(i)*partitions);
        else
            array(i) = 1;
        end
    end
    shannon= make_cond_entropy(0,array,len,partitions);
    if (tau >= len)
        tau=len-1;
    end
 
    for i = 0:1:tau
        mi(i+1) = make_cond_entropy(i,array,len,partitions);
    end
    entropy_s=mean(mi);
    
%     chaotic attracto
    N = length(data);                           % length of data
    M=3;
    n = size(data,1);
    N = n - tau*(M-1);
    A = zeros(N,M); % maximum # of segments (k = 1,2 ... n - (e-1)*tau  
    
    % loop through series "x" and pull out e-dimensional vectors
    for t = 1:M
        A(:,t) = data([1:N] + tau*(t-1)); % indexes by tau
    end
    t=A;
    try
     options = statset('Display','final');
     obj = gmdistribution.fit(A,2,'Options',options);  
     m1=mean(obj.mu(1,:))
     m2=mean(obj.mu(2,:))
     m3=obj.NegativeLogLikelihood
    catch ME
       m1=0;
       m2=0;
       m3=0;
    end
 
    
    
    
    
    feats{blast_ind}={patientName,tileNo,FD_multi,FD_multi_STD,FD_multi_Med,FD_multi_SKW,FD_multi_min,FD_multi_max,FD_mask,FD_mask_STD,FD_mask_Med,FD_mask_SKW,FD_mask_min,FD_mask_max,FD1, entropy_s, m1,m2,m3,tau,entropy_MI,variance,av};

%         clear org_blast_r org_blast_g org_blast_b org_blast ROI_row ROI_colm roi_ind
 end    


Matx=[];
for ind=1:cc.NumObjects
    
    A1=cell2mat(feats{1,ind});
    Matx=[Matx;A1];
end

features=Matx;