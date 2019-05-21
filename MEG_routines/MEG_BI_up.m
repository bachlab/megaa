function MEG_BI_up(set_par,folders,In_1,In_4,In_5)

subs = set_par.subs;
TimeBins = round(set_par.Epoch_Dur/10);

% compute condition-specific mean
for s = 1:length(subs)
    
    bfile = [folders.beha,'AAA_05_MEG_Sno_',num2str(subs(s)),'.mat'];
    load(bfile,'game')
    if s ~= 2, game = game(37:end); end
    for trl = 1:set_par.NumTrials
        PL(trl) = game(trl).laststate.tokenloss; %#ok<AGROW>
        TL(trl) = game(trl).laststate.predno;  %#ok<AGROW>
    end
    
    trls_good = In_5{s}.Go.Sort;
    Lats_all{s} = [TL(trls_good)' PL(trls_good)' In_1{s}.BehMat(trls_good,7)];
    
    for tl = 1:3
        for pl = 0:5
            CondMean(tl,pl+1,s) = mean(Lats_all{s}(Lats_all{s}(:,1) == tl & Lats_all{s}(:,2) == pl,3));
        end
    end
    
end

% compute correlation
for s = 1:length(subs)
    Lats = In_1{s}.BehMat(In_5{s}.Go.Sort,7);
    Conds = Lats_all{s}(:,1:2);
    
    for trl = 1:length(Lats)
        Lats(trl) = Lats(trl) - CondMean(Conds(trl,1),Conds(trl,2)+1,s);
    end
    
    % real
    for t = 1:TimeBins
        N_real = In_4.PredCont{s}.Col(In_5{s}.Go.Sort,t);
%         [rfoo, pfoo] = corrcoef(Lats,N_real);
%         R_real(s,t) = rfoo(1,2);
        RegReal = polyfit(Lats,N_real,1);
        R_real(s,t) = RegReal(1);
%         p_real(s,t) = pfoo(1,2);
    end
    
    % perm
    for p = 1:100
        for t = 1:TimeBins
            N_perm = In_4.PredCont_perm{s,p}.Col(In_5{s}.Go.Sort,t);
%             [rfoo, pfoo] = corrcoef(Lats,N_perm);
%             R_perm(s,t,p) = rfoo(1,2);
            RegPerm = polyfit(Lats,N_real,1);
            R_perm(s,t,p) = RegPerm(1);
%             p_perm(s,t,p) = pfoo(1,2);
        end
    end
    s
end

% run ttest over correlation for each time after token appearance - real
for t = 1:TimeBins
    [~,t_p_real(t),~,stats] = ttest(R_real(:,t));
    t_t_real(t) = stats.tstat;
end
t_t_real = smooth(t_t_real)';
% run ttest over correlation for each time after token appearance - perm
for p = 1:100
    for t = 1:TimeBins
        [~,t_p_perm(t,p),~,stats] = ttest(R_perm(:,t,p));
        t_t_perm(t,p) = stats.tstat;
    end
    t_t_perm(:,p) = smooth(t_t_perm(:,p));
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
