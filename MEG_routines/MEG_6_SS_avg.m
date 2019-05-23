function SS_avg = MEG_6_SS_avg(set_par,In,In_2,idx,figs)
% G Castegnetti 09/01/2017
% Script to optimise classifier for a given subject. It includes count of
% eyeblinks to retain only 135 best sensors (Kurth-Nelson et al. 2016)

% minimum duration to retain a trial (ms)

MinDuration = set_par.deliberTime;
PredCont = In;

subs = set_par.subs; clear set
SS_avg = cell(length(subs),1);
for s = 1:length(subs)
    
    %% plot all trials
    if figs(1) == 10
        MEG_5_Plot_AllTrials(idx{s},PredCont{s}.Cau,PredCont{s}.Col); %#ok<*USENS>
    end
    
    %% plot single-subject averages
    MinDuration_idx = round(MinDuration/10);
    
    SS_avg{s}.Cau.All      = mean(PredCont{s}.Cau(idx{s}.All,1:MinDuration_idx));
    SS_avg{s}.Cau.GoSort   = mean(PredCont{s}.Cau(idx{s}.Go.Sort,1:MinDuration_idx));
    SS_avg{s}.Cau.Stay     = mean(PredCont{s}.Cau([idx{s}.Stay.Conds{:}],1:MinDuration_idx));
    SS_avg{s}.Cau.TL(:,1)  = mean(PredCont{s}.Cau([idx{s}.Stay.Conds{1,:} idx{s}.Go.Conds{1,:}],1:MinDuration_idx));
    SS_avg{s}.Cau.TL(:,2)  = mean(PredCont{s}.Cau([idx{s}.Stay.Conds{2,:} idx{s}.Go.Conds{2,:}],1:MinDuration_idx));
    SS_avg{s}.Cau.TL(:,3)  = mean(PredCont{s}.Cau([idx{s}.Stay.Conds{3,:} idx{s}.Go.Conds{3,:}],1:MinDuration_idx));
    SS_avg{s}.Cau.PL(:,1)  = mean(PredCont{s}.Cau([idx{s}.Stay.Conds{:,1} idx{s}.Go.Conds{:,1}],1:MinDuration_idx),1);
    SS_avg{s}.Cau.PL(:,2)  = mean(PredCont{s}.Cau([idx{s}.Stay.Conds{:,2} idx{s}.Go.Conds{:,2}],1:MinDuration_idx),1);
    SS_avg{s}.Cau.PL(:,3)  = mean(PredCont{s}.Cau([idx{s}.Stay.Conds{:,3} idx{s}.Go.Conds{:,3}],1:MinDuration_idx),1);
    SS_avg{s}.Cau.PL(:,4)  = mean(PredCont{s}.Cau([idx{s}.Stay.Conds{:,4} idx{s}.Go.Conds{:,4}],1:MinDuration_idx),1);
    SS_avg{s}.Cau.PL(:,5)  = mean(PredCont{s}.Cau([idx{s}.Stay.Conds{:,5} idx{s}.Go.Conds{:,5}],1:MinDuration_idx),1);
    SS_avg{s}.Cau.PL(:,6)  = mean(PredCont{s}.Cau([idx{s}.Stay.Conds{:,6} idx{s}.Go.Conds{:,6}],1:MinDuration_idx),1);
    
    SS_avg{s}.Col.All      = mean(PredCont{s}.Col(idx{s}.All,1:MinDuration_idx));
    SS_avg{s}.Col.GoSort   = mean(PredCont{s}.Col(idx{s}.Go.Sort,1:MinDuration_idx));
    SS_avg{s}.Col.Stay     = mean(PredCont{s}.Col([idx{s}.Stay.Conds{:}],1:MinDuration_idx));
%     figure,plot(SS_avg{s}.Col.Stay)
    SS_avg{s}.Col.TL(:,1)  = mean(PredCont{s}.Col([idx{s}.Stay.Conds{1,:} idx{s}.Go.Conds{1,:}],1:MinDuration_idx));
    SS_avg{s}.Col.TL(:,2)  = mean(PredCont{s}.Col([idx{s}.Stay.Conds{2,:} idx{s}.Go.Conds{2,:}],1:MinDuration_idx));
    SS_avg{s}.Col.TL(:,3)  = mean(PredCont{s}.Col([idx{s}.Stay.Conds{3,:} idx{s}.Go.Conds{3,:}],1:MinDuration_idx));
    SS_avg{s}.Col.PL(:,1)  = mean(PredCont{s}.Col([idx{s}.Stay.Conds{:,1} idx{s}.Go.Conds{:,1}],1:MinDuration_idx),1);
    SS_avg{s}.Col.PL(:,2)  = mean(PredCont{s}.Col([idx{s}.Stay.Conds{:,2} idx{s}.Go.Conds{:,2}],1:MinDuration_idx),1);
    SS_avg{s}.Col.PL(:,3)  = mean(PredCont{s}.Col([idx{s}.Stay.Conds{:,3} idx{s}.Go.Conds{:,3}],1:MinDuration_idx),1);
    SS_avg{s}.Col.PL(:,4)  = mean(PredCont{s}.Col([idx{s}.Stay.Conds{:,4} idx{s}.Go.Conds{:,4}],1:MinDuration_idx),1);
    SS_avg{s}.Col.PL(:,5)  = mean(PredCont{s}.Col([idx{s}.Stay.Conds{:,5} idx{s}.Go.Conds{:,5}],1:MinDuration_idx),1);
    SS_avg{s}.Col.PL(:,6)  = mean(PredCont{s}.Col([idx{s}.Stay.Conds{:,6} idx{s}.Go.Conds{:,6}],1:MinDuration_idx),1);
    
    tspan = 10:10:MinDuration;
    if figs(1) == 1
        figure('color',[1 1 1])
        subplot(3,2,1),plot(tspan,[SS_avg{s}.Cau.GoSort' SS_avg{s}.Cau.Stay'],'linewidth',2),title(['Sub#',num2str(subs(s)),' - CAU'])
        subplot(3,2,3),plot(tspan,SS_avg{s}.Cau.TL,'linewidth',2)
        subplot(3,2,5),plot(tspan,SS_avg{s}.Cau.PL,'linewidth',2)
        
        subplot(3,2,2),plot(tspan,[SS_avg{s}.Col.GoSort' SS_avg{s}.Col.Stay'],'linewidth',2),title(['Sub#',num2str(subs(s)),' - COL'])
        subplot(3,2,4),plot(tspan,SS_avg{s}.Col.TL,'linewidth',2)
        subplot(3,2,6),plot(tspan,SS_avg{s}.Col.PL,'linewidth',2)
    end
    
    %% movement latency
    MoveLats = In_2{s}.BehMat(:,7);
    
    for tl = 1:3
        for pl = 1:6
            MoveLat(tl,pl,s)  = mean(MoveLats([idx{s}.Go.Conds{tl,pl}]));
        end
    end
    
end

%% plot grand averages
Avg_Cau_GoSort = 0;
Avg_Cau_Stay = 0;
Avg_Cau_TL = 0;
Avg_Cau_PL = 0;
Avg_Col_All = 0;
Avg_Col_GoSort = 0;
Avg_Col_Stay = 0;
Avg_Col_TL = 0;
Avg_Col_PL = 0;

for s = 1:length(subs)
    Avg_Cau_GoSort = Avg_Cau_GoSort + SS_avg{s}.Cau.GoSort/length(subs);
    Avg_Cau_Stay = Avg_Cau_Stay + SS_avg{s}.Cau.Stay/length(subs);
    Avg_Cau_TL = Avg_Cau_TL + SS_avg{s}.Cau.TL/length(subs);
    Avg_Cau_PL = Avg_Cau_PL + SS_avg{s}.Cau.PL/length(subs);
    
    Avg_Col_All = Avg_Col_All + SS_avg{s}.Col.All/length(subs);
    Avg_Col_GoSort = Avg_Col_GoSort + SS_avg{s}.Col.GoSort/length(subs);
    Avg_Col_Stay = Avg_Col_Stay + SS_avg{s}.Col.Stay/length(subs);
    Avg_Col_TL = Avg_Col_TL + SS_avg{s}.Col.TL/length(subs);
    Avg_Col_PL = Avg_Col_PL + SS_avg{s}.Col.PL/length(subs);
end
if figs(2) == 1
    drawnow
    figure('color',[1 1 1])
    subplot(3,2,5),plot(tspan,[smooth(smooth(Avg_Cau_GoSort')), smooth(smooth(Avg_Cau_Stay'))],'linewidth',2)
    title('Neg+, Approach/avoidance'),set(gca,'fontsize',14), xlim([0 MinDuration]),ylim([0.30 0.41])
    set(gca,'xtick',0:200:1500)
    
    for i = 1:3, Avg_Cau_TL_s(:,i) =  smooth(smooth(Avg_Cau_TL(:,i))); end
    subplot(3,2,1),plot(tspan,Avg_Cau_TL_s,'linewidth',2)
    title('Neg+, Threat probability'),set(gca,'fontsize',14), xlim([0 MinDuration]),ylim([0.30 0.41])
    set(gca,'xtick',0:200:1500)
    
    for i = 1:6, Avg_Cau_PL_s(:,i) =  smooth(smooth(Avg_Cau_PL(:,i))); end
    subplot(3,2,3),plot(tspan,Avg_Cau_PL_s,'linewidth',2)
    title('Neg+, Threat magnitude'),set(gca,'fontsize',14), xlim([0 MinDuration]),ylim([0.30 0.41])
    set(gca,'xtick',0:200:1500)
    
    subplot(3,2,6),plot(tspan,[smooth(smooth(Avg_Col_GoSort')) smooth(smooth(Avg_Col_Stay'))],'linewidth',2)
    title('Pos+, Approach/avoidance'),set(gca,'fontsize',11), xlim([0 MinDuration])%,ylim([0.59 0.85])
    set(gca,'xtick',0:200:1500)
    
    for i = 1:3, Avg_Col_TL_s(:,i) =  smooth(smooth(Avg_Col_TL(:,i))); end
    subplot(3,2,2),plot(tspan,Avg_Col_TL_s,'linewidth',2)
    title('Pos+, Threat probability'),set(gca,'fontsize',11), xlim([0 MinDuration])%,ylim([0.59 0.85])
    set(gca,'xtick',0:200:1500)
    
    for i = 1:6, Avg_Col_PL_s(:,i) =  smooth(smooth(Avg_Col_PL(:,i))); end
    subplot(3,2,4),plot(tspan,Avg_Col_PL_s,'linewidth',2)
    title('Pos+, Threat magnitude'),set(gca,'fontsize',11), xlim([0 MinDuration])%,ylim([0.59 0.85])
    set(gca,'xtick',0:200:1500)

end
