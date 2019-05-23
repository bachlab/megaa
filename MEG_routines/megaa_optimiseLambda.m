function out = megaa_optimiseLambda(par,In)
% finds the time point of maximal accuracy for every classifier, then 
% optimises lasso coefficient at this time
% G Castegnetti 2017

subs = par.subs;
numNullEx = par.NumNullEx;
drawnow

%% Compute and plot single-subject accuracy
% ----------------------------------------------------------------
balancedAcc = megaa_balancedAccuracy(par,In);
xspan = 10:10:1000;
figure('color',[1 1 1])
for s = 1:length(subs)
    
    % plot them
    subplot(ceil(sqrt(length(subs))),ceil(sqrt(length(subs))),s)
    plot(xspan,balancedAcc.Cau(s,:),'linewidth',1.5,'color','r'),hold on
    plot(xspan,balancedAcc.Col(s,:),'linewidth',1.5,'color','b')
    ylim([0.45 0.85])
end

%% Compute accuracy mean and SEM
% ----------------------------------------------------------------

accuracyAvg = nanmean(balancedAcc.Col);
accuracySem = nanstd(balancedAcc.Col)/sqrt(length(subs));

optBin = par.timeBin;

% plot it
figure('color',[1 1 1])
plot(xspan,accuracyAvg,'linewidth',2,'color','k'),hold on

jbfill(xspan,accuracyAvg+accuracySem,accuracyAvg-accuracySem); hold on

plot(xspan,0.5*ones(length(xspan),1),'color',[0.4 0.4 0.4],'linestyle','--','linewidth',1.5),hold on
set(gca,'FontSize',14)
xlabel('Time (ms)'), ylabel('Balanced accuracy')
ylim([0.48 0.70])
xlim([0 500])
clear x dev_Cau_avg dev_Col_avg OptBin_shift TimeOut_thh_idx dev_Sum_avg
keyboard

%% Run training at optimal bin with difference lambda coefficients
% ----------------------------------------------------------------
lasso = 0.0005:0.0005:0.01;
parfor s = 1:length(subs)
    
    disp(['Sub#',int2str(s),' of ',int2str(length(subs)),'...']); % update user
    
    % Prepare training data
    xReal = squeeze(In{s}.d_Real(:,optBin,In{s}.Design(:,1)))';    % sensor data at the outcome - Cau
    xBase = In{s}.d_Base;                                          % sensor data at the baseline
    yCau = [In{s}.Design(:,2); zeros(numNullEx,1)];        % outcomes if Cau are positive examples
    yCol = [1-In{s}.Design(:,2); zeros(numNullEx,1)];      % outcomes if Col are positive examples
    x = [xReal; xBase];
    
    % Cross-validated accuracy with each lambda
    [cau{s}.Coeff,cau{s}.FitInfo] = lassoglm(x,yCau,'binomial','Alpha',1,'lambda',lasso,'CV',10); % regression with Cau positive examples
    [col{s}.Coeff,col{s}.FitInfo] = lassoglm(x,yCol,'binomial','Alpha',1,'lambda',lasso,'CV',10); % regression with Col positive examples

end

%% Find optimal subjective lambda coefficient
% ----------------------------------------------------------------
optLasso_Cau = nan(length(subs),1);
optLasso_Col = nan(length(subs),1);
figure('color',[1 1 1])
for s = 1:length(subs)
    
    % Cau training
    devs_Cau = cau{s}.FitInfo.Deviance;
    [dev_Cau(s),loc_Cau] = min(devs_Cau); % find minimum deviance
    optLasso_Cau(s) = lasso(loc_Cau); % find corresponding lambda
    
    % Col training
    devs_Col = col{s}.FitInfo.Deviance;
    [dev_Col(s),loc_Col] = min(devs_Col);
    optLasso_Col(s) = lasso(loc_Col);
    
    % plot
    subplot(5,5,s)
    plot(lasso,devs_Cau,'r'),hold on
    plot(lasso,devs_Col,'b')
    plot(lasso(loc_Cau),devs_Cau(loc_Cau),'marker','x','color','r')
    plot(lasso(loc_Col),devs_Col(loc_Col),'marker','x','color','b')
    xlim([lasso(1) lasso(end)])
    title(['sub #',num2str(subs(s))])
end
out.OptLasso_Cau = optLasso_Cau;
out.OptLasso_Col = optLasso_Col;
out.OptDevia_Cau = dev_Cau;
out.OptDevia_Col = dev_Col;
out.Lambdas = lasso;
out.OptBin = optBin;


