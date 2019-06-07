%% megaa_plotCvAccuracyVsThreat
% -------------------------------------------------------------
% Plots the cross-validated accuracy obtained at each time bin post-outcome
% with classifiers trained with data from trials with a single threat prob.
% -------------------------------------------------------------
% G Castegnetti --- start: 05/2019 --- last update 05/2019

clear
close all

restoredefaultpath, clear RESTOREDEFAULTPATH_EXECUTED

addpath('/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_out')
addpath('/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_routines')

foldersPrefix = '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_out/E0S135B0_Col_300ms_threat';

% Define parameters for megaa_balancedAccuracy to work
par.NumTrainBins = 100;
par.subs = [1:5 7:9 11:25];
par.NumNullEx = 0;

%% Load the three files corresponding to all probs and magns
% -------------------------------------------------------------
out1 = load([foldersPrefix,'Prob1/Out_S1_OptBin_Balanced.mat']);
out2 = load([foldersPrefix,'Prob2/Out_S1_OptBin_Balanced.mat']);
out3 = load([foldersPrefix,'Prob3/Out_S1_OptBin_Balanced.mat']);
outm0 = load([foldersPrefix,'Magn0/Out_S1_OptBin.mat']);
outm1 = load([foldersPrefix,'Magn1/Out_S1_OptBin.mat']);
outm2 = load([foldersPrefix,'Magn2/Out_S1_OptBin.mat']);
outm3 = load([foldersPrefix,'Magn3/Out_S1_OptBin.mat']);

%% Compute accuracy curve for every classifier
% -------------------------------------------------------------

% Single-subject accuracy
accuracy1 = megaa_balancedAccuracy(par,out1.Out_1);
accuracy2 = megaa_balancedAccuracy(par,out2.Out_1);
accuracy3 = megaa_balancedAccuracy(par,out3.Out_1);
accuracym0 = megaa_balancedAccuracy(par,outm0.Out_1);
accuracym1 = megaa_balancedAccuracy(par,outm1.Out_1);
accuracym2 = megaa_balancedAccuracy(par,outm2.Out_1);
accuracym3 = megaa_balancedAccuracy(par,outm3.Out_1);

% Average accuracy
accuracyAvg1 = nanmean(accuracy1.Col);
accuracyAvg2 = nanmean(accuracy2.Col);
accuracyAvg3 = nanmean(accuracy3.Col);
accuracyAvgm0 = nanmean(accuracym0.Col);
accuracyAvgm1 = nanmean(accuracym1.Col);
accuracyAvgm2 = nanmean(accuracym2.Col);
accuracyAvgm3 = nanmean(accuracym3.Col);

% SEM
accuracySem1 = nanstd(accuracy1.Col)/sqrt(length(par.subs));
accuracySem2 = nanstd(accuracy2.Col)/sqrt(length(par.subs));
accuracySem3 = nanstd(accuracy3.Col)/sqrt(length(par.subs));
accuracySemm0 = nanstd(accuracym0.Col)/sqrt(length(par.subs));
accuracySemm1 = nanstd(accuracym1.Col)/sqrt(length(par.subs));
accuracySemm2 = nanstd(accuracym2.Col)/sqrt(length(par.subs));
accuracySemm3 = nanstd(accuracym3.Col)/sqrt(length(par.subs));

%% Plot them
% -------------------------------------------------------------
x = 10:10:1000;
% x = x';

% Threat probability
% -------------------------------------------------------------
figure('color',[1 1 1])
plot(x,accuracyAvg1,'linewidth',2),hold on
plot(x,accuracyAvg2,'linewidth',2)
plot(x,accuracyAvg3,'linewidth',2)
jbfill(x,accuracyAvg1+accuracySem1,accuracyAvg1-accuracySem1,[0,0.4470,0.7410]); hold on
jbfill(x,accuracyAvg2+accuracySem2,accuracyAvg2-accuracySem2,[0.8500 0.3250 0.0980]); hold on
jbfill(x,accuracyAvg3+accuracySem3,accuracyAvg3-accuracySem3,[0.9290 0.6940 0.1250]); hold on
plot(x,0.5*ones(length(x),1),'color',[0.4 0.4 0.4],'linestyle','--','linewidth',1.5)
legend('Threat prob.: Low','Threat prob.: Med','Threat prob.: High')
set(gca,'FontSize',14)
xlabel('Time (ms)'), ylabel('Balanced accuracy')
ylim([0.48 0.70])
xlim([0 750])

% Threat magnitude
% -------------------------------------------------------------
% figure('color',[1 1 1])
% plot(x,accuracyAvgm0,'linewidth',2,'color',[0.75,0.75,0.75]),hold on
% plot(x,accuracyAvgm1,'linewidth',2,'color',[0.60,0.60,0.60])
% plot(x,accuracyAvgm2,'linewidth',2,'color',[0.45,0.45,0.45])
% plot(x,accuracyAvgm3,'linewidth',2,'color',[0.30,0.30,0.30])
% jbfill(x,accuracyAvgm0+accuracySemm0,accuracyAvgm0-accuracySemm0,[0.75,0.75,0.75]); hold on
% jbfill(x,accuracyAvgm1+accuracySemm1,accuracyAvgm1-accuracySemm1,[0.60,0.60,0.60]); hold on
% jbfill(x,accuracyAvgm2+accuracySemm2,accuracyAvgm2-accuracySemm2,[0.45,0.45,0.45]); hold on
% jbfill(x,accuracyAvgm3+accuracySemm3,accuracyAvgm3-accuracySemm3,[0.30,0.30,0.30]); hold on
% plot(x,0.5*ones(length(x),1),'color',[0.4 0.4 0.4],'linestyle','--','linewidth',1.5)
% legend('Threat magn. = 0','Threat magn. = 1','Threat magn. = 2','Threat magn. = 3')
% set(gca,'FontSize',14)
% xlabel('Time (ms)'), ylabel('Balanced accuracy')
% ylim([0.48 0.70])
% xlim([0 750])

figure('color',[1 1 1])
plot(x,accuracyAvgm0,'linewidth',2,'color',[0.75,0.75,0.75]),hold on
plot(x,accuracyAvgm1,'linewidth',2,'color',[0.45,0.45,0.45])
plot(x,accuracyAvgm2,'linewidth',2,'color',[0.15,0.15,0.15])
jbfill(x,accuracyAvgm0+accuracySemm0,accuracyAvgm0-accuracySemm0,[0.75,0.75,0.75]); hold on
jbfill(x,accuracyAvgm1+accuracySemm1,accuracyAvgm1-accuracySemm1,[0.45,0.45,0.45]); hold on
jbfill(x,accuracyAvgm2+accuracySemm2,accuracyAvgm2-accuracySemm2,[0.15,0.15,0.15]); hold on
plot(x,0.5*ones(length(x),1),'color',[0.4 0.4 0.4],'linestyle','--','linewidth',1.5)
legend('Threat magn. = 0','Threat magn. = 1','Threat magn. = 2')
set(gca,'FontSize',14)
xlabel('Time (ms)'), ylabel('Balanced accuracy')
ylim([0.48 0.70])
xlim([0 750])
