function MEG_BI(set_par,In_1,In_4,In_5)

subs = set_par.subs;
TimeBins = round(set_par.Epoch_Dur/10);

% compute correlation
for s = 1:length(subs)
    Lats = In_1{s}.BehMat(In_5{s}.Go.Sort,7);
    
    % real
    for t = 1:TimeBins
        N_real = In_4.PredCont{s}.Col(In_5{s}.Go.Sort,t);
        [rfoo, pfoo] = corrcoef(Lats,N_real);
        R_real(s,t) = rfoo(1,2);
        p_real(s,t) = pfoo(1,2);
    end
    
    % perm
    for p = 1:100
        for t = 1:TimeBins
            N_perm = In_4.PredCont_perm{s,p}.Col(In_5{s}.Go.Sort,t);
            [rfoo, pfoo] = corrcoef(Lats,N_perm);
            R_perm(s,t,p) = rfoo(1,2);
            p_perm(s,t,p) = pfoo(1,2);
        end
    end
end

% run ttest over correlation for each time after token appearance - real
for t = 1:TimeBins
    [~,t_p_real(t),~,stats] = ttest(R_real(:,t));
    t_t_real(t) = stats.tstat;
end

% run ttest over correlation for each time after token appearance - perm
for p = 1:100
    for t = 1:TimeBins
        [~,t_p_perm(t,p),~,stats] = ttest(R_perm(:,t,p));
        t_t_perm(t,p) = stats.tstat;
    end
end

%% permutation test
pcluster_BI_p = permtest(t_t_real, t_t_perm', 2);
pcluster_BI_m = permtest(-t_t_real, -t_t_perm', 2);

%% plot
% t
xspan = 10:10:set_par.Epoch_Dur;
figure('color',[1 1 1]),
subplot(2,1,1)
plot(xspan,t_t_real,'.','markersize',30), hold on
plot(xspan(pcluster_BI_p > 0.95),t_t_real(pcluster_BI_p > 0.95),'.','markersize',30,'color','r')
plot(xspan(pcluster_BI_m > 0.95),t_t_real(pcluster_BI_m > 0.95),'.','markersize',30,'color','k')
set(gca,'fontsize',14)
subplot(2,1,2)
plot(xspan,R_real,'linewidth',2)
set(gca,'fontsize',14)

keyboard
