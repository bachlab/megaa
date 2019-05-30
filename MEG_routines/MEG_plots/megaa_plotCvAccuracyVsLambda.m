% Load inputs
in010 = load('/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_out/E0S135B0_Col_300ms_lambda010/Out_S1_OptBin.mat');
in025 = load('/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_out/E0S135B0_Col_300ms/Out_S1_OptBin.mat');
in040 = load('/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_out/E0S135B0_Col_300ms_lambda040/Out_S1_OptBin.mat');

par.NumTrainBins = 100;
par.NumNullEx = 0;
par.subs = [1:5 7:9 11:25];

acc010 = megaa_balancedAccuracy(par,in010.Out_1);
acc025 = megaa_balancedAccuracy(par,in025.Out_1);
acc040 = megaa_balancedAccuracy(par,in040.Out_1);


%% Compute accuracy mean and SEM
% ----------------------------------------------------------------
accuracyAvg010 = nanmean(acc010.Col);
accuracySem010 = nanstd(acc010.Col)/sqrt(23);
accuracyAvg025 = nanmean(acc025.Col);
accuracySem025 = nanstd(acc025.Col)/sqrt(23);
accuracyAvg040 = nanmean(acc040.Col);
accuracySem040 = nanstd(acc040.Col)/sqrt(23);

% plot it
xspan = 10:10:1000;
figure('color',[1 1 1])

plot(xspan,accuracyAvg010,'linewidth',2,'color','k','linestyle','none','marker','o'),hold on
plot(xspan,accuracyAvg025,'linewidth',2,'color','k')
plot(xspan,accuracyAvg040,'linewidth',2,'color','k','linestyle','none','marker','*')
plot(xspan,0.5*ones(length(xspan),1),'color',[0.4 0.4 0.4],'linestyle','--','linewidth',1.5)

jbfill(xspan,accuracyAvg010+accuracySem010,accuracyAvg010-accuracySem010); hold on
jbfill(xspan,accuracyAvg025+accuracySem025,accuracyAvg025-accuracySem025); hold on
jbfill(xspan,accuracyAvg040+accuracySem040,accuracyAvg040-accuracySem040); hold on

set(gca,'FontSize',14)
xlabel('Time (ms)'), ylabel('Balanced accuracy')
ylim([0.48 0.75])
xlim([0 500])
legend('\lambda = 0.010','\lambda = 0.025','\lambda = 0.040','location','northwest'), legend boxoff
