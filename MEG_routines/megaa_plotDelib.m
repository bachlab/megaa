function megaa_plotDelib(par,data,conds)
%% Plots average reconstructed probabilities
% ----------------------------------------------------
% G Castegnetti --- start: 05/2019

whichTp = par.whichTpTrain;
delibTime = par.deliberTime;
subs = par.subs;


%% Loop over subjects
% ----------------------------------------------------
for s = 1:numel(subs)
    
    threatProb = conds{s}(:,2);
    if whichTp ~= 100
        trialsRetain = threatProb == whichTp;
    else
        trialsRetain = true(numel(threatProb));
    end
    
    conds{s}(~trialsRetain,:) = nan;
    
    choice = conds{s}(:,1);
    threatProb = conds{s}(:,2);
    threatMagn = conds{s}(:,3);
    
    % Take data
    % ----------------------------------------------------
    dataSub = [];
    try
        dataSub = data.out_4.PredCont{s}.Col;
    catch
        dataSub = data.Out_4.PredCont{s}.Col;
    end
    
    dataSub = [dataSub(:,1), dataSub(:,1), dataSub];
    for i = 1:540
        dataSub(i,:) = smooth(dataSub(i,:),8);
    end
    dataSub = dataSub(:,3:2+round(delibTime/10));
    
    
    
    % Divide conditions by threat probability
    % ----------------------------------------------------
    trls.tp1(s,:) = mean(dataSub(threatProb == 1,:),1);
    trls.tp2(s,:) = mean(dataSub(threatProb == 2,:),1);
    trls.tp3(s,:) = mean(dataSub(threatProb == 3,:),1);
    
    
    % Divide conditions by threat magnitude
    % ----------------------------------------------------
    trls.tm0(s,:) = mean(dataSub(threatMagn == 0,:),1);
    trls.tm1(s,:) = mean(dataSub(threatMagn == 1,:),1);
    trls.tm2(s,:) = mean(dataSub(threatMagn == 2,:),1);
    trls.tm3(s,:) = mean(dataSub(threatMagn == 3,:),1);
    trls.tm4(s,:) = mean(dataSub(threatMagn == 4,:),1);
    trls.tm5(s,:) = mean(dataSub(threatMagn == 5,:),1);
    
    
    % Divide conditions by choice
    % ----------------------------------------------------
    trls.go(s,:) = mean(dataSub(choice == 1,:),1);
    trls.stay(s,:) = mean(dataSub(choice == -1,:),1);
    
end

%% Plot
% ----------------------------------------------------
figure('color',[1 1 1])
xspan = 0:10:(delibTime-10);
lw = 2;

% Probability
% ----------------------------------------------------
subplot(3,1,1)

jbfill(xspan,mean(trls.tp1,1) + std(trls.tp1,1)/sqrt(23),...
    mean(trls.tp1,1) - std(trls.tp1,1)/sqrt(23),[0,0.4470,0.7410]); hold on
jbfill(xspan,mean(trls.tp2,1) + std(trls.tp2,1)/sqrt(23),...
    mean(trls.tp2,1) - std(trls.tp2,1)/sqrt(23),[0.8500 0.3250 0.0980]); hold on
jbfill(xspan,mean(trls.tp3,1) + std(trls.tp1,1)/sqrt(23),...
    mean(trls.tp3,1) - std(trls.tp3,1)/sqrt(23),[0.9290 0.6940 0.1250]); hold on

plot(xspan,mean(trls.tp1,1),'linewidth',lw,'color',[0,0.4470,0.7410])
plot(xspan,mean(trls.tp2,1),'linewidth',lw,'color',[0.8500,0.3250,0.0980])
plot(xspan,mean(trls.tp3,1),'linewidth',lw,'color',[0.9290 0.6940 0.1250])
set(gca,'fontsize',14,'xtick',0:300:1500), %ylim([0.76 0.86])
% Magnitude
% ----------------------------------------------------
subplot(3,1,2)

jbfill(xspan,mean(trls.tm0,1) + std(trls.tm0,1)/sqrt(23),...
    mean(trls.tm0,1) - std(trls.tm0,1)/sqrt(23),[0.80,0.80,0.80]); hold on
jbfill(xspan,mean(trls.tm1,1) + std(trls.tm1,1)/sqrt(23),...
    mean(trls.tm1,1) - std(trls.tm1,1)/sqrt(23),[0.60,0.60,0.60]); hold on
jbfill(xspan,mean(trls.tm2,1) + std(trls.tm2,1)/sqrt(23),...
    mean(trls.tm2,1) - std(trls.tm2,1)/sqrt(23),[0.45,0.45,0.45]); hold on
jbfill(xspan,mean(trls.tm3,1) + std(trls.tm3,1)/sqrt(23),...
    mean(trls.tm3,1) - std(trls.tm3,1)/sqrt(23),[0.30,0.30,0.30]); hold on
jbfill(xspan,mean(trls.tm4,1) + std(trls.tm4,1)/sqrt(23),...
    mean(trls.tm4,1) - std(trls.tm4,1)/sqrt(23),[0.15,0.15,0.15]); hold on
jbfill(xspan,mean(trls.tm5,1) + std(trls.tm5,1)/sqrt(23),...
    mean(trls.tm5,1) - std(trls.tm5,1)/sqrt(23),[0,0,0]); hold on

plot(xspan,mean(trls.tm0,1),'linewidth',lw,'color',[0.85,0.85,0.90])
plot(xspan,mean(trls.tm1,1),'linewidth',lw,'color',[0.60,0.60,0.65])
plot(xspan,mean(trls.tm2,1),'linewidth',lw,'color',[0.45,0.45,0.50])
plot(xspan,mean(trls.tm3,1),'linewidth',lw,'color',[0.30,0.30,0.35])
plot(xspan,mean(trls.tm4,1),'linewidth',lw,'color',[0.15,0.15,0.20])
plot(xspan,mean(trls.tm5,1),'linewidth',lw,'color',[0,0,0.05])
set(gca,'fontsize',14), %ylim([0.76 0.86])

% Choice
% ----------------------------------------------------
subplot(3,1,3)

jbfill(xspan,mean(trls.stay,1) + std(trls.stay,1)/sqrt(23),...
    mean(trls.stay,1) - std(trls.stay,1)/sqrt(23),[0.9,0,0]); hold on
jbfill(xspan,mean(trls.go,1) + std(trls.go,1)/sqrt(23),...
    mean(trls.go,1) - std(trls.go,1)/sqrt(23),[0,0,0.75]); hold on

plot(xspan,mean(trls.stay,1),'linewidth',lw,'color',[0.9,0,0])
plot(xspan,mean(trls.go,1),'linewidth',lw,'color',[0,0,0.75])
set(gca,'fontsize',14,'xtick',0:250:1500), %ylim([0.76 0.86])

keyboard
end
