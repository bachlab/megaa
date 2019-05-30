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

% Entire dataset
fValEntireData = load('/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_out/E0S135B0_Col_300ms/TrlSrt/from_R/fVal_realCol.mat');

% Cross-threat classification
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
figure('color',[1 1 1])
fValEntireData = smooth(fValEntireData.x(2,:),8);
rectangle('Position',[400 0.02 130 10],'FaceColor',[0.95 0.95 0.95],'linestyle','--'); hold on
plot(x,fValEntireData,'linewidth',2,'marker','.','linestyle','none','markersize',10)
ylim([0 4.5]), xlim([0 1500])
set(gca,'fontsize',12), ylabel('F-value (threat magn.)'), xlabel('Deliberation time after trial start (ms)')
