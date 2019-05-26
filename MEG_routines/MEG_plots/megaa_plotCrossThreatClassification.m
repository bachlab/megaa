%% megaa_plotCrossThreatClassification
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


%% Load the files containing the F-values from the lme
% -------------------------------------------------------------
fValAll{1,1} = load([foldersPrefix,'Prob1/TrlSrt/from_R/tVal_realCol_11.mat']);
fValAll{1,2} = load([foldersPrefix,'Prob1/TrlSrt/from_R/tVal_realCol_12.mat']);
fValAll{1,3} = load([foldersPrefix,'Prob1/TrlSrt/from_R/tVal_realCol_13.mat']);
fValAll{2,1} = load([foldersPrefix,'Prob2/TrlSrt/from_R/tVal_realCol_21.mat']);
fValAll{2,2} = load([foldersPrefix,'Prob2/TrlSrt/from_R/tVal_realCol_22.mat']);
fValAll{2,3} = load([foldersPrefix,'Prob2/TrlSrt/from_R/tVal_realCol_23.mat']);
fValAll{3,1} = load([foldersPrefix,'Prob3/TrlSrt/from_R/tVal_realCol_31.mat']);
fValAll{3,2} = load([foldersPrefix,'Prob3/TrlSrt/from_R/tVal_realCol_32.mat']);
fValAll{3,3} = load([foldersPrefix,'Prob3/TrlSrt/from_R/tVal_realCol_33.mat']);


%% Plot them
% -------------------------------------------------------------
figure('color',[1 1 1])
x = 10:10:1500;
for i = 1:3
    for j = 1:3
        fVal{i,j} = smooth(fValAll{i,j}.x(1,:),8);
        subplot(3,3,3*(i-1)+j)
        rectangle('Position',[400 0.02 130 10],'FaceColor',[0.95 0.95 0.95],'linestyle','--'); hold on
        plot(x,fVal{i,j},'linewidth',2,'marker','.','linestyle','none','markersize',10)
        ylim([0 4.25]), xlim([0 1500])
        
        set(gca,'fontsize',12)
    end
end

% Plot also general one for comparison
% -------------------------------------------------------------



%% Plot them
% -------------------------------------------------------------
x = 10:10:1500;

% Threat probability
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
figure('color',[1 1 1])
plot(x,accuracyAvgm0,'linewidth',2,'color',[0.75,0.75,0.75]),hold on
plot(x,accuracyAvgm1,'linewidth',2,'color',[0.60,0.60,0.60])
plot(x,accuracyAvgm2,'linewidth',2,'color',[0.45,0.45,0.45])
plot(x,accuracyAvgm3,'linewidth',2,'color',[0.30,0.30,0.30])
jbfill(x,accuracyAvgm0+accuracySemm0,accuracyAvgm0-accuracySemm0,[0.75,0.75,0.75]); hold on
jbfill(x,accuracyAvgm1+accuracySemm1,accuracyAvgm1-accuracySemm1,[0.60,0.60,0.60]); hold on
jbfill(x,accuracyAvgm2+accuracySemm2,accuracyAvgm2-accuracySemm2,[0.45,0.45,0.45]); hold on
jbfill(x,accuracyAvgm3+accuracySemm3,accuracyAvgm3-accuracySemm3,[0.30,0.30,0.30]); hold on
plot(x,0.5*ones(length(x),1),'color',[0.4 0.4 0.4],'linestyle','--','linewidth',1.5)
legend('Threat magn. = 0','Threat magn. = 1','Threat magn. = 2','Threat magn. = 3')
set(gca,'FontSize',14)
xlabel('Time (ms)'), ylabel('Balanced accuracy')
ylim([0.48 0.70])
xlim([0 750])
