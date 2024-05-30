% function [outputArg1,outputArg2] = Read_data(inputArg1,inputArg2)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
close all
clear all
clc
s=1;
k5=1;
filename = '/home/gxa131/mmm/home/gxa131/Data/Final_Labels.xlsx';
projectdir='/home/gxa131/mmm/data/CCF_Atrial_Fibrillation/Afib-ablation-data-20190111/CT-segmentations';
ds = spreadsheetDatastore('/home/gxa131/mmm/home/gxa131/Data/Final_Labels.xlsx');
p = read(ds);
columnC = p.Recurrence;
columnA=p.ID;
columnB = p.Lumenidx;
columnD = p.Pvidx;
columnH = p.Tissueidx;
%for i2=112:113
for i2=1:size(columnB,1)
    i2
         
         if i2 == 16
             ff0=1;
         end
         if i2 == 19
             ff0=1;
         end
         %if i2 == 113
             %continue;
         %end 
         %{
         if i2 == 98
            FF(i2,:) = [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
            continue;
         end
         %}  
         if isnan(columnB(i2))              
           continue;
         end;
         %{
         if columnB(i2)==0
           continue;
         end; 
         
         if columnB(i2)==52
           continue;
         end; 
         %}
         fname= columnA{i2}               
         p = dir(fullfile(projectdir,fname, '*.mat'))
         load(fullfile(projectdir,fname,p.name))
         Labels=columnC(i2)
         X2=segMask{1,columnB(i2)};
         X1=segMask{1,columnD(i2)};
         X=X1-X2;

         %X=segMask{1,columnD(i2)};
         Y=volCT;
         P=rot90(X1,3);
         P1=rot90(flipud(Y),-3);
         %niftiwrite (P1,'Img.nii');
         niftiwrite (P,[fname,'_pv.nii']);
         
         
         %{
         
         for i=1:size(X,3)
              I{i}= Y(:,:,i); 
         end    
        
        for j=1:size(I,3)
            j
            [M,N]= size(I{j});
            for r=2:7
                rc = @(x) floor(((max(x)-min(x))/r))+ 1; % non-linear filter
                F= colfilt(I{j}, [r r],'sliding', rc);
                B{r}= log(double(F * (49/(r^2))));
            end
            i=log(2:7); % Normalised scale range vector
            Nxx=dot(i,i)-(sum(i)^2)/6;
            for m = 1:M
                for n = 1:N
                    fd= [B{7}(m,n), B{6}(m,n), B{5}(m,n), B{4}(m,n), B{3}(m,n), B{2}(m,n)]; % Number of boxes multiscale vector
                    Nxy=dot(i,fd)-(sum(i)*sum(fd))/6; 
                    FD{j}(m, n)= (Nxy/Nxx); % slope of the linear regression line
                end
            end
        end
        
%         matfilename = sprintf('FDPT_%d.mat', ii);
%         save(matfilename, 'FD');
F=FD;
%        clear FD


for k=1:size(F,2)
    J1(:,:,k)=F{k};
end
% J1(:,:,22:23)=[];
% niftiwrite (J1,'FDP.nii')
J=J1.*(double(X));
result = uint8((J / 3) * 255);

%niftiwrite (result,'LJ4.nii');
%niftiwrite (X,'im4.nii');
%niftiwrite (Y,'im44.nii');
[r,n]=boxcount(J);
D = -diff(log(n))./diff(log(r));

FDavg=sum(sum(sum(J)))/ numel(J);
FDsd= std(std(std(J))); % Standard deviation of FD for selected area
FDlac= ((sum(sum(sum(J.^2)))/(length(J)))./((sum(sum(sum(J)))/(length(J)))^2)); % Lacunarity for selected area        #1d fractal feature
  
ii=size(X,3);
t=1;
for k=1:ii      %2d
    a=im2double(X(:,:,k));
    if nnz(a)==0
        FD0=0;
        continue;
    end
    [r,n]=boxcount(a);
    df = -diff(log(n))./diff(log(r));
     %figure; imagesc(df);  
     %colorbar
    ff=df(find(0<df));
    FD0=mean(ff);
    if FD0>0     
    ff0(t)=FD0;
    t=t+1;
    end 
end           %2d 
co = sum(sum(sum(X)));
[fds ics averFD averIC]= fdvolfft(X);   %3d
fds_main=fds;
fds(isnan(fds))=0;

%%%%%%added by2
dim=X;
a=(find(dim>0));
data= a(1:1:numel(a));
FD1 = BoxFractalDim(data);     %1d fractals

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
    
%%%%%%added by 2    
    
aFD=averFD;
aIC=averIC;
aaa(1,1)=mean(ff0);    %Mean_FD2_shape
%aaa(1,2)=var(ff0);
aaa(1,2)=std(ff0);
aaa(1,3)=median(ff0);
aaa(1,4)=skewness(ff0);    %Skewness_FD2_shape
aaa(1,5)=max(ff0);  %Maximum_FD2_shape
aaa(1,6)=(aFD);   %3D_shape_aveg
aaa(1,7)=(aIC);    
aaa(1,8)=(FDavg);   %1D_mean
aaa(1,9)=FDsd;      %1D_standard_deviation
aaa(1,10)=FDlac;     %1D Lacunarity
aaa(1,11)=co;
aaa(1,12)=mean(D);
%%%%
aaa(1,13)=median(fds_main(~isnan(fds_main)), 'all');   %3D_shape_median
%aaa(1,13)=median(ff0, 'all');       %Median_FD2_shape
%aaa(1,14)=max(max(ff0));            %Maximum_FD2_shape
aaa(1,14)=max(max(fds));               %Maximum_FD3_shape
aaa(1,15)=std(std(fds));            % 3D shape_std
%aaa(1,17)=std(ff0);
aaa(1,16)=skewness(skewness(fds));      %3D_shape_skewness
aaa(1,17)=FD1;   %1d s and m
aaa(1,18)=m1;
aaa(1,19)=m2;
aaa(1,20)=m3;
aaa(1,21)=entropy_s;
aaa(1,22)=entropy_MI;
features=aaa;
% matfilename = sprintf('Final_features_%d.mat', i);
% save(matfilename, 'features');
FF(i2,1:23)=[features Labels];
clear J1 F FD ff0 FDavg aIC co D FDsd aFD
         %}
end
%save F_pv_features_corr_test FF
%save F_pv_features_corr_test FF
     
