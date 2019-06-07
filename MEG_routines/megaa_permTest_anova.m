%% Script to compute and plot the results of cluster analysis

clear
close all
restoredefaultpath

ProbClus = 0.95;

% addpath D:\MATLAB\MATLAB_scripts\MEG\MEG_STEPs_outputs\ECGLO135\MEG_OUT_B50\From_R
restoredefaultpath, clear RESTOREDEFAULTPATH_EXECUTED
addpath(genpath([pwd,filesep,'MEG_routines']))
addpath /Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_out/E0S135B100_Col_300ms/TrlSrt/From_R

%% Load F-values from lme in R
% --------------------------------------------
load('fVal_realCol.mat')
f_realCol = x;
load('fVal_realCau.mat')
f_realCau = x;
load('fVal_permCol.mat')
f_permCol = x;
load('fVal_permCau.mat')
f_permCau = x;
load('outR_df2.mat')
df2 = x;
xend = round(10*size(f_realCol,2));
xspan = 10:10:xend;

%% smooth F
% --------------------------------------------
for i = 1:size(f_realCol,1)
    f_realCol(i,:) = smooth(f_realCol(i,:));
    f_realCau(i,:) = smooth(f_realCau(i,:));
    for p = 1:size(f_permCol,3)
       f_permCol(i,:,p) = smooth(f_permCol(i,:,p));
       f_permCau(i,:,p) = smooth(f_permCau(i,:,p));
    end
end

%% Identify clusters
% --------------------------------------------

% find F-thresholds 
f_thr_TL = finv(ProbClus,2,df2);
f_thr_PL = finv(ProbClus,5,df2);
f_thr_GO = finv(ProbClus,1,df2);

% Cau
% --------------------------------------------

% Threat prob.
fstat = f_realCol(1,:);
fstatperm = squeeze(f_permCol(1,:,:))';
pcluster.Cau.TL = permtest(fstat, fstatperm, f_thr_TL);
signClusters.Cau.TL = pcluster.Cau.TL > 0.95;

% Threat magn.
fstat = f_realCol(2,:);
fstatperm = squeeze(f_permCol(2,:,:))';
pcluster.Cau.PL = permtest(fstat, fstatperm, f_thr_PL);
signClusters.Cau.PL = pcluster.Cau.PL > 0.95;

% Choice
fstat = f_realCol(3,:);
fstatperm = squeeze(f_permCol(3,:,:))';
pcluster.Cau.GO = permtest(fstat, fstatperm, f_thr_GO);
signClusters.Cau.GO = pcluster.Cau.GO > 0.95;

% Col
% --------------------------------------------

% Threat prob.
fstat = f_realCau(1,:);
fstatperm = squeeze(f_permCau(1,:,:))';
pcluster.Col.TL = permtest(fstat, fstatperm, f_thr_TL);
signClusters.Col.TL = pcluster.Col.TL > 0.95;

% Threat magn.
fstat = f_realCau(2,:);
fstatperm = squeeze(f_permCau(2,:,:))';
pcluster.Col.PL = permtest(fstat, fstatperm, f_thr_PL);
signClusters.Col.PL = pcluster.Col.PL > 0.95;

% Choice
fstat = f_realCau(3,:);
fstatperm = squeeze(f_permCau(3,:,:))';
pcluster.Col.GO = permtest(fstat, fstatperm, f_thr_GO);
signClusters.Col.GO = pcluster.Col.GO > 0.95;


%% plot Cau
h3 = figure('color',[1 1 1]);
subplot(3,2,1)
plot(xspan,f_realCol(1,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(signClusters.Cau.TL),f_realCol(1,signClusters.Cau.TL),'color','r','linestyle','none','marker','.','markersize',15)
title('N, Threat probability','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])

subplot(3,2,3)
plot(xspan,f_realCol(2,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(signClusters.Cau.PL),f_realCol(2,signClusters.Cau.PL),'color','r','linestyle','none','marker','.','markersize',15)
title('N, Threat magnitude','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])

subplot(3,2,5)
plot(xspan,f_realCol(3,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(signClusters.Cau.GO),f_realCol(3,signClusters.Cau.GO),'color','r','linestyle','none','marker','.','markersize',15)
title('N, Choice','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])


%% plot Col
subplot(3,2,2)
plot(xspan,f_realCau(1,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(signClusters.Col.TL),f_realCau(1,signClusters.Col.TL),'color','r','linestyle','none','marker','.','markersize',15)
title('P, Threat probability','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])

subplot(3,2,4)
plot(xspan,f_realCau(2,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(signClusters.Col.PL),f_realCau(2,signClusters.Col.PL),'color','r','linestyle','none','marker','.','markersize',15)
title('P, Threat magnitude','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])

subplot(3,2,6)
plot(xspan,f_realCau(3,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(signClusters.Col.GO),f_realCau(3,signClusters.Col.GO),'color','r','linestyle','none','marker','.','markersize',15)
title('P, Choice','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])


