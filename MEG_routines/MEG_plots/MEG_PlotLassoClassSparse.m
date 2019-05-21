restoredefaultpath

clear
% close all

% addpath D:\MATLAB\MATLAB_scripts\MEG\MEG_STEPs_outputs\EUGLO135\MEG_steps_outputs_3
addpath D:\MATLAB\MATLAB_scripts\MEG\MEG_STEPs_outputs\EUGLO275\MEG_OUT_B50
% addpath D:\MATLAB\MATLAB_scripts\MEG\MEG_ROU_out\E0S275B50
load('Out_STEP3_OptLas')
% load('Out_S2_OptLas')

edges = 0:0.0025:0.05;
figure('color',[1 1 1])
subplot(2,2,1), histogram(Out_3.OptLasso_Col,edges), xlim([0 0.05]), ylim([0 15]), xlabel('Lasso coeff.')
set(gca,'fontsize',14)
subplot(2,2,3), histogram(Out_3.OptLasso_Cau,edges), xlim([0 0.05]), ylim([0 15]), xlabel('Lasso coeff.')
set(gca,'fontsize',14)

load('Out_STEP4_CreateClass')

for s = 1:23
    
    LL_ClassCol(s) = sum(Out_4.OptClass{s}.Col ~= 0);
    LL_ClassCau(s) = sum(Out_4.OptClass{s}.Cau ~= 0);
    
end

edges2 = 0:4:80;
subplot(2,2,2), histogram(LL_ClassCol,edges2,'facecolor',[0.99 0.36 0.2]), xlim([0 80]), ylim([0 6]), xlabel('Num. coeff. \neq 0')
set(gca,'fontsize',14)
subplot(2,2,4), histogram(LL_ClassCau,edges2,'facecolor',[0.99 0.36 0.2]), xlim([0 80]), ylim([0 6]), xlabel('Num. coeff. \neq 0')
set(gca,'fontsize',14)