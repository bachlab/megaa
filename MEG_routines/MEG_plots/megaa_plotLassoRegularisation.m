%% megaa_plotLassoRegularisation
% -------------------------------------------------------------
% G Castegnetti --- start: 07/2019 --- last update 07/2019

clear
close all

restoredefaultpath, clear RESTOREDEFAULTPATH_EXECUTED

optLasso = [0.0055;0.0055;0.0565;0.0080;0.0025;0.0045;0.0115;0.0035;0.0175;0.0040;0.0055;0.0055;0.0035;0.0060;0.0060;0.0155;0.0110;0.0055;0.0060;0.0045;0.0050;0.0055;0.0045];

figure('color',[1 1 1])
histogram(optLasso,23,'facecolor','k'), set(gca,'fontsize',16)
xlabel('Regularisation coefficient'), ylabel('Number of subjects')