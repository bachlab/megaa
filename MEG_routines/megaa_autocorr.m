function Out_AutoC = megaa_autocorr(par,In_5,idx)

%% import parameters
subs        = par.subs;
numTrials   = par.NumTrials;
numPerm     = par.NumPerm;
minDuration = par.deliberTime;
minDur_idx  = round(minDuration/10);

%% maximum time lag
lagMax = 400;
lagMaxIdx = round(lagMax/10);

%% autocorrelation and fft

In_5 = In_5.Out_4;

AutoC_avg = cell(length(subs),1);
for s = 1:length(subs)
    
    % update user
    disp(['sub#',num2str(subs(s))])
    
    % compute autocorrelation for every trial with real labels
    autocorr_trial_real = nan(numTrials,lagMaxIdx+1);
    for trl = 1:numTrials
        autocorr_trial_real(trl,:) = autocorr(In_5.PredCont{s}.Col(trl,1:minDur_idx),lagMaxIdx);
    end
    
    % prepare output
    if par.whichTpTrain < 100
        Out_AutoC.AutoC_Real{s}.Col = autocorr_trial_real(idx{s}(:,2) == par.whichTpTrain,:);
    elseif par.whichTmTrain < 100
        Out_AutoC.AutoC_Real{s}.Col = autocorr_trial_real(idx{s}(:,3) == par.whichTmTrain,:);
    else
        Out_AutoC.AutoC_Real{s}.Col = autocorr_trial_real;
    end
    
    % compute autocorrelation for every trial with permuted labels
    for p = 1:numPerm
        autocorr_trial_perm = NaN(numTrials,lagMaxIdx+1);
        for trl = 1:numTrials
            autocorr_trial_perm(trl,:) = autocorr(In_5.PredCont_perm{s,p}.Col(trl,1:minDur_idx),lagMaxIdx);
        end
        
        if par.whichTpTrain < 100
            Out_AutoC.AutoC_Perm{s,p}.Col = autocorr_trial_perm(idx{s}(:,2) == par.whichTpTrain,:);
        elseif par.whichTmTrain < 100
            Out_AutoC.AutoC_Perm{s,p}.Col = autocorr_trial_perm(idx{s}(:,3) == par.whichTmTrain,:);
        else
            Out_AutoC.AutoC_Perm{s,p}.Col = autocorr_trial_perm;
        end
    end
    
end


%% plot autocorrelation's dependence on conditions
% tsp = 10:10:LagMax;
% figure('color',[1 1 1])
% title('Potential loss'),set(gca,'fontsize',14)
% subplot(3,1,3),plot(tsp,[AutoC_Col_GoSort(2:end)' AutoC_Col_Stay(2:end)'],'linewidth',2)
% title('Approach/avoidance'),set(gca,'fontsize',14)
% subplot(3,1,1),plot(tsp,AutoC_Col_TL(2:end,:),'linewidth',2)
% title('Threat level'),set(gca,'fontsize',14)
% subplot(3,1,2),plot(tsp,AutoC_Col_PL(2:end,:),'linewidth',2)
% title('Potential loss'),set(gca,'fontsize',14)


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute distribution of epoch length vs null distribution %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% numTransitionsReal = NaN(numTrials,numel(subs));
% autocorr_trial_real = [];
% epochDur_Col_Perm = [];
% 
% subjPNRatio = [3;4.60256410256410;2.79365079365079;5.33333333333333;6.72549019607843;4.95833333333333;4.13483146067416;8.95238095238095;4.89090909090909;9.12500000000000;4.74683544303798;4.54166666666667;6;3.63636363636364;6.37777777777778;5.45205479452055;3.82692307692308;4.78313253012048;4.81481481481482;6.81967213114754;5.05194805194805;5.69565217391304;3.79545454545455];
% subjChance = (1./(subjPNRatio+1)).*subjPNRatio;
% 
% for s = 1:length(subs)
%     
%     % update user
%     disp(['sub#',num2str(subs(s))])
%     
%     % compute autocorrelation for every trial with real labels
%     for trl = 1:numTrials
%         
%         outcomeRepresented(In_5.PredCont{s}.Col(trl,1:minDur_idx) >= subjChance(s)) = 1;
%         outcomeRepresented(In_5.PredCont{s}.Col(trl,1:minDur_idx) <= subjChance(s)) = 0;
%         
%         % count connected components = 1
%         connComp = bwlabel(outcomeRepresented);
%         numConnComp = max(connComp);
%         for i = 1:numConnComp
%             epochLengthPos_1(i) = sum(connComp == i);
%         end
%         
%         % count connected components = 0
%         connComp = bwlabel(1-outcomeRepresented);
%         numConnComp = max(connComp);
%         for i = 1:numConnComp
%             epochLengthPos_0(i) = sum(connComp == i);
%         end
%         
%         autocorr_trial_real = [autocorr_trial_real; epochLengthPos_1'; epochLengthPos_0']; %#ok<*AGROW>
%     end
%     
%     % compute autocorrelation for every trial with permuted labels
%     for p = 1:numPerm
%         for trl = 1:numTrials
%             outcomeRepresentedPerm(In_5.PredCont_perm{s,p}.Col(trl,1:minDur_idx) >= subjChance(s)) = 1;
%             outcomeRepresentedPerm(In_5.PredCont_perm{s,p}.Col(trl,1:minDur_idx) < subjChance(s)) = 0;
%             
%             % count connected components = 1
%             connComp = bwlabel(outcomeRepresentedPerm);
%             numConnComp = max(connComp);
%             for i = 1:numConnComp
%                 epochLengthPos_1(i) = sum(connComp == i);
%             end
%             
%             % count connected components = 0
%             connComp = bwlabel(1-outcomeRepresentedPerm);
%             numConnComp = max(connComp);
%             for i = 1:numConnComp
%                 epochLengthPos_0(i) = sum(connComp == i);
%             end
%             epochDur_Col_Perm = [epochDur_Col_Perm; epochLengthPos_1'; epochLengthPos_0'];
%         end
%     end
%     
%     % number of transitions with real labels
%     for trl = 1:numTrials
%         outcomeRepresented(In_5.PredCont{s}.Col(trl,1:minDur_idx) >= subjChance(s)) = 1;
%         outcomeRepresented(In_5.PredCont{s}.Col(trl,1:minDur_idx) <= subjChance(s)) = 0;
%         transitions = diff(outcomeRepresented);
%         numTransitionsReal(trl,s) = sum(transitions ~= 0);
%     end
%     
%     % number of transitions with permuted labels
%     for p = 1:numPerm
%         for trl = 1:numTrials
%             outcomeRepresentedPerm(In_5.PredCont_perm{s,p}.Col(trl,1:minDur_idx) >= subjChance(s)) = 1;
%             outcomeRepresentedPerm(In_5.PredCont_perm{s,p}.Col(trl,1:minDur_idx) < subjChance(s)) = 0;
%             transitions = diff(outcomeRepresentedPerm);
%             numTransitionsPerm(trl,s,p) = sum(transitions ~= 0);
%         end
%     end
% end
% 
% 
% 
% figure('color',[1 1 1])
% h1 = histogram(autocorr_trial_real,'Normalization','probability'); hold on
% h2 = histogram(epochDur_Col_Perm,'Normalization','probability'); xlim([0,12])
% h1.BinWidth = 2;
% h2.BinWidth = 2;
% legend('Correct','Permuted'), legend boxoff
% xlabel('Epoch duration (ms)'), ylabel('Relative duration frequency')
% 
% set(gca,'fontsize',16)
% 
% % [h,p,ks2stat] = kstest2(epochDur_Col_Real,epochDur_Col_Perm);
% 
% numTransitionsReal_avg = mean(numTransitionsReal,1);
% numTransitionsPerm_avg = squeeze(mean(numTransitionsPerm,1));
% 
% for s = 1:23
%     largerThanChance(s) = sum(numTransitionsReal_avg(s) > numTransitionsPerm_avg(s,:));
% end
% 
% %% plot of transitions
% meansPerm = mean(numTransitionsPerm_avg,1);
% semReal = std(numTransitionsReal_avg)/sqrt(23);
% 
% figure('color',[1 1 1])
% scatter(1,mean(numTransitionsReal_avg),250,'MarkerEdgeColor',[0 0 0],...
%     'MarkerFaceColor',[0 0 0]), hold on
% scatter(2+0.07*randn(100,1),meansPerm,250,'marker','o','MarkerEdgeColor','none',...
%     'MarkerFaceColor',[0.6 0.6 0.6],'MarkerFaceAlpha',0.25)
% 
% errorbar(1,mean(numTransitionsReal_avg),semReal,'linestyle','none','color','k','linewidth',2.5,'capsize',0)
% 
% set(gca,'fontsize',18,'xtick',1:2,'xticklabels',{'Correct','Permuted'}),...
%     xlim([0 3]),ylim([25 55])
% ylabel('Transitions per trial')
% 
% 
