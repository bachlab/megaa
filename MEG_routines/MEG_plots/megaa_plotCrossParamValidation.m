%% megaa_plotCrossParamValidation
% -------------------------------------------------------------
% The accuracies plotted here are computed in megaa_optimiseLambda on the
% output from megaa_crossParamValidation
% G Castegnetti --- start: 07/2019 --- last update 07/2019

clear
close all

restoredefaultpath, clear RESTOREDEFAULTPATH_EXECUTED

probMean = [0.73;0.69;0.65];
magnMean = [0.6897; 0.6850; 0.6930; 0.6865; 0.6883; 0.6601];

probSem = 0.01*[3,3,2];
magnSem = 0.01*[3,2,2,2,3,3];

figure('color',[1 1 1])

subplot(1,2,1)
bar(probMean,'facecolor',[0.5 0.5 0.5]), set(gca,'fontsize',16),hold on
errorbar(1:3,probMean,probSem), ylim([0.5 0.8])
xlabel('Loss probability'), ylabel('Cross-classification accuracy')

subplot(1,2,2)
bar(magnMean,'facecolor',[0.5 0.5 0.5]), set(gca,'fontsize',16),hold on
errorbar(1:6,magnMean,magnSem), ylim([0.5 0.8])
xlabel('Loss magnitude'), ylabel('Cross-classification accuracy')