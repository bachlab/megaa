%% MEGAA_main
% -------------------------------------------------------------
% Script with all the pipeline to produce the results presented in the AA MEG study
% Castegnetti et al. 2020
% -------------------------------------------------------------
% GX Castegnetti --- start 08/2016 --- last update 05/2019

clear
close all

restoredefaultpath, clear RESTOREDEFAULTPATH_EXECUTED
fs = filesep;

addpath('/Users/gcastegnetti/Desktop/tools/matlab/spm12')
addpath(genpath([pwd,fs,'MEG_routines']))


%% Analysis parameters
% -------------------------------------------------------------
param.NumSens = 135;    % How many sensors (with fewest eyeblink artefacts) to retain
param.ebCorr = 0;       % Correct eyeblink artefacts?
param.NumNullEx = 0;    % Number of null examples taken before trial onset.
param.timeBin = 30;
outOne = ['_Col_',num2str(param.timeBin*10),'ms_threatMagn3'];        % Which outcome to consider?
param.subs = [1:5 7:9 11:25]; % Subjects
% param.subs = [14:25]; % Subjects
param.NumRuns = 6;      % Number of experimental runs
param.NumTrials = 540;  % Number of trials per subject
param.NumPerm = 100;    % Number of permutations for statistical testing
param.NumTrainBins = 100; % Number of (10ms) time bins to consider after outcome presentation to define training set
param.NullOnset = 50;   % Where to take data for null examples
param.whichThreatProb = 100;
param.whichThreatMagn = 3;

% Select whether to align to token appearance (1) or trial start (2)
param.align = 2;
if param.align == 1
    param.deliberTime = 300;
elseif param.align == 2
    param.deliberTime = 1500;
end

% Select which steps to run
steps.preprocess = 0;
steps.corrEye = 0;
steps.cutEpoch = 0;
steps.findChan = 0;
steps.findBin = 1;
steps.findLasso = 1;
steps.createClass = 0;
steps.classify = 0;
steps.autocorr = 0;
steps.bf = 0;

%% Folders
% -------------------------------------------------------------

% create analysis folder
outFolder = [pwd,fs,'MEG_out',fs,'E',int2str(param.ebCorr),'S',int2str(param.NumSens),'B',int2str(param.NumNullEx),outOne];
mkdir([outFolder,fs,'TokApp'])
mkdir([outFolder,fs,'TrlSrt'])

% Select whether to take uncorrected data or data after eyeblink removal
if param.ebCorr == 0
    folders.scan = [pwd,fs,'MEG_data',fs,'imported',fs];
else
    folders.scan = [pwd,fs,'MEG_data',fs,'scanner_v2',fs];
end

% Folder with behavioural data
folders.beha = [pwd,fs,'MEG_data',fs,'behavioural',fs];


%% Preprocess raw data (import, downsample, HP filter)
% -------------------------------------------------------------
if steps.preprocess
    D_pre = preprocessing_MEG;
end


%% Correct eyeblinks artefacts if needed
% -------------------------------------------------------------
if param.ebCorr == 1 && steps.corrEye
    MEG_0_CorrectEyeBlinks(param,folders);
end


%% Cut epochs
% -------------------------------------------------------------
if steps.cutEpoch
    MEG_0_Epochs(param,folders);
end


%% Set channels to retain for the analysis
% -------------------------------------------------------------
file_0 = fullfile(outFolder,'Out_S0_channels');
if steps.findChan
    
    % if subset of channels, take those with least eyeblinks
    if param.NumSens < 275
        Out_0 = MEG_0_OptChan(param,folders);
        
        % otherwise take them all
    else
        Out_0.Chan_sub = repmat((33:307)',1,length(param.subs));
        Out_0.Chan_tot = repmat((33:307)',1,length(param.subs));
    end
    save(file_0,'Out_0')
end


%% Find time bin (after outcome presentation) for training data
% -------------------------------------------------------------
file_1 = fullfile(outFolder,'Out_S1_OptBin');
if steps.findBin
    if ~exist('Out_0','var'), load(file_0,'Out_0'), end
    Out_1 = megaa_cvPerformance(param,folders,Out_0);
    save(file_1,'Out_1','-v7.3')
end, clear Out_0


%% Find optimal lasso coefficient
% -------------------------------------------------------------
file_2 = fullfile(outFolder,'Out_S2_OptLas');
if steps.findLasso
    if ~exist('Out_1','var'), load(file_1,'Out_1'), end
    Out_2 = megaa_optimiseLambda(param,Out_1);
    save(file_2,'Out_2')
end


%% Create classifier
% -------------------------------------------------------------
file_3 = fullfile(outFolder,'Out_S3_CreCla');
if steps.createClass
    if ~exist('Out_1','var'), load(file_1,'Out_1'), end
    if ~exist('Out_2','var'), load(file_2,'Out_2'), end
    
    % Decide which script to use based on whether we include null examples
    if param.NumNullEx == 0
        Out_3 = MEG_3_CreCla(param,Out_1,Out_2);
    else
        Out_3 = MEG_3_CreClaVsBase(set_par,Out_1,Out_2);
    end
    save(file_3,'Out_3','-v7.3')
end, clear Out_2


%% Classify deliberation phase
% -------------------------------------------------------------
if param.align == 1
    AlFold = fullfile(outFolder,'/TokApp');
elseif param.align == 2
    AlFold = fullfile(outFolder,'/TrlSrt');
end
file_4 = fullfile(AlFold,'/Out_S4_AnaDel');
if steps.classify
    if ~exist('Out_1','var'), load(file_1,'Out_1'), end
    if ~exist('Out_3','var'), load(file_3,'Out_3'), end
    Out_4 = MEG_4_AnaDel(param,folders,Out_1,Out_3);
    save(file_4,'Out_4','-v7.3')
    MEG_4_PrepareInputLme(param,AlFold,Out_4);
end, clear Out_3


%% Beamformer
% -------------------------------------------------------------
if steps.bf
    megaa_bf_batch;
end
keyboard

%% separate conditions
% -------------------------------------------------------------
load(file_1,'Out_1')
file_lmeCond = fullfile(AlFold,'lmeCond');
[Out_5, lmeCond] = MEG_6_SepCon(param,folders,Out_1);
save(file_lmeCond,'lmeCond'), clear file_lmeCond


%% Statistics <------- make this code nicer
% -------------------------------------------------------------

% Load file containing (real) outcome probability during deliberation
load([AlFold,filesep,'lmeData',filesep,'lme_Real.mat'])

% Loop over deliberation time points
for i = 1:round(param.deliberTime/10)
    
    outProb = log(lme_Real.Col(:,i)./(1-lme_Real.Col(:,i)));
    outProb(outProb == Inf) = 100;
    %     outProb = R_Real.Col(:,i);
    
    % Create table suitable for lme
    %     ~isnan(lmeTab(:,7))
    lmeTab = array2table([outProb(~isnan(lmeCond(:,6))), lmeCond(~isnan(lmeCond(:,6)),:)]);
    lmeTab.Properties.VariableNames = {'outProb','sub','run','trial','lossProb','lossMagn','approach','prevOut','rt'};
    
    % Save matrix suitable for lme
    % lmeFile = fullfile(AlFold,'lmeData');
    % save(lmeFile,'lmeMat'), clear lmeFile
    
    mdlField = fitlme(lmeTab,'outProb ~ 1 + lossProb * lossMagn * approach');
    anovaMdl = anova(mdlField);
    
    t_lossProb(i) = anovaMdl.FStat(2);
    t_lossMagn(i) = anovaMdl.FStat(3);
    t_approach(i) = anovaMdl.FStat(4);
    
end, clear lmeMat lmeFile

figure('color',[1 1 1])


%% Behaviour <------- make this code nicer
% -------------------------------------------------------------
MEG_Behaviour(param,folders);


%% Autocorrelation
% -------------------------------------------------------------
if steps.autocorr
    if ~exist('Out_4','var'), load(file_4,'Out_4'), end
    if ~exist('Out_5','var'), load(file_5,'Out_5'), end
    Out_AutoC = MEG_autocorr(param,Out_4,Out_5);
    MEG_PermTest_AutoC(param,Out_AutoC);
end


%% compute single-subject averages with real and permuted labels
if ~exist('Out_4','var'), load(file_4,'Out_4'), end
if ~exist('Out_5','var'), load(file_5,'Out_5'), end
In = Out_4.PredCont;
Out_SSreal = MEG_6_SS_avg(param,In,Out_1,Out_5,[0 1]);
keyboard
for s = 1:length(param.subs)
    MeanReal_Col(s,:) = smooth(Out_SSreal{s}.Col.All); %#ok<SAGROW>
    MeanReal_Cau(s,:) = smooth(Out_SSreal{s}.Cau.All); %#ok<SAGROW>
end
Out_SSperm = cell(param.NumPerm,1);
for p = 1:param.NumPerm
    In_perm = Out_4.PredCont_perm(:,p);
    Out_SSperm{p} = MEG_6_SS_avg(param,In_perm,Out_1,Out_5,[0 0]);
    for s = 1:length(param.subs)
        foo_Col(s,:) = Out_SSperm{p}{s}.Col.All;
        foo_Cau(s,:) = Out_SSperm{p}{s}.Cau.All;
    end
    PermMeans_Col(p,:) = smooth(mean(foo_Col,1)); %#ok<SAGROW>
    PermMeans_Cau(p,:) = smooth(mean(foo_Cau,1)); %#ok<SAGROW>
end
figure('color',[1 1 1])
subplot(2,1,1),plot(PermMeans_Cau','color',[0 0 0]),hold on,plot(mean(MeanReal_Cau),'color',[0 0 1],'linewidth',2)
subplot(2,1,2),plot(PermMeans_Col','color',[0 0 0]),hold on,plot(mean(MeanReal_Col),'color',[0 0 1],'linewidth',2)

clear Out_5 Out_6
MEG_DataClusters(param,Out_SSreal,Out_SSperm)

%% cluster plot and analysis
MEG_7_PermTest

