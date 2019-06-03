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

spm eeg

%% Analysis parameters
% -------------------------------------------------------------
par.NumSens = 135;    % How many sensors (with fewest eyeblink artefacts) to retain
par.ebCorr = 0;       % Correct eyeblink artefacts?
par.NumNullEx = 50;    % Number of null examples taken before trial onset.
par.timeBin = 30;
par.subs = [1:5 7:9 11:25]; % Subjects
par.NumRuns = 6;      % Number of experimental runs
par.NumTrials = 540;  % Number of trials per subject
par.NumPerm = 100;    % Number of permutations for statistical testing
par.NumTrainBins = 100; % Number of (10ms) time bins to consider after Outcome presentation to define training set
par.NullOnset = 50;   % Where to take data for null examples
par.whichTpTrain = 100; % Which threat prob. to include for training (100 = all)
par.whichTmTrain = 100; % Which threat magn. to include for training (100 = all)

% Select whether to align to token appearance (1) or trial start (2)
par.align = 2;
if par.align == 1
    par.deliberTime = 300;
elseif par.align == 2
    par.deliberTime = 1500;
end

% Select which steps to run
steps.preprocess = 0;
steps.corrEye = 0;
steps.cutEpoch = 0;
steps.findChan = 0;
steps.findBin = 0;
steps.findLasso = 0;
steps.createClass = 0;
steps.classify = 0;
steps.autocorr = 0;
steps.bf = 1;

%% Folders
% -------------------------------------------------------------

% create analysis folder
if par.whichTpTrain < 100
    OutOne = ['_Col_',num2str(par.timeBin*10),'ms_threatProb',num2str(par.whichTpTrain)];
elseif par.whichTmTrain < 100
    OutOne = ['_Col_',num2str(par.timeBin*10),'ms_threatMagn',num2str(par.whichTmTrain)];
else
    OutOne = ['_Col_',num2str(par.timeBin*10),'ms'];
end
OutFolder = [pwd,fs,'MEG_Out',fs,'E',int2str(par.ebCorr),'S',int2str(par.NumSens),'B',int2str(par.NumNullEx),OutOne];
mkdir([OutFolder,fs,'TokApp'])
mkdir([OutFolder,fs,'TrlSrt'])

% Select whether to take uncorrected data or data after eyeblink removal
if par.ebCorr == 0
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
if par.ebCorr == 1 && steps.corrEye
    MEG_0_CorrectEyeBlinks(par,folders);
end


%% Cut epochs
% -------------------------------------------------------------
if steps.cutEpoch
    MEG_0_Epochs(par,folders);
end


%% Set channels to retain for the analysis
% -------------------------------------------------------------
file_0 = fullfile(OutFolder,'Out_S0_channels');
if steps.findChan
    
    % if subset of channels, take those with least eyeblinks
    if par.NumSens < 275
        Out_0 = megaa_findChannels(par,folders);
        
        % otherwise take them all
    else
        Out_0.Chan_sub = repmat((33:307)',1,length(par.subs));
        Out_0.Chan_tot = repmat((33:307)',1,length(par.subs));
    end
    save(file_0,'Out_0')
end


%% Find time bin (after outcome presentation) for training data
% -------------------------------------------------------------
file_1 = fullfile(OutFolder,'Out_S1_OptBin');
if steps.findBin
    if ~exist('Out_0','var'), load(file_0,'Out_0'), end
    Out_1 = megaa_cvPerformance(par,folders,Out_0);
    save(file_1,'Out_1','-v7.3')
end, clear Out_0


%% Find optimal lasso coefficient
% -------------------------------------------------------------
file_2 = fullfile(OutFolder,'Out_S2_OptLas');
if steps.findLasso
    if ~exist('Out_1','var'), load(file_1,'Out_1'), end
    Out_2 = megaa_optimiseLambda(par,Out_1);
    save(file_2,'Out_2')
end


%% Create classifier
% -------------------------------------------------------------
file_3 = fullfile(OutFolder,'Out_S3_CreCla');
if steps.createClass
    if ~exist('Out_1','var'), load(file_1,'Out_1'), end
    if ~exist('Out_2','var'), load(file_2,'Out_2'), end
    
    % Decide which script to use based on whether we include null examples
    if par.NumNullEx == 0
        Out_3 = megaa_createClassifier(par,Out_1,Out_2);
    else
        Out_3 = megaa_createClassifierBase(par,Out_1,Out_2);
    end
    save(file_3,'Out_3','-v7.3')
end, clear Out_2


%% Classify deliberation phase
% -------------------------------------------------------------
if par.align == 1
    alignmentFolder = fullfile(OutFolder,'/TokApp');
elseif par.align == 2
    alignmentFolder = fullfile(OutFolder,'/TrlSrt');
end
file_4 = fullfile(alignmentFolder,'/Out_S4_AnaDel');
if steps.classify
    if ~exist('Out_1','var'), load(file_1,'Out_1'), end
    if ~exist('Out_3','var'), load(file_3,'Out_3'), end
    Out_4 = megaa_classifyDelib(par,folders,Out_1,Out_3);
    save(file_4,'Out_4','-v7.3')
    MEG_4_PrepareInputLme(par,alignmentFolder,Out_4);
end, clear Out_3


%% Beamformer
% -------------------------------------------------------------
if steps.bf
    megaa_bf_batch;
end


%% Separate conditions
% -------------------------------------------------------------
load(file_1);
file_lmeCond = fullfile(alignmentFolder,'lmeCond');
[conds, lmeCond] = megaa_conditions(par,folders,Out_1);
save(file_lmeCond,'lmeCond'), clear file_lmeCond


%% Plot classified activity during deliberation
% -------------------------------------------------------------
Out_4 = load(file_4);
megaa_plotDelib(par,Out_4,conds);


%% Behaviour <------- make this code nicer
% -------------------------------------------------------------
% MEG_Behaviour(par,folders);


%% Autocorrelation
% -------------------------------------------------------------
if steps.autocorr
    if ~exist('Out_4','var'), load(file_4,'Out_4'), end
    if ~exist('Out_5','var'), load(file_5,'Out_5'), end
    Out_AutoC = MEG_autocorr(par,Out_4,conds);
    MEG_PermTest_AutoC(par,Out_AutoC);
end


%% compute single-subject averages with real and permuted labels
if ~exist('Out_4','var'), load(file_4,'Out_4'), end
if ~exist('Out_5','var'), load(file_5,'Out_5'), end
In = Out_4.PredCont;
Out_SSreal = MEG_6_SS_avg(par,In,Out_1,conds,[0 1]);


%% cluster plot and analysis
MEG_7_PermTest

