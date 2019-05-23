%% Script to compute and plot the results of cluster analysis

clear
% close all

ProbClus = 0.95;
restoredefaultpath
% addpath D:\MATLAB\MATLAB_scripts\MEG\MEG_STEPs_outputs\ECGLO135\MEG_OUT_B50\From_R
restoredefaultpath, clear RESTOREDEFAULTPATH_EXECUTED
addpath(genpath([pwd,filesep,'MEG_routines']))
addpath /Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_out/E0S135B0_Col_300ms_threatProb1/TrlSrt/From_R

load('R_out_Real_Cau')
F_Real_Cau = x;
load('R_out_Real_Col')
F_Real_Col = x;
load('R_out_Perm_Cau')
F_Perm_Cau = x;
load('R_out_Perm_Col')
F_Perm_Col = x;
load('R_out_df2')
df2 = x;
xend = round(10*size(F_Real_Cau,2));
xspan = 10:10:xend;

%% smooth F
for i = 1:size(F_Real_Cau,1)
    F_Real_Cau(i,:) = smooth(F_Real_Cau(i,:));
    F_Real_Col(i,:) = smooth(F_Real_Col(i,:));
    for p = 1:size(F_Perm_Cau,3)
       F_Perm_Cau(i,:,p) = smooth(F_Perm_Cau(i,:,p));
       F_Perm_Col(i,:,p) = smooth(F_Perm_Col(i,:,p));
    end
end

%% find clusters and correct from permutations

% find threasholds 
F_thr_TL = finv(ProbClus,2,df2);
F_thr_PL = finv(ProbClus,5,df2);
F_thr_GO = finv(ProbClus,1,df2);
F_thr_TL_PL = finv(ProbClus,10,df2);
F_thr_TL_GO = finv(ProbClus,2,df2);
F_thr_PL_GO = finv(ProbClus,5,df2);
F_thr_TL_PL_GO = finv(ProbClus,10,df2);

%% TL Cau
Fstat = F_Real_Cau(1,:);
Fstatperm = squeeze(F_Perm_Cau(1,:,:))';
pcluster.Cau.TL = permtest(Fstat, Fstatperm, F_thr_TL);
SignClusters.Cau.TL = pcluster.Cau.TL > 0.95;

%% PL Cau
Fstat = F_Real_Cau(2,:);
Fstatperm = squeeze(F_Perm_Cau(2,:,:))';
pcluster.Cau.PL = permtest(Fstat, Fstatperm, F_thr_PL);
SignClusters.Cau.PL = pcluster.Cau.PL > 0.95;

%% GO Cau
Fstat = F_Real_Cau(3,:);
Fstatperm = squeeze(F_Perm_Cau(3,:,:))';
pcluster.Cau.GO = permtest(Fstat, Fstatperm, F_thr_GO);
SignClusters.Cau.GO = pcluster.Cau.GO > 0.95;

%% TL:PL Cau
Fstat = F_Real_Cau(4,:);
Fstatperm = squeeze(F_Perm_Cau(4,:,:))';
pcluster.Cau.TL_PL = permtest(Fstat, Fstatperm, F_thr_TL_PL);
SignClusters.Cau.TL_PL = pcluster.Cau.TL_PL > 0.95;

%% TL:GO Cau
Fstat = F_Real_Cau(5,:);
Fstatperm = squeeze(F_Perm_Cau(5,:,:))';
pcluster.Cau.TL_GO = permtest(Fstat, Fstatperm, F_thr_TL_GO);
SignClusters.Cau.TL_GO = pcluster.Cau.TL_GO > 0.95;

%% PL:GO Cau
Fstat = F_Real_Cau(6,:);
Fstatperm = squeeze(F_Perm_Cau(6,:,:))';
pcluster.Cau.PL_GO = permtest(Fstat, Fstatperm, F_thr_PL_GO);
SignClusters.Cau.PL_GO = pcluster.Cau.PL_GO > 0.95;

%% TL:PL:GO Cau
Fstat = F_Real_Cau(7,:);
Fstatperm = squeeze(F_Perm_Cau(7,:,:))';
pcluster.Cau.TL_PL_GO = permtest(Fstat, Fstatperm, F_thr_TL_PL_GO);
SignClusters.Cau.TL_PL_GO = pcluster.Cau.TL_PL_GO > 0.95;

%% TL Col
Fstat = F_Real_Col(1,:);
Fstatperm = squeeze(F_Perm_Col(1,:,:))';
pcluster.Col.TL = permtest(Fstat, Fstatperm, F_thr_TL);
SignClusters.Col.TL = pcluster.Col.TL > 0.95;

%% PL Col
Fstat = F_Real_Col(2,:);
Fstatperm = squeeze(F_Perm_Col(2,:,:))';
pcluster.Col.PL = permtest(Fstat, Fstatperm, F_thr_PL);
SignClusters.Col.PL = pcluster.Col.PL > 0.95;

%% GO Col
Fstat = F_Real_Col(3,:);
Fstatperm = squeeze(F_Perm_Col(3,:,:))';
pcluster.Col.GO = permtest(Fstat, Fstatperm, F_thr_GO);
SignClusters.Col.GO = pcluster.Col.GO > 0.95;

%% TL:PL Col
Fstat = F_Real_Col(4,:);
Fstatperm = squeeze(F_Perm_Col(4,:,:))';
pcluster.Col.TL_PL = permtest(Fstat, Fstatperm, F_thr_TL_PL);
SignClusters.Col.TL_PL = pcluster.Col.TL_PL > 0.95;

%% TL:GO Col
Fstat = F_Real_Col(5,:);
Fstatperm = squeeze(F_Perm_Col(5,:,:))';
pcluster.Col.TL_GO = permtest(Fstat, Fstatperm, F_thr_TL_GO);
SignClusters.Col.TL_GO = pcluster.Col.TL_GO > 0.95;

%% PL:GO Col
Fstat = F_Real_Col(6,:);
Fstatperm = squeeze(F_Perm_Col(6,:,:))';
pcluster.Col.PL_GO = permtest(Fstat, Fstatperm, F_thr_PL_GO);
SignClusters.Col.PL_GO = pcluster.Col.PL_GO > 0.95;

%% TL:PL:GO Col
Fstat = F_Real_Col(7,:);
Fstatperm = squeeze(F_Perm_Col(7,:,:))';
pcluster.Col.TL_PL_GO = permtest(Fstat, Fstatperm, F_thr_TL_PL_GO);
SignClusters.Col.TL_PL_GO = pcluster.Col.TL_PL_GO > 0.95;

%% plot Cau

h3 = figure('color',[1 1 1]);
subplot(3,2,1),plot(xspan,F_Real_Cau(1,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Cau.TL),F_Real_Cau(1,SignClusters.Cau.TL),'color','r','linestyle','none','marker','.','markersize',15)
title('Neg+, Threat probability','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])
subplot(3,2,3),plot(xspan,F_Real_Cau(2,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Cau.PL),F_Real_Cau(2,SignClusters.Cau.PL),'color','r','linestyle','none','marker','.','markersize',15)
title('Neg+, Threat magnitude','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])
subplot(3,2,5),plot(xspan,F_Real_Cau(3,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Cau.GO),F_Real_Cau(3,SignClusters.Cau.GO),'color','r','linestyle','none','marker','.','markersize',15)
title('Neg+, Approach/avoidance','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])

h4 = figure('color',[1 1 1]);
subplot(4,2,1),plot(xspan,F_Real_Cau(4,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Cau.TL_PL),F_Real_Cau(4,SignClusters.Cau.TL_PL),'color','r','linestyle','none','marker','.','markersize',15)
title('Neg+, TL:PL','fontsize',12), set(gca,'fontsize',14), xlim([0 xend])
subplot(4,2,3),plot(xspan,F_Real_Cau(5,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Cau.TL_GO),F_Real_Cau(5,SignClusters.Cau.TL_GO),'color','r','linestyle','none','marker','.','markersize',15)
title('Neg+, TL:GO','fontsize',12), set(gca,'fontsize',14), xlim([0 xend])
subplot(4,2,5),plot(xspan,F_Real_Cau(6,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Cau.PL_GO),F_Real_Cau(6,SignClusters.Cau.PL_GO),'color','r','linestyle','none','marker','.','markersize',15)
title('Neg+, PL:GO','fontsize',12), set(gca,'fontsize',14), xlim([0 xend])
subplot(4,2,7),plot(xspan,F_Real_Cau(7,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Cau.TL_PL_GO),F_Real_Cau(7,SignClusters.Cau.TL_PL_GO),'color','r','linestyle','none','marker','.','markersize',15)
title('Neg+, TL:PL:GO','fontsize',12), set(gca,'fontsize',14), xlim([0 xend])

%% plot Col
figure(h3)
subplot(3,2,2),plot(xspan,F_Real_Col(1,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Col.TL),F_Real_Col(1,SignClusters.Col.TL),'color','r','linestyle','none','marker','.','markersize',15)
title('Pos+, Threat probability','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])
subplot(3,2,4),plot(xspan,F_Real_Col(2,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Col.PL),F_Real_Col(2,SignClusters.Col.PL),'color','r','linestyle','none','marker','.','markersize',15)
title('Pos+, Threat magnitude','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])
subplot(3,2,6),plot(xspan,F_Real_Col(3,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Col.GO),F_Real_Col(3,SignClusters.Col.GO),'color','r','linestyle','none','marker','.','markersize',15)
title('Pos+, Approach/avoidance','fontsize',14), set(gca,'fontsize',14), xlim([0 xend])

figure(h4)
subplot(4,2,2),plot(xspan,F_Real_Col(4,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Col.TL_PL),F_Real_Col(4,SignClusters.Col.TL_PL),'color','r','linestyle','none','marker','.','markersize',15)
title('Pos+, TL:PL','fontsize',12), set(gca,'fontsize',14), xlim([0 xend])
subplot(4,2,4),plot(xspan,F_Real_Col(5,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Col.TL_GO),F_Real_Col(5,SignClusters.Col.TL_GO),'color','r','linestyle','none','marker','.','markersize',15)
title('Pos+, TL:GO','fontsize',12), set(gca,'fontsize',14), xlim([0 xend])
subplot(4,2,6),plot(xspan,F_Real_Col(6,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Col.PL_GO),F_Real_Col(6,SignClusters.Col.PL_GO),'color','r','linestyle','none','marker','.','markersize',15)
title('Pos+, PL:GO','fontsize',12), set(gca,'fontsize',14), xlim([0 xend])
subplot(4,2,8),plot(xspan,F_Real_Col(7,:),'color','b','linestyle','none','marker','.','markersize',15),hold on
plot(xspan(SignClusters.Col.TL_PL_GO),F_Real_Col(7,SignClusters.Col.TL_PL_GO),'color','r','linestyle','none','marker','.','markersize',15)
title('Pos+, TL:PL:GO','fontsize',12), set(gca,'fontsize',14), xlim([0 xend])

