function Out_3 = MEG_2_OptLas(par,In)
% finds the time point of maximal accuracy for every classifier, then 
% optimises lasso coefficient at this time
% G Castegnetti 2017

subs = par.subs;
NullOnset = par.NullOnset;
NumNullEx = par.NumNullEx;
drawnow

% threshold (in time) from which to look for minimum
TimeOut_thh = 150;
TimeOut_thh_idx = round(TimeOut_thh/10);
TimeOut_SS = cell(length(subs),1);
TimeOut_All = [];

%% find movement times
% for s = 1:length(subs)
%     BehMat = In{s}.BehMat; % 1:#Tok 2:TokCollSoFar 3:TokDuration 4:PreTokTime 5:TokPos 6:FirstMovPos 7:FirstMovTime 8:MoveBack 9:Caught? 10:Collect?
%     TimeOut_SS{s} = BehMat(BehMat(:,8)>0,8) - BehMat(BehMat(:,8)>0,7);
%     TimeOut_All = [TimeOut_All;TimeOut_SS{s}]; %#ok<AGROW>
% end, clear s
% 
% % how many movements are longer than TimeOut_thh
% PctileLeft = sum(TimeOut_All > TimeOut_thh)/length(TimeOut_All);
% 
% % plot them
% figure('color',[1 1 1])
% histogram(TimeOut_All),hold on
% ylim([0 1000]),xlabel('Time outside safe place (ms)')
% stem(TimeOut_thh,2000,'linewidth',2,'linestyle','--','color','k')
% set(gca,'FontSize',14)
% title(['Presses left = ',num2str(100*PctileLeft),'%'])
% clear TimeOut_thh TimeOut_SS TimeOut_All PctileLeft

%% compute performance for every subject and classifier
Acc = MEG_1_PerBin(par,In);
x = 10:10:1000;
figure('color',[1 1 1])
for s = 1:length(subs)
    
    [~,idx_] = max(Acc.Cau(s,TimeOut_thh_idx:end) + Acc.Col(s,TimeOut_thh_idx:end));
    BestAcc_Cau(s) = TimeOut_thh_idx + idx_ - 1; %#ok<AGROW>
    BestAcc_Col(s) = TimeOut_thh_idx + idx_ - 1; %#ok<AGROW>
    
    % plot them
    subplot(ceil(sqrt(length(subs))),ceil(sqrt(length(subs))),s)
    plot(x,Acc.Cau(s,:),'linewidth',1.5,'color','r'),hold on
    plot(x,Acc.Col(s,:),'linewidth',1.5,'color','b')
    ylim([0.45 0.85])
end
    
%% compute average performance
Met_Cau_avg = nanmean(Acc.Cau);
Met_Col_avg = nanmean(Acc.Col);

%% compute sem
Met_Cau_sem = std(Acc.Cau)/sqrt(length(subs));
Met_Col_sem = std(Acc.Col)/sqrt(length(subs));

Met_Sum_avg = Met_Cau_avg/2 + Met_Col_avg/2;
[~, OptBin_shift] = max(Met_Sum_avg(TimeOut_thh_idx+1:end));
OptBin = TimeOut_thh_idx + OptBin_shift;
OptBin = par.timeBin;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mod. 11/09

% plot it
figure('color',[1 1 1])
plot(x,Met_Col_avg,'linewidth',2,'color','k'),hold on
% plot(x,Met_Col_avg,'linewidth',2,'color','k'),hold on
% plot(x,Met_Col_avg + Met_Col_sem,'linewidth',1,'color','k')
% plot(x,Met_Col_avg - Met_Col_sem,'linewidth',1,'color','k')

jbfill(x,Met_Col_avg+Met_Col_sem,Met_Col_avg-Met_Col_sem); hold on

% plot(x,Met_Sum_avg,'linewidth',2,'color','k','linestyle','--')
plot(x,0.5*ones(length(x),1),'color',[0.4 0.4 0.4],'linestyle','--','linewidth',1.5),hold on
% plot(x(OptBin),Met_Sum_avg(OptBin),'color','k','marker','x','markersize',25)
% plot(x(OptBin),Met_Cau_avg(OptBin),'color','r','marker','x','markersize',25)
% plot(x(OptBin),Met_Col_avg(OptBin),'color','b','marker','x','markersize',25)
set(gca,'FontSize',14)
% legend('Pos+','Neg+','Mean','Chance acc.','location','northeast')
xlabel('Time (ms)'), ylabel('Balanced accuracy')
ylim([0.48 0.70])
xlim([0 500])
clear x dev_Cau_avg dev_Col_avg OptBin_shift TimeOut_thh_idx dev_Sum_avg

%% optimise lasso
% lasso = [0.001:0.001:0.009 0.01:0.005:0.1]; % lasso coefficients to try %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mod. 30/08
lasso = [0.0005:0.0005:0.01]; % lasso coefficients to try %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mod. 30/08
parfor s = 1:length(subs)
    disp(['Sub#',int2str(s),' of ',int2str(length(subs)),'...']); % update user
    
    %% create X and Ys
    X_Real = squeeze(In{s}.d_Real(:,OptBin,In{s}.Design(:,1)))';    % sensor data at the outcome - Cau
    X_Base = In{s}.d_Base;                                          % sensor data at the baseline
    Y_Cau = [In{s}.Design(:,2); zeros(NumNullEx,1)];        % outcomes if Cau are positive examples
    Y_Col = [1-In{s}.Design(:,2); zeros(NumNullEx,1)];      % outcomes if Col are positive examples
    X = [X_Real; X_Base];
    
    %% regression
    [Cau{s}.Coeff,Cau{s}.FitInfo] = lassoglm(X,Y_Cau,'binomial','Alpha',1,'lambda',lasso,'CV',10); % regression with Cau positive examples
    [Col{s}.Coeff,Col{s}.FitInfo] = lassoglm(X,Y_Col,'binomial','Alpha',1,'lambda',lasso,'CV',10); % regression with Col positive examples

end

%% find optimal lambda and plot deviance
OptLasso_Cau = NaN(length(subs),1);
OptLasso_Col = NaN(length(subs),1);
figure('color',[1 1 1])
for s = 1:length(subs)
    
    % Cau training
    devs_Cau = Cau{s}.FitInfo.Deviance;
    [dev_Cau(s),loc_Cau] = min(devs_Cau); % find minimum deviance
    OptLasso_Cau(s) = lasso(loc_Cau); % find corresponding lambda
    
    % Col training
    devs_Col = Col{s}.FitInfo.Deviance;
    [dev_Col(s),loc_Col] = min(devs_Col);
    OptLasso_Col(s) = lasso(loc_Col);
    
    % plot
    subplot(5,5,s)
    plot(lasso,devs_Cau,'r'),hold on
    plot(lasso,devs_Col,'b')
    plot(lasso(loc_Cau),devs_Cau(loc_Cau),'marker','x','color','r')
    plot(lasso(loc_Col),devs_Col(loc_Col),'marker','x','color','b')
    xlim([lasso(1) lasso(end)])
    title(['sub #',num2str(subs(s))])
end
Out_3.OptLasso_Cau = OptLasso_Cau;
Out_3.OptLasso_Col = OptLasso_Col;
Out_3.OptDevia_Cau = dev_Cau;
Out_3.OptDevia_Col = dev_Col;
Out_3.Lambdas = lasso;
Out_3.OptBin = OptBin;


