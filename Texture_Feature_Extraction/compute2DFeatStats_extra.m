function [featstats,statnames]=compute2DFeatStats_extra(featints, featnames)
%INPUTS
% featints: a 1xM cell array, where each column cell is a vector containing feature values
% featnames: (optional) a 1xM cell array of the names corresponding to each element of featints; use [] if you dont care about knowing statnames

%OUTPUT
% featstats: a 4xM double matrix, where each element in a column a single of the feature intensity vector in the corresponding column
% statnames: a 4xM cell matrix, where each element is the statistic and feature name corresponding to featstats

% fprintf('Extracting 4 feature statistics\n');
featstats=zeros(4,length(featints)); %mxn matrix (m = # statistics, n = # texture features)
statnames=cell(4,length(featints));
for i=1:length(featints)
    temp1=featints{i};
    featstats(:,i)= [median(temp1); ...
                     std(temp1)^2; ...
                     kurtosis(temp1); ...
                     skewness(temp1)];
                     %previously used: mean(temp1);range(temp1); std(temp1); harmmean(temp1);mad(temp1); iqr(temp1)
    clear temp1
end
if ~isempty(featnames)
   for i=1:length(featnames)
        statnames{1,i} = strcat('median-',featnames{i});
        statnames{2,i} = strcat('var-',featnames{i});
        statnames{3,i} = strcat('kurtosis-',featnames{i});
        statnames{4,i} = strcat('skewness-',featnames{i});
%          previously used:
%          statnames{3,i} = strcat('range-',featnames{i});
%         statnames{7,i} = strcat('harmean-',featnames{i});
%         statnames{4,i} = strcat('std-',featnames{i});
%          statnames{5,i} = strcat('mean-',featnames{i});
%         statnames{9,i} = strcat('mad-',featnames{i});
%         statnames{10,i} = strcat('iqr-',featnames{i});
   end
end 