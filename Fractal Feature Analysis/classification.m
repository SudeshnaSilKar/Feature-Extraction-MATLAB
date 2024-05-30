%% Setup
close all;clear;clc;

%% Load Fisher's Iris Data
% load C:\mmm\mxf412\Final_Lumenfeatures
% meas1=FF(:,1:7);
% load C:\mmm\mxf412\Final_tissuefeatures
% meas2=FF(:,1:7);
% load C:\mmm\mxf412\Final_features
% meas3=FF(:,1:7);
% load C:\mmm\mxf412\Final_PV_Lumen_features
% meas4=FF(:,1:7);
load F_PV_M1_features
meas1=FF(:,1:11);
load F_LumenM1_features
meas2=FF(:,1:11);
Labels=FF(:,12);
load F_PV_Lu_M1_features
meas3=FF(:,1:11);

load('\\csehomes\csehome$\mxf412\Desktop\F_PV_Lu_M1_features.mat')
meas4=FF(:,1:11);
% load Final_PVTest_features
% meas4=FF(:,1:11)
% Labels4=FF(:,12);
measFinal=[meas1,meas2,meas3];
% Labels=FF(:,12);


% load featuresP
% meas2=F;
% load featuresT
% meas3=F;
% meas=[meas1,meas2,meas3]; 
% Labels=FF(:,8);
species=(Labels);
% [auc, labels] = colAUC(meas1,species,'ROC')

% load LabelsA
% s=Labels;

% load LabRA
% s1=LabR;
% s(20)=1;
% s(114)=0;
% s(115)=0;
% s(116)=0;
% s(117)=0;
% s(118)=0;
% s(119)=0;
% load LabRRR 
% load LabelsA
% % save LabRRR s
% % sum(s)
% meas(:,[6 7 9 10 12 13 19 20 22 23 25 26 32 33 35 36 38 39])=[];
% meas11=meas;
% 
% load featuresLT
% meas1=F;
% load featuresPT
% meas2=F;
% load featuresTT
% meas3=F;
% meass=[meas1,meas2,meas3];
% load LabRRR
% load LabA
% save LabRRR s
% sum(s)
% Labels=FF(:,8);
% Lab=Lab';
% l=[Labels; Lab]
% save l
% meass(:,[6 7 9 10 12 13 19 20 22 23 25 26 32 33 35 36 38 39])=[];
% meas22=meass;
% mm=[meas11;meas22];
% mm=[mm l];
csvwrite('Training_PV.csv', [meas1,Labels]);
csvwrite('Training_Lumen.csv', [meas2,Labels]);
csvwrite('Training_Tissue.csv', [meas3,Labels]);
csvwrite('TrainingT_All.csv', [measFinal,Labels]);
csvwrite('Training_PV_Lu.csv', [meas4,Labels]);
% meas1=F;
% load FeaturesPT
% meas2=F;
% load FeaturesTT
% meas3=F;
% meas=[meas1 meas2 meas3];
% 
% 
% load LabA
% csvwrite('TTT.csv', [meas3 Lab']);

species=num2str(Labels);

for i=1:size(species)
Y{i,1}=species(i);
end
% figure;gscatter(meas(:,1), meas(:,2), species);
% xlabel('FD3');ylabel('IC3');
% legend('NonR','R');
% title('Atrial Fibrillation'); 
group = species;
%% Linear Discriminant Analysis (LDA)
%Fit and test a model using default linear partitioning

% % 
% lda = fitcdiscr(meas1,group);
% cp = cvpartition(group,'KFold',5);
% cvt = crossval(lda,'CVPartition',cp);
% [~,posterior] = kfoldPredict(cvt);
% [fpr,tpr,~,auc] = perfcurve(Y,posterior(:,2),cvt.ClassNames(2));
% auc
% plot(fpr,tpr);
% xlabel('False positive rate');
% ylabel('True positive rate');
% title('ROC Curve');
% tCVErr = kfoldLoss(cvt);
% 
% group=Labels;
% t = fitctree(meas, group);
% dtResubErr = resubLoss(t);
% [grpname,node] = predict(t,meas);
% cp = cvpartition(group,'KFold',10);
% cvt = crossval(t,'CVPartition',cp);
% [~,posterior] = kfoldPredict(cvt);
% 
% [fpr,tpr,~,auc] = perfcurve(Y,posterior(:,2),cvt.ClassNames(2));
% auc
% plot(fpr,tpr);
% xlabel('False positive rate'); ylabel('True positive rate');
% title(sprintf('ROC for classification. AUC = %0.3f',auc));
% tCVErr = kfoldLoss(cvt);
for k=1:100
kfold=5;
Y=Labels;
X=meas1;
data = [X,Y];
data=data(randsample(1:length(data),length(data)),:);
indices = crossvalind('Kfold',Y,kfold);
  cp = classperf(Y); % initializes the CP object
for i = 1:kfold
    test = (indices == i);
    train = ~test;
    X_train = data (train,1:end-1);
    Y_train = data (train,end);
    X_test = data (test,1:end-1);
    Y_test = data (test,end);
    Mdl = fitctree(X_train,Y_train);
    %Mdl= fitcdiscr(X_train,Y_train,'DiscrimType','quadratic');
    [pred,score,cost] = predict(Mdl,X_test);
    [c,cm,ind,per] = confusion(Y_test,pred);
    cp = classperf(Y_test,pred);
    correct(i) = cp.CorrectRate;
    [x_auc,y_auc,T,AUC] = perfcurve(Y_test,score(:,2),1);
    auc(i) = AUC
    
    
  
%       class = classify(X_test, X_train,Y_train);
%         % updates the CP object with the current classification results
%         classperf(cp,class,test)  

% plot(x_auc,y_auc)
% xlabel('False positive rate'); ylabel('True positive rate');
% title(sprintf('ROC for classification. AUC = %0.3f',AUC));
end
    auuc(k)=mean(auc); 
    plotconfusion(t,y)
%     
%   
%     
%     
% %     
%     figure;plot(x_auc,y_auc)
%     xlabel('False positive rate')
%     ylabel('True positive rate')
%     title('ROC for Classification by Logistic Regression')
%     
end
aa=mean(auuc)
[confus,numcorrect,precision,recall,F] = getcm (x_auc,y_auc,Labels)
% end
% 
% mean(aa)

% resp = Labels;
% pred = X;
% mdl = fitglm(pred,resp,'Distribution','binomial','Link','logit');
% score_log = mdl.Fitted.Probability; % Probability estimates
% 
% mdlSVM = fitcsvm(pred,resp,'Standardize',true);
% 
% mdlSVM = fitcsvm(pred,resp,'Standardize',true);
% mdlSVM = fitPosterior(mdlSVM);
% [~,score_svm] = resubPredict(mdlSVM);
% [Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(resp,score_svm);
% mdlNB = fitcnb(pred,resp);
% [~,score_nb] = resubPredict(mdlNB);
% [Xnb,Ynb,Tnb,AUCnb] = perfcurve(resp,score_nb);
% 
% plot(Xlog,Ylog)
% hold on
% plot(Xsvm,Ysvm)
% plot(Xnb,Ynb)
% legend('Logistic Regression','Support Vector Machines','Naive Bayes','Location','Best')
% xlabel('False positive rate'); ylabel('True positive rate');
% title('ROC Curves for Logistic Regression, SVM, and Naive Bayes Classification')
% hold off
