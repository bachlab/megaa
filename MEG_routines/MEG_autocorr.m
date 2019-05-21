function Out_AutoC = MEG_autocorr(set_par,In_5,idx)

%% import parameters
subs        = set_par.subs;
NumTrials   = set_par.NumTrials;
NumPerm     = set_par.NumPerm;
MinDuration = set_par.Epoch_Dur;
MinDur_idx  = round(MinDuration/10);

%% maximum time lag
LagMax = 400;
LagMaxIdx = round(LagMax/10);

%% autocorrelation and fft
% hReal  = figure('color',[1 1 1]);
% hPerm1 = figure('color',[1 1 1]);
% hPerm2 = figure('color',[1 1 1]);
% hPerm3 = figure('color',[1 1 1]);

AutoC_avg = cell(length(subs),1);
for s = 1:length(subs)
    
    % update user
    disp(['sub#',num2str(subs(s))])
    
    % compute autocorrelation for every trial with real labels
    epochDur_Col_Real = NaN(NumTrials,LagMaxIdx+1);
    for trl = 1:NumTrials
        epochDur_Col_Real(trl,:) = autocorr(In_5.PredCont{s}.Col(trl,1:MinDur_idx),LagMaxIdx);
    end
    
    % prepare output
    Out_AutoC.AutoC_Real{s}.Col = epochDur_Col_Real;
    
    % compute autocorrelation for every trial with permuted labels
    for p = 1:NumPerm
        AutoC_Col_Perm = NaN(NumTrials,LagMaxIdx+1);
        for trl = 1:NumTrials
            AutoC_Col_Perm(trl,:) = autocorr(In_5.PredCont_perm{s,p}.Col(trl,1:MinDur_idx),LagMaxIdx);
        end
        Out_AutoC.AutoC_Perm{s,p}.Col = AutoC_Col_Perm;
    end
    
    AutoC_avg{s}.Col.All      = mean(epochDur_Col_Real(idx{s}.All,:));
    AutoC_avg{s}.Col.GoSort   = mean(epochDur_Col_Real(idx{s}.Go.Sort,:));
    AutoC_avg{s}.Col.Stay     = mean(epochDur_Col_Real([idx{s}.Stay.Conds{:}],:));
    AutoC_avg{s}.Col.TL(:,1)  = mean(epochDur_Col_Real([idx{s}.Stay.Conds{1,:} idx{s}.Go.Conds{1,:}],:));
    AutoC_avg{s}.Col.TL(:,2)  = mean(epochDur_Col_Real([idx{s}.Stay.Conds{2,:} idx{s}.Go.Conds{2,:}],:));
    AutoC_avg{s}.Col.TL(:,3)  = mean(epochDur_Col_Real([idx{s}.Stay.Conds{3,:} idx{s}.Go.Conds{3,:}],:));
    AutoC_avg{s}.Col.PL(:,1)  = mean(epochDur_Col_Real([idx{s}.Stay.Conds{:,1} idx{s}.Go.Conds{:,1}],:),1);
    AutoC_avg{s}.Col.PL(:,2)  = mean(epochDur_Col_Real([idx{s}.Stay.Conds{:,2} idx{s}.Go.Conds{:,2}],:),1);
    AutoC_avg{s}.Col.PL(:,3)  = mean(epochDur_Col_Real([idx{s}.Stay.Conds{:,3} idx{s}.Go.Conds{:,3}],:),1);
    AutoC_avg{s}.Col.PL(:,4)  = mean(epochDur_Col_Real([idx{s}.Stay.Conds{:,4} idx{s}.Go.Conds{:,4}],:),1);
    AutoC_avg{s}.Col.PL(:,5)  = mean(epochDur_Col_Real([idx{s}.Stay.Conds{:,5} idx{s}.Go.Conds{:,5}],:),1);
    AutoC_avg{s}.Col.PL(:,6)  = mean(epochDur_Col_Real([idx{s}.Stay.Conds{:,6} idx{s}.Go.Conds{:,6}],:),1);
    
    %% plot SS mean autocorrelation
    tsp = 0:10:LagMax;
    %     figure(hReal)
    %     subplot(5,5,s),plot(tsp,AutoC_avg{s}.Cau.All,'linewidth',2,'color',[0.75 0.2 0.2]), hold on
    %     plot(tsp,AutoC_avg{s}.Col.All,'linewidth',2,'color',[0.2 0.2 0.75]), title(['sub#',num2str(subs(s))])
    %     ylim([-0.25 1])
    %
    %     figure(hPerm1)
    %     subplot(5,5,s),plot(tsp,mean(Out_AutoC.AutoC_Perm{s,13}.Cau(idx{s}.All,:)),'linewidth',2,'color',[0.75 0.2 0.2]), hold on
    %     plot(tsp,mean(Out_AutoC.AutoC_Perm{s,14}.Col(idx{s}.All,:)),'linewidth',2,'color',[0.2 0.2 0.75]), title(['sub#',num2str(subs(s))])
    %     ylim([-0.25 1])
    %
    %     figure(hPerm2)
    %     subplot(5,5,s),plot(tsp,mean(Out_AutoC.AutoC_Perm{s,54}.Cau(idx{s}.All,:)),'linewidth',2,'color',[0.75 0.2 0.2]), hold on
    %     plot(tsp,mean(Out_AutoC.AutoC_Perm{s,55}.Col(idx{s}.All,:)),'linewidth',2,'color',[0.2 0.2 0.75]), title(['sub#',num2str(subs(s))])
    %     ylim([-0.25 1])
    %
    %     figure(hPerm3)
    %     subplot(5,5,s),plot(tsp,mean(Out_AutoC.AutoC_Perm{s,96}.Cau(idx{s}.All,:)),'linewidth',2,'color',[0.75 0.2 0.2]), hold on
    %     plot(tsp,mean(Out_AutoC.AutoC_Perm{s,97}.Col(idx{s}.All,:)),'linewidth',2,'color',[0.2 0.2 0.75]), title(['sub#',num2str(subs(s))])
    %     ylim([-0.25 1])
    
    %% plot SS autocorrelation's dependence on conditions
    %     figure('color',[1 1 1])
    %     subplot(3,2,5),plot(tsp,[AutoC_avg{s}.Cau.GoSort', AutoC_avg{s}.Cau.Stay'],'linewidth',2),title('CAU')
    %     subplot(3,2,1),plot(tsp,AutoC_avg{s}.Cau.TL,'linewidth',2)
    %     subplot(3,2,3),plot(tsp,AutoC_avg{s}.Cau.PL,'linewidth',2)
    %     subplot(3,2,6),plot(tsp,[AutoC_avg{s}.Col.GoSort', AutoC_avg{s}.Col.Stay'],'linewidth',2),title('COL')
    %     subplot(3,2,2),plot(tsp,AutoC_avg{s}.Col.TL,'linewidth',2)
    %     subplot(3,2,4),plot(tsp,AutoC_avg{s}.Col.PL,'linewidth',2)
    
end

%% plot grand averages

AutoC_Col_GoSort = 0;
AutoC_Col_Stay = 0;
AutoC_Col_TL = 0;
AutoC_Col_PL = 0;

% sum single-subject averages to obtain grand average
for s = 1:length(subs)
    
    % autocorrelation
    AutoC_Col_GoSort = AutoC_Col_GoSort + AutoC_avg{s}.Col.GoSort/length(subs);
    AutoC_Col_Stay = AutoC_Col_Stay + AutoC_avg{s}.Col.Stay/length(subs);
    AutoC_Col_TL = AutoC_Col_TL + AutoC_avg{s}.Col.TL/length(subs);
    AutoC_Col_PL = AutoC_Col_PL + AutoC_avg{s}.Col.PL/length(subs);
    
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
numTransitionsReal = NaN(NumTrials,numel(subs));
epochDur_Col_Real = [];
epochDur_Col_Perm = [];

subjPNRatio = [3;4.60256410256410;2.79365079365079;5.33333333333333;6.72549019607843;4.95833333333333;4.13483146067416;8.95238095238095;4.89090909090909;9.12500000000000;4.74683544303798;4.54166666666667;6;3.63636363636364;6.37777777777778;5.45205479452055;3.82692307692308;4.78313253012048;4.81481481481482;6.81967213114754;5.05194805194805;5.69565217391304;3.79545454545455];
subjChance = (1./(subjPNRatio+1)).*subjPNRatio;

for s = 1:length(subs)
    
    % update user
    disp(['sub#',num2str(subs(s))])
    
    % compute autocorrelation for every trial with real labels
    for trl = 1:NumTrials
        
        outcomeRepresented(In_5.PredCont{s}.Col(trl,1:MinDur_idx) >= subjChance(s)) = 1;
        outcomeRepresented(In_5.PredCont{s}.Col(trl,1:MinDur_idx) <= subjChance(s)) = 0;
        
        % count connected components = 1
        connComp = bwlabel(outcomeRepresented);
        numConnComp = max(connComp);
        for i = 1:numConnComp
            epochLengthPos_1(i) = sum(connComp == i);
        end
        
        % count connected components = 0
        connComp = bwlabel(1-outcomeRepresented);
        numConnComp = max(connComp);
        for i = 1:numConnComp
            epochLengthPos_0(i) = sum(connComp == i);
        end
        
        epochDur_Col_Real = [epochDur_Col_Real; epochLengthPos_1'; epochLengthPos_0']; %#ok<*AGROW>
    end
    
    % compute autocorrelation for every trial with permuted labels
    for p = 1:NumPerm
        for trl = 1:NumTrials
            outcomeRepresentedPerm(In_5.PredCont_perm{s,p}.Col(trl,1:MinDur_idx) >= subjChance(s)) = 1;
            outcomeRepresentedPerm(In_5.PredCont_perm{s,p}.Col(trl,1:MinDur_idx) < subjChance(s)) = 0;
            
            % count connected components = 1
            connComp = bwlabel(outcomeRepresentedPerm);
            numConnComp = max(connComp);
            for i = 1:numConnComp
                epochLengthPos_1(i) = sum(connComp == i);
            end
            
            % count connected components = 0
            connComp = bwlabel(1-outcomeRepresentedPerm);
            numConnComp = max(connComp);
            for i = 1:numConnComp
                epochLengthPos_0(i) = sum(connComp == i);
            end
            epochDur_Col_Perm = [epochDur_Col_Perm; epochLengthPos_1'; epochLengthPos_0'];
        end
    end
    
    % number of transitions with real labels
    for trl = 1:NumTrials
        outcomeRepresented(In_5.PredCont{s}.Col(trl,1:MinDur_idx) >= subjChance(s)) = 1;
        outcomeRepresented(In_5.PredCont{s}.Col(trl,1:MinDur_idx) <= subjChance(s)) = 0;
        transitions = diff(outcomeRepresented);
        numTransitionsReal(trl,s) = sum(transitions ~= 0);
    end
    
    % number of transitions with permuted labels
    for p = 1:NumPerm
        for trl = 1:NumTrials
            outcomeRepresentedPerm(In_5.PredCont_perm{s,p}.Col(trl,1:MinDur_idx) >= subjChance(s)) = 1;
            outcomeRepresentedPerm(In_5.PredCont_perm{s,p}.Col(trl,1:MinDur_idx) < subjChance(s)) = 0;
            transitions = diff(outcomeRepresentedPerm);
            numTransitionsPerm(trl,s,p) = sum(transitions ~= 0);
        end
    end
end



figure('color',[1 1 1])
h1 = histogram(epochDur_Col_Real,'Normalization','probability'); hold on
h2 = histogram(epochDur_Col_Perm,'Normalization','probability'); xlim([0,12])
h1.BinWidth = 2;
h2.BinWidth = 2;
legend('Correct','Permuted'), legend boxoff
xlabel('Epoch duration (ms)'), ylabel('Relative duration frequency')

set(gca,'fontsize',16)

% [h,p,ks2stat] = kstest2(epochDur_Col_Real,epochDur_Col_Perm);

numTransitionsReal_avg = mean(numTransitionsReal,1);
numTransitionsPerm_avg = squeeze(mean(numTransitionsPerm,1));

for s = 1:23
    largerThanChance(s) = sum(numTransitionsReal_avg(s) > numTransitionsPerm_avg(s,:));
end

%% plot of transitions
meansPerm = mean(numTransitionsPerm_avg,1);
semReal = std(numTransitionsReal_avg)/sqrt(23);

figure('color',[1 1 1])
scatter(1,mean(numTransitionsReal_avg),250,'MarkerEdgeColor',[0 0 0],...
    'MarkerFaceColor',[0 0 0]), hold on
scatter(2+0.07*randn(100,1),meansPerm,250,'marker','o','MarkerEdgeColor','none',...
    'MarkerFaceColor',[0.6 0.6 0.6],'MarkerFaceAlpha',0.25)

errorbar(1,mean(numTransitionsReal_avg),semReal,'linestyle','none','color','k','linewidth',2.5,'capsize',0)

set(gca,'fontsize',18,'xtick',1:2,'xticklabels',{'Correct','Permuted'}),...
    xlim([0 3]),ylim([25 55])
ylabel('Transitions per trial')


