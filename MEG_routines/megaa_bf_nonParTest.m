%% megaa_nonParamTestBF.m
% ---
% GX Castegnetti --- 2018

clear
close all
% restoredefaultpath

addpath('/Users/gcastegnetti/Desktop/tools/matlab/spm12')
addpath(genpath('/Users/gcastegnetti/Desktop/stds/DRE/codes/fmri/rsa/rsatoolbox'))

spm eeg

%% analysisName
analysisName = 'rsa_sl_ima';

%%%%%%%%%%
% define %
%%%%%%%%%%

dirData = '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/bf/freq1-49';

% output directory
dirOut = [dirData,filesep,'clusterAnalysis'];
job{1}.spm.tools.snpm.des.OneSampT.dir = {dirOut};

% files
d = spm_select('List', dirData, '^mv.*\.nii$');
files  = cellstr([repmat([dirData filesep],size(d,1),1) d]);
job{1}.spm.tools.snpm.des.OneSampT.P = files;

% cluster inference
job{1}.spm.tools.snpm.des.OneSampT.bVolm = 1;
%     job{1}.spm.tools.snpm.des.OneSampT.ST.ST_later = -1;

% defaults
job{1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
job{1}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
job{1}.spm.tools.snpm.des.OneSampT.cov = struct('c', {}, 'cname', {});
job{1}.spm.tools.snpm.des.OneSampT.nPerm = 1000;
job{1}.spm.tools.snpm.des.OneSampT.vFWHM = [0 0 0];
job{1}.spm.tools.snpm.des.OneSampT.masking.tm.tm_none = 1;
job{1}.spm.tools.snpm.des.OneSampT.masking.im = 1;
job{1}.spm.tools.snpm.des.OneSampT.ST.ST_U = 0.00001;
job{1}.spm.tools.snpm.des.OneSampT.masking.em = {''};
job{1}.spm.tools.snpm.des.OneSampT.globalc.g_omit = 1;
job{1}.spm.tools.snpm.des.OneSampT.globalm.gmsca.gmsca_no = 1;
job{1}.spm.tools.snpm.des.OneSampT.globalm.glonorm = 1;

% run job
spm_jobman('run',job)
clear job

%%%%%%%%%%%
% compute %
%%%%%%%%%%%

job{1}.spm.tools.snpm.cp.snpmcfg = {[dirOut,filesep,'SnPMcfg.mat']};

% run job
spm_jobman('run',job)
clear job

%%%%%%%%%%%%%
% inference %
%%%%%%%%%%%%%
job{1}.spm.tools.snpm.inference.SnPMmat = cellstr([dirOut,filesep,'SnPM.mat']);
job{1}.spm.tools.snpm.inference.Thr.Clus.ClusSize.CFth = nan;
job{1}.spm.tools.snpm.inference.Thr.Clus.ClusSize.ClusSig.FWEthC = 0.05;
%         job{1}.spm.tools.snpm.inference.Thr.Clus.ClusSize.ClusSig.PthC = 0.15;
job{1}.spm.tools.snpm.inference.Tsign = 1;
job{1}.spm.tools.snpm.inference.WriteFiltImg.name = '_SnPM_filtered';
job{1}.spm.tools.snpm.inference.Report = 'MIPtable';

% run job
spm_jobman('run',job)
clear job

