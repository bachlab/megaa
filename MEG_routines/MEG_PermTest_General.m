%% Script to compute and plot the results of cluster analysis

clear
% close all

ProbClus = 0.95;
restoredefaultpath
% addpath D:\MATLAB\MATLAB_scripts\MEG\MEG_STEPs_outputs\ECGLO135\MEG_OUT_B50\From_R
restoredefaultpath, clear RESTOREDEFAULTPATH_EXECUTED
addpath(genpath([pwd,filesep,'MEG_routines']))
addpath /Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_out/E0S135B0_Col_300ms/TrlSrt/From_R

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


