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
    try
        dataSub = data.out_4.PredCont{s}.Col(:,1:round(delibTime/10));
    catch
        dataSub = data.Out_4.PredCont{s}.Col(:,1:round(delibTime/10));
    end
    
    % Divide conditions by threat probability
    % ----------------------------------------------------
    trls.tp1(s,:) = smooth(mean(dataSub(threatProb == 1,:),1),10);
    trls.tp2(s,:) = smooth(mean(dataSub(threatProb == 2,:),1),10);
    trls.tp3(s,:) = smooth(mean(dataSub(threatProb == 3,:),1),10);
    
    
    % Divide conditions by threat magnitude
    % ----------------------------------------------------
    trls.tm0(s,:) = smooth(mean(dataSub(threatMagn == 0,:),1),10);
    trls.tm1(s,:) = smooth(mean(dataSub(threatMagn == 1,:),1),10);
    trls.tm2(s,:) = smooth(mean(dataSub(threatMagn == 2,:),1),10);
    trls.tm3(s,:) = smooth(mean(dataSub(threatMagn == 3,:),1),10);
    trls.tm4(s,:) = smooth(mean(dataSub(threatMagn == 4,:),1),10);
    trls.tm5(s,:) = smooth(mean(dataSub(threatMagn == 5,:),1),10);
    
    
    % Divide conditions by choice
    % ----------------------------------------------------
    trls.go(s,:) = smooth(mean(dataSub(choice == 1,:),1),10);
    trls.stay(s,:) = smooth(mean(dataSub(choice == -1,:),1),10);
    
end

%% Plot
% ----------------------------------------------------
figure('color',[1 1 1])
xspan = 10:10:1500;


% Probability
% ----------------------------------------------------
subplot(3,1,1)

jbfill(xspan,mean(trls.tp1,1) + std(trls.tp1,1)/sqrt(23),...
    mean(trls.tp1,1) - std(trls.tp1,1)/sqrt(23),[0,0.4470,0.7410]); hold on
jbfill(xspan,mean(trls.tp2,1) + std(trls.tp2,1)/sqrt(23),...
    mean(trls.tp2,1) - std(trls.tp2,1)/sqrt(23),[0.8500 0.3250 0.0980]); hold on
jbfill(xspan,mean(trls.tp3,1) + std(trls.tp1,1)/sqrt(23),...
    mean(trls.tp3,1) - std(trls.tp3,1)/sqrt(23),[0.9290 0.6940 0.1250]); hold on

plot(xspan,mean(trls.tp1,1),'linewidth',2,'color',[0,0.4470,0.7410])
plot(xspan,mean(trls.tp2,1),'linewidth',2,'color',[0.8500,0.3250,0.0980])
plot(xspan,mean(trls.tp3,1),'linewidth',2,'color',[0.9290 0.6940 0.1250])
set(gca,'fontsize',14), ylim([0.77 0.85])

% Magnitude
% ----------------------------------------------------
subplot(3,1,2)

jbfill(xspan,mean(trls.tm0,1) + std(trls.tm0,1)/sqrt(23),...
    mean(trls.tm0,1) - std(trls.tm0,1)/sqrt(23),[0.75,0.75,0.75]); hold on
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

plot(xspan,mean(trls.tm0,1),'linewidth',2,'color',[0.8,0.8,0.8])
plot(xspan,mean(trls.tm1,1),'linewidth',2,'color',[0.60,0.60,0.60])
plot(xspan,mean(trls.tm2,1),'linewidth',2,'color',[0.45,0.45,0.45])
plot(xspan,mean(trls.tm3,1),'linewidth',2,'color',[0.30,0.30,0.30])
plot(xspan,mean(trls.tm4,1),'linewidth',2,'color',[0.15,0.15,0.15])
plot(xspan,mean(trls.tm5,1),'linewidth',2,'color',[0,0,0])
set(gca,'fontsize',14), ylim([0.77 0.85])

% Choice
% ----------------------------------------------------
subplot(3,1,3)

jbfill(xspan,mean(trls.stay,1) + std(trls.stay,1)/sqrt(23),...
    mean(trls.stay,1) - std(trls.stay,1)/sqrt(23),[0.9,0,0]); hold on
jbfill(xspan,mean(trls.go,1) + std(trls.go,1)/sqrt(23),...
    mean(trls.go,1) - std(trls.go,1)/sqrt(23),[0,0,0.75]); hold on

plot(xspan,mean(trls.stay,1),'linewidth',2,'color',[0.9,0,0])
plot(xspan,mean(trls.go,1),'linewidth',2,'color',[0,0,0.75])
set(gca,'fontsize',14), ylim([0.77 0.85])

keyboard
end
