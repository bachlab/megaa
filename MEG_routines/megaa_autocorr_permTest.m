function megaa_autocorr_permTest(set_par,In_AutoC)

%% import parameters
subs = set_par.subs;
NumPerm = set_par.NumPerm;

%% import Real autocorrelation
for s = 1:length(subs)
    foo(s,:) = smooth(nanmean(In_AutoC.AutoC_Real{s}.Col,1)); %#ok<*AGROW>
end
autocorr_real = mean(foo,1);
autocorr_real_std = std(foo,1)/sqrt(23);

%% import Perm autocorrelations
for p = 1:NumPerm
    for s = 1:length(subs)
        foo2(s,:) = smooth(nanmean(In_AutoC.AutoC_Perm{s,p}.Col,1));
    end
    autocorr_perm(p,:) = nanmean(foo2,1);
end

percentile05 = prctile(autocorr_perm,2.5,1);
percentile95 = prctile(autocorr_perm,97.5,1);

%% fit kernel distribution
for i = 1:size(autocorr_perm,2)
    KernDist_Col{i} = fitdist(autocorr_perm(:,i),'kernel');
end

figure('color',[1 1 1])
plot(autocorr_perm'),xlabel('lag'),ylabel('r')

xx = -0.5:0.001:1;

% Col real
for i = 1:size(autocorr_perm,2)
    foo = pdf(KernDist_Col{i},xx);
    foo = foo/sum(foo);
    [~,l] = min(abs(xx - autocorr_real(i)));
    y_Col_real(i) = sum(foo(l:end));
end
% transform to NLL - Col real
y_Col_real(y_Col_real > 0.5) = 1 - y_Col_real(y_Col_real > 0.5);
y_Col_real_NLL = -log(y_Col_real);

for p = 1:NumPerm
    disp(['Permutation #', num2str(p), ' of 100'])
    
    % Col
    AutoC_Perm_Col = autocorr_perm(p,:);
    for i = 1:size(autocorr_perm,2)
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

% keyboard
xspan = 10:10:410;
xf = 4;

figure('color',[1 1 1])
plot(xspan(xf:end),autocorr_real(xf:end),'color',[0,0,102]/255,'linewidth',2),hold on

jbfill(xspan(xf:end),percentile95(xf:end),percentile05(xf:end),'b','w'), hold on
plot(xspan(xf:end),zeros(numel(xspan(xf:end)),1),'color','k','linewidth',2,'linestyle','--')
xlabel('Lag (ms)'), ylabel('Autocorrelation')
ylim([-0.1 0.3]),xlim([30 400])
set(gca,'fontsize',16)
legend('a','b'), legend boxoff

% v2
xspan = 10:10:410;
xf = 3;

figure('color',[1 1 1]), hold on
for p = 1:100
    hPlot = plot(xspan(xf:end),autocorr_perm(p,xf:end),'color',[0.75 0.75 0.75],'linewidth',3);
    hPlot.Color(4) = 0.1;
end
jbfill(xspan(xf:end),autocorr_real(xf:end) + autocorr_real_std(xf:end),autocorr_real(xf:end) - autocorr_real_std(xf:end),[0,51,150]/255)
hold on
plot(xspan(xf:end),autocorr_real(xf:end),'color',[0,51,150]/255,'linewidth',2),hold on

% jbfill(xspan(xf:end),percentile95(xf:end),percentile05(xf:end),'b','w'), hold on
plot(xspan(xf:end),zeros(numel(xspan(xf:end)),1),'color','k','linewidth',2,'linestyle','--')
xlabel('Lag (ms)'), ylabel('Autocorrelation')
ylim([-0.1 0.3]),xlim([20 300])
set(gca,'fontsize',16)
legend('a','b'), legend boxoff





