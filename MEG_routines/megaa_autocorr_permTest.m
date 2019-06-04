function megaa_autocorr_permTest(set_par,In_AutoC)

%% import parameters
subs = set_par.subs;
NumPerm = set_par.NumPerm;

%% import Real autocorrelation
for s = 1:length(subs)
    foo(s,:) = smooth(nanmean(In_AutoC.AutoC_Real{s}.Col,1)); %#ok<*AGROW>
end
autocorr_real = mean(foo,1);

%% import Perm autocorrelations
for p = 1:NumPerm
    for s = 1:length(subs)
        foo2(s,:) = smooth(nanmean(In_AutoC.AutoC_Perm{s,p}.Col,1));
    end
    autocorr_perm(p,:) = mean(foo2,1);
end

%%
percentile05 = prctile(autocorr_perm,5,1);
percentile95 = prctile(autocorr_perm,95,1);

% permutation test Col
NLLstat_Col = y_Col_real_NLL;
NLLstatperm_Col = y_Col_perm_NLL;
AutoC_Clu_Col = permtest(autocorr_real, autocorr_perm, 0.95);
AutoC_SignClu_Col = AutoC_Clu_Col > 0.95;

%% compute percentiles for display


xspan = 10:10:410;
xf = 4;

figure('color',[1 1 1])
plot(xspan(xf:end),autocorr_real(xf:end),'color','b','linewidth',2),hold on

jbfill(xspan(xf:end),LMM_Perm.Int.Col.p95(xf:end),LMM_Perm.Int.Col.p05(xf:end),'b','w'), hold on
plot(xspan(xf:end),zeros(numel(xspan(xf:end)),1),'color','k','linewidth',2,'linestyle','--')
xlabel('Lag (ms)'), ylabel('Autocorrelation')
ylim([-0.05 0.3]),xlim([30 300])
set(gca,'fontsize',16)
legend('a','b'), legend boxoff

keyboard



