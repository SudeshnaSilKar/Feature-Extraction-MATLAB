%load('extractSOIDeformationFeatures_SOIDeformationStats_03180948_pval_992.mat')
clc;
clear all;
close all;

load('F_PV_M1_features.mat')
%matrixx=[double(Data), double(Age'), double(BMI'), double(DayToRecurrence'), double(Ht'), double(LAV'), double(LVEF'), double(PVTypical'), double(Smoking'), double(SR'), double(Wt'),double(Labels')];
%clinicals=[double(Data), double(Age'), double(MaleGender'), double(LAV'), double(LVEF'), double(BMI'), double(SR'), double(PVTypical'), double(PersistentAF'), double(Labels')];
%dlmwrite('Lables_test.csv', Labels(31:58,:))


%dlmwrite('training.csv', Data(1:30,:))
%dlmwrite('test.csv', Data(31:58,:))
%writetable(matrixx, 'new.csv')
dlmwrite('FF.csv', FF)
aaa=FF;
x1=aaa(:,1);
x=x1(aaa(:,18)==1);
y=x1(aaa(:,18)==0);
p1 = ranksum(x,y)

x2=aaa(:,2);
x=x2(aaa(:,18)==1);
y=x2(aaa(:,18)==0);
p2 = ranksum(x,y)

x3=aaa(:,3);
x=x3(aaa(:,18)==1);
y=x3(aaa(:,18)==0);
p3 = ranksum(x,y)

x4=aaa(:,4);
x=x4(aaa(:,18)==1);
y=x4(aaa(:,18)==0);
p4 = ranksum(x,y)


x5=aaa(:,5);
x=x5(aaa(:,18)==1);
y=x5(aaa(:,18)==0);
p5 = ranksum(x,y)


x6=aaa(:,6);
x=x6(aaa(:,18)==1);
y=x6(aaa(:,18)==0);
p6 = ranksum(x,y)

x7=aaa(:,7);
x=x7(aaa(:,18)==1);
y=x7(aaa(:,18)==0);
p7 = ranksum(x,y)

x8=aaa(:,8);
x=x8(aaa(:,18)==1);
y=x8(aaa(:,18)==0);
p8 = ranksum(x,y)

x9=aaa(:,9);
x=x9(aaa(:,18)==1);
y=x9(aaa(:,18)==0);
p9 = ranksum(x,y)

x10=aaa(:,10);
x=x10(aaa(:,18)==1);
y=x10(aaa(:,18)==0);
p10 = ranksum(x,y)


x11=aaa(:,11);
x=x11(aaa(:,18)==1);
y=x11(aaa(:,18)==0);
p11 = ranksum(x,y)

x12=aaa(:,12);
x=x12(aaa(:,18)==1);
y=x12(aaa(:,18)==0);
p12 = ranksum(x,y)


x13=aaa(:,13);
x=x13(aaa(:,18)==1);
y=x13(aaa(:,18)==0);
p13 = ranksum(x,y)


x14=aaa(:,14);
x=x14(aaa(:,18)==1);
y=x14(aaa(:,18)==0);
p14 = ranksum(x,y)


x15=aaa(:,15);
x=x15(aaa(:,18)==1);
y=x15(aaa(:,18)==0);
p15 = ranksum(x,y)

x16=aaa(:,16);
x=x16(aaa(:,18)==1);
y=x16(aaa(:,18)==0);
p16 = ranksum(x,y)

x17=aaa(:,17);
x=x17(aaa(:,18)==1);
y=x17(aaa(:,18)==0);
p16 = ranksum(x,y)
%}