% function wilcoxon_ranksum_boxplot(filename_healthy,filename_disease,yaxis_label)
close all
clear all
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name - wilcoxon_ranksum_boxplot
% Creation Date - 28th July 2014
% Author: Soumya Banerjee
% Website: https://sites.google.com/site/neelsoumya/
%
% Description: 
%  Perform a Wilcoxon rank-sum test or Mann-Whitney U-test (non-parametric test)
%  Takes measurements of genes/compounds/bugs/metabolites etc in healthy
%  (control) individuals and individuals with some disease. Then does a
%  Wilcoxon rank-sum test to find out how many of these genes/compounds/metabolites/bugs,
%  etc are differentially abundnant in healthy vs. disease in a
%  statistically significant manner.
%  Also generates box plots for each of the measured genes/compounds/bugs/metabolites
%  The data for healthy individuals and individuals with some disease must be supplied in
%  separate files. The rows will represent different measured genes/compounds/bugs/metabolites
%  and the columns will be different individuals. 
%
% Input:  
%       1) filename_healthy: Name of file containing matrix of measurements
%           of some quantity (genes/metabolites/bugs/compounds, etc) in healthy (control) individuals.
%           The columns are replicates or different individuals, that is (say) the same compound
%           measured in multiple healthy individuals.
%           The rows are different compounds.
%           There may be a header row that has some descriptive text (not
%           necessary).
%           It is necessary to have the first column of this file be a text
%           only column that has some description of the quantity being
%           measured. For example, if a compound is being measured in
%           multiple individuals, then the name of that compound should be
%           in the first column. If this is all too complicated, dont worry
%           (!), because two example files are attached.
%       2) filename_disease: Name of file containing matrix of measurements
%           of some quantity (genes/metabolites/bugs/compounds, etc) in individuals with some disease.
%           Same restrictions as above apply.
%       3) yaxis_label:   label for y-axis of boxplots (for example compound abundance) 
%   
% Output: 
%       1) A file containing results from a Wilcoxon rank-sum test comparing each row in the
%           file filename_healthy to each row in the file filename_disease.
%           This includes p-value, rank-sum score and a Benjamini-Hochberg corrected
%           FDR (False Discovery Rate) q-value   
%       2) The number of compounds/genes/metabolites etc (represented by the
%           rows) that are differentially abundant in healthy vs. disease
%           (statistically significant at p-value < 0.05 and also FDR q-value <
%           0.05)
%       3) A number of boxplots of each of the measured quantities (say compound abundance) in disease vs. healthy
%       4) A combined boxplot that combines all boxplots in 3) into one
%           (requires ghostscript to be installed and needs to be run on
%           UNIX/Mac OS X). Currently commented out.
%
% Assumotions -
%       1) Input file must be tab-delimited
%       2) The names of compounds/bugs/metabolites/genes etc must match (row-by-row) between the two
%           input files i.e. if say compound X is in row 3 of the healthy file
%           (e.g compounds_healthy.csv), then compound X must also be in row 3
%           of the disease file (e.g. compounds_disease.csv)
%
% Example usage:
%       wilcoxon_ranksum_boxplot('compounds_healthy.csv','compounds_disease.csv','Compound abundance')
%
% License - BSD 
%
% Acknowledgements -
%           Dedicated to my wife Joyeeta
%
% Change History - 
%                   28th July 2014  - Creation by Soumya Banerjee
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Load the data
data_ptr_healthy = [0.523118004	3.832527807	31.62106519	0.463523213	0.079990548
0.5	4.233575379	29.77217464	0.086617381	0.042093733
0.5	4.982938448	26.69259309	0.027262841	0.026267237
0.5	3.810960979	33.61115238	1.196781089	0.111864046
0.5	4.93834342	26.3847596	0.021475854	0.023563829
0.5	4.662449876	27.10677034	0.022773432	0.023625324
0.5	3.888489438	32.0080332	0.116761365	0.049246629
0.5	5.06049073	25.51282258	0.015797909	0.020080835
0.5	5.106126832	24.0248164	0.007043672	0.012941227
0.5	4.29538471	29.33030142	0.046185381	0.031931702
0.5	5.003012563	24.18020466	0.006863631	0.012643379
0.5	5.173918047	25.14584329	0.01595352	0.020556577
0.5	5.387720228	22.89806396	0.0060883	0.012582378
0.5	4.387725564	28.66494428	0.033734046	0.027258131
0.5	4.079963898	31.33637206	0.12026593	0.05101077
0.5	3.671037153	32.16713967	0.141256479	0.052404666
0.5	4.002971918	30.67190731	0.08400069	0.041725237
0.5	3.885685088	31.93663616	0.10876701	0.049129204
0.5	4.742318246	26.51986468	0.017435266	0.020369007
0.5	5.011725754	25.65485214	0.016711358	0.020952284
0.5	4.869386876	26.19205273	0.017593696	0.020452166
0.5	5.083401659	24.84304028	0.012032364	0.017770551
0.5	4.025034208	30.32129199	0.055254665	0.034175177
0.5	5.013153479	25.80738928	0.017538464	0.021142072
0.5	5.457311288	20.77261291	0.002172717	0.007393417
0.5	4.141355952	30.4927826	0.17873556	0.053103566
0.5	4.85269486	25.43366261	0.01172069	0.016925501
0.5	3.917638854	32.40784274	0.234130747	0.068678321
0.5	5.087253008	24.62339989	0.010419557	0.016307141
0.5	5.396255968	22.47496175	0.005160146	0.011687599
0.5	4.016528225	30.44460843	0.063076719	0.038418872
0.5	4.276710799	29.62259203	0.059331746	0.037134562
0.5	4.102555966	29.81396641	0.048338477	0.033050235
0.5	4.82703096	26.98525982	0.025600766	0.024880253
]';
data_ptr_disease =[0.5	3.904163731	31.72114974	0.573236237	0.175646619
0.5	3.977471199	31.98547649	0.32780581	0.071758681
0.539417294	4.106507351	29.79153216	0.092192166	0.045378605
0.5	3.83921178	34.07252495	2.245785875	0.140889919
0.5	4.000920597	31.54520112	0.320713554	0.069539444
0.5	4.65409833	27.38809508	0.027514102	0.026064255
0.5	3.769278676	34.19044275	1.753647507	0.132749714
0.5	3.898438419	31.30325683	0.154047441	0.053616306
0.5	3.658247605	33.53741447	0.33050092	0.076895869
0.5	3.601779681	34.53266811	0.760484703	0.106199456
0.5	3.753364093	34.0238605	1.554138233	0.098338476
0.5	3.819166848	33.4145805	1.050357118	0.106539029
0.5	3.766119786	34.20800421	1.591192834	0.128424164
0.5	3.988889211	32.57772896	0.579262775	0.080401636
0.5	3.790706571	34.09252277	1.49606435	0.130316248
0.5	3.610640996	33.22512287	0.459166929	0.083380203
0.5	3.901700451	33.74372484	2.002949851	0.122854778
0.5	4.013237758	31.46307336	0.11207304	0.047340028
0.5	4.094169404	30.40449336	0.09774698	0.042889092
0.523118004	4.121506472	29.03409346	0.135656598	0.051496614
0.52567337	4.128700047	29.62929488	0.262320845	0.064801884
0.523118004	3.781607743	33.03782447	0.888097576	0.106199641
0.523118004	4.305283747	28.33052724	0.135536426	0.046292277
0.523118004	3.883568884	31.4559323	0.621053737	0.090277931
0.523118004	3.750650146	31.48369601	0.196857684	0.062364619
0.523118004	3.834400914	31.46662013	0.339786213	0.072712095
0.523118004	3.867360873	32.21697218	1.189875702	0.103437795
0.523118004	3.501200944	33.49814439	0.934950012	0.11456311
0.523118004	4.409930785	27.21828437	0.043798753	0.030535831
0.523118004	4.327890678	28.39661716	0.040656874	0.031909779
0.523118004	4.307402759	28.93505369	0.066995012	0.039672572
0.523118004	3.575729525	33.25873365	0.723385478	0.103009466
0.55924593	4.172968929	28.51487089	0.053710322	0.035509579
0.5	3.76212968	32.62573938	0.28986709	0.065090929
]';

%% Initial checks
% number of rows in healthy file must be the same as the number of rows in
% disease file. This reflects the fact that both must have measured the
% same number of quantities (genes, compounds, bugs, metabolites, etc)
if size(data_ptr_healthy,1) ~= size(data_ptr_disease,1)
    disp('The number of rows in healthy file must be the same as the number of rows in')
    disp('disease file. This reflects the fact that both must have measured the same number of quantities (genes, compounds, bugs, metabolites, etc) in both healthy individuals and individuals with disease')
    return
end

iNumRows = size(data_ptr_healthy,1);

iTempCount = 1; % temporary counter variable to store index of array of wilcoxon stats
% Iterate through all rows
for iCount = 1:iNumRows
    %% Perform a Wilcoxon rank-sum test or Mann-Whitney U-test
    [temp_p_value temp_h_value temp_wilcox_stats] = ranksum( ...
                                                                data_ptr_healthy(iCount,:), ...
                                                                data_ptr_disease(iCount,:)  ...
                                                                );
                                                            
    array_wilcox_risk(iTempCount,:) = [temp_p_value temp_h_value temp_wilcox_stats.ranksum];
    iTempCount = iTempCount + 1;        
end


%% Perform a Benjamini-Hochberg correction of p-values to yield FDR (False Discovery Rate)
PValues = array_wilcox_risk(:,1);
FDR = mafdr(PValues,'BHFDR',true);

%% Generate a volcano plot (optional: commented out)
%mavolcanoplot(data_ptr_healthy.data,data_ptr_disease.data,PValues)

%% Calculate number of measurements (compounds, metabolites, bugs, etc) 
%% that are differentially abundant (statistically significant) in healthy vs. disease
temp_index_sign_FDR = find(FDR < 0.05);
disp('Number of measurements (compounds, metabolites, bugs, etc) that are differentially abundant (statistically significant) in healthy vs. disease at FDR < 0.05')
size(temp_index_sign_FDR,1)

temp_index_sign_pvalue = find(PValues < 0.05);
disp('Number of measurements (compounds, metabolites, bugs, etc) that are differentially abundant (statistically significant) in healthy vs. disease at p-value < 0.05')
size(temp_index_sign_pvalue,1)

%% Save list of p-values, ranksum score and FDR values to disk
dlmwrite('vital_stats.txt',[array_wilcox_risk(:,1) array_wilcox_risk(:,3) FDR],'delimiter','\t')
disp('Statistics saved in file vital_stats.txt')

%% Create box plot

% Iterate through all rows
for iCount = 1:iNumRows

    %% Combined data for healthy and disease
    data_box_plot = [ data_ptr_healthy(iCount,:)' ; data_ptr_disease(iCount,:)'];

    %% Replicates labels
    str_group = [repmat('Healthy',size(data_ptr_healthy(iCount,:),2),1); repmat('Disease',size(data_ptr_disease(iCount,:),2),1)];

    %% create figure for boxplot
    temp_figID = figure;
    boxplot(data_box_plot,str_group,'notch','on')
  

    %% save boxplot to disk
    print(temp_figID, '-dpdf', sprintf('boxplot_%d_%s.pdf', iCount, date));
end
disp('Box plots saved in file names boxplot_*.pdf')

%% Combine pdfs of all boxplots into one single pdf
%% CAUTION - requires ghostscript and a UNIX/Mac OS X system
% Commented out. Uncomment if you meet both of these requirements
% This code courtesy of Decio Biavati at
% http://decio.blogspot.de/2009/01/join-merge-pdf-files-in-linux.html

%unix('gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=finished.pdf *.pdf')