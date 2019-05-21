function MEG_PermTest_AutoC(set_par,In_AutoC)

%% import parameters
subs = set_par.subs;
NumPerm = set_par.NumPerm;

%% import Real autocorrelation
for s = 1:length(subs)
    Real_AutoC_Col_foo(s,:) = smooth(mean(In_AutoC.AutoC_Real{s}.Col,1)); %#ok<*AGROW>
end
Real_AutoC_Col = mean(Real_AutoC_Col_foo,1);

%% import Perm autocorrelations
for p = 1:NumPerm
    for s = 1:length(subs)
        Perm_AutoC_Col_foo(s,:) = smooth(mean(In_AutoC.AutoC_Perm{s,p}.Col,1));
    end
    Perm_AutoC_Col(p,:) = mean(Perm_AutoC_Col_foo,1);
end

%% fit kernel distribution
for i = 1:size(Perm_AutoC_Col,2)
    KernDist_Col{i} = fitdist(Perm_AutoC_Col(:,i),'kernel');
end

figure('color',[1 1 1])
plot(Perm_AutoC_Col'),xlabel('lag'),ylabel('r')


xx = -0.5:0.001:1;

% Col real
for i = 1:size(Perm_AutoC_Col,2)
    foo = pdf(KernDist_Col{i},xx);
    foo = foo/sum(foo);
    [~,l] = min(abs(xx - Real_AutoC_Col(i)));
    y_Col_real(i) = sum(foo(l:end));
end
% transform to NLL - Col real
y_Col_real(y_Col_real > 0.5) = 1 - y_Col_real(y_Col_real > 0.5);
y_Col_real_NLL = -log(y_Col_real);

for p = 1:NumPerm
    disp(['Permutation #', num2str(p), ' of 100'])
    
    % Col
    AutoC_Perm_Col = Perm_AutoC_Col(p,:);
    for i = 1:size(Perm_AutoC_Col,2)
        foo = pdf(KernDist_Col{i},xx);
        foo = foo/sum(foo);
        [~,l] = min(abs(xx - AutoC_Perm_Col(i)));
        y_Col_perm(p,i) = sum(foo(l:end));
    end
end

% transform to NLL - Col perm
y_Col_perm(y_Col_perm > 0.5) = 1 - y_Col_perm(y_Col_perm > 0.5);
y_Col_perm_NLL = -log(y_Col_perm);

% permutation test Col
NLLstat_Col = y_Col_real_NLL;
NLLstatperm_Col = y_Col_perm_NLL;
AutoC_Clu_Col = permtest(NLLstat_Col, NLLstatperm_Col, 6);
AutoC_SignClu_Col = AutoC_Clu_Col > 0.95;

%% compute percentiles for display
LMM_Perm.Int.Col.p05 = prctile(Perm_AutoC_Col,5,1);
LMM_Perm.Int.Col.p95 = prctile(Perm_AutoC_Col,95,1);

xspan = 10:10:410;
xf = 4;

figure('color',[1 1 1])
plot(xspan(xf:end),Real_AutoC_Col(xf:end),'color','b','linewidth',2),hold on
jbfill(xspan(xf:end),LMM_Perm.Int.Col.p95(xf:end),LMM_Perm.Int.Col.p05(xf:end),'b','w'), hold on
plot(xspan(xf:end),zeros(numel(xspan(xf:end)),1),'color','k','linewidth',2,'linestyle','--')
xlabel('Lag (ms)'), ylabel('Autocorrelation')
ylim([-0.05 0.3]),xlim([30 300])
set(gca,'fontsize',16)
legend('a','b'), legend boxoff

keyboard



