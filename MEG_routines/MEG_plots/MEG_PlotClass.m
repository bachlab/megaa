restoredefaultpath

clear
close all

% addpath D:\MATLAB\MATLAB_scripts\MEG\MEG_STEPs_outputs\EUGLO135\MEG_steps_outputs_3
% addpath D:\MATLAB\MATLAB_scripts\MEG\MEG_ROU_out\E0S275B50
addpath D:\MATLAB\MATLAB_scripts\MEG\MEG_ROU_out\E0S135B0_t300
folders.scan = 'D:\MATLAB\MATLAB_scripts\MEG\MEG_data\scanner\';
load('Out_S0_OptCha')
load('Out_S3_CreCla')
% load('Out_S0_OptCha')
% load('Out_S3_CreCla')

subs = [1:5 7:9 11:25];
Act_SS_Cau = zeros(275,23);
Act_SS_Col = zeros(275,23);
for s = 1:length(subs)
    Channels = Out_0.Chan_sub(:,s)-32;
    ClassCau = Out_3.OptClass{s}.Cau;
    ClassCol = Out_3.OptClass{s}.Col;
    UsedChanCau_idx = Channels(ClassCau ~= 0);
    UsedChanCol_idx = Channels(ClassCol ~= 0);
    UsedChanCau_val = ClassCau(ClassCau ~= 0);
    UsedChanCol_val = ClassCol(ClassCol ~= 0);
    Act_SS_Cau(UsedChanCau_idx,s) = UsedChanCau_val;
    Act_SS_Col(UsedChanCol_idx,s) = UsedChanCol_val;
end
Act_Mean_Cau = mean(Act_SS_Cau,2);
Act_Mean_Col = mean(Act_SS_Col,2);

file = [folders.scan,'MEG_sub_1\hpdspmmeg_sub_1_run_2.mat'];
load(file)

% plot
eye_x = [D.channels(:).X_plot2D]'; % x for scatter plot
eye_y = [D.channels(:).Y_plot2D]'; % y for scatter plot

%% cau
figure('color',[1 1 1]), title('Neg+')
% > 0
foo_Bx = eye_x(Act_Mean_Cau > 0);
foo_By = eye_y(Act_Mean_Cau > 0);
foo_Bd = Act_Mean_Cau(Act_Mean_Cau > 0);
for i = 1:length(foo_Bd)
    c = 1 - foo_Bd(i)*1/max(Act_Mean_Cau(Act_Mean_Cau > 0));
    scatter(foo_Bx(i), foo_By(i), 100, foo_Bd(i),'filled',...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[1 c c]),hold on
end

% < 0
foo_Sx = eye_x(Act_Mean_Cau <= 0);
foo_Sy = eye_y(Act_Mean_Cau <= 0);
foo_Sd = Act_Mean_Cau(Act_Mean_Cau <= 0);
for i = 1:length(foo_Sd)
    c = 1 + foo_Sd(i)*1/max(-Act_Mean_Cau(Act_Mean_Cau < 0));
    if isnan(c), keyboard, end
    scatter(foo_Sx(i), foo_Sy(i), 100, foo_Sd(i),'filled',...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[c c 1]),hold on
end
set(gca,'fontsize',14)


%% col
figure('color',[1 1 1]), title('Pos+')
% > 0
foo_Bx = eye_x(Act_Mean_Col > 0);
foo_By = eye_y(Act_Mean_Col > 0);
foo_Bd = Act_Mean_Col(Act_Mean_Col > 0);
for i = 1:length(foo_Bd)
    c = 1 - foo_Bd(i)*1/max(Act_Mean_Col(Act_Mean_Col > 0));
    scatter(foo_Bx(i), foo_By(i), 100, foo_Bd(i),'filled',...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[1 c c]),hold on
end

% < 0
foo_Sx = eye_x(Act_Mean_Col <= 0);
foo_Sy = eye_y(Act_Mean_Col <= 0);
foo_Sd = Act_Mean_Col(Act_Mean_Col <= 0);
for i = 1:length(foo_Sd)
    c = 1 + foo_Sd(i)*1/max(-Act_Mean_Col(Act_Mean_Col < 0));
    if isnan(c), keyboard, end
    scatter(foo_Sx(i), foo_Sy(i), 100, foo_Sd(i),'filled',...
        'MarkerEdgeColor',[0 0 0],...
        'MarkerFaceColor',[c c 1]),hold on
end
set(gca,'fontsize',14)
