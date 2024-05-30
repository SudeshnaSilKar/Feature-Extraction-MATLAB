%% Setup
% close all;clear;clc;

%load New_features_Lumen.mat
Features=FF(:,1:15);
classLeble=FF(:,16);

[fea] = mrmr_mid_d(Features, classLeble, 5)


species=(Labels);

group = species;
%% Linear Discriminant Analysis (LDA)
%Fit and test a model using default linear partitioning

% % 
% lda = fitcdiscr(meas,group);
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
X=meas;
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
%     plotconfusion(t,y)
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
