function MEG_CorrLat(set_par,In_1,In_4,In_5)

subs = set_par.subs;
TimeBins = round(set_par.Epoch_Dur/10);

%% extract latencies
Lats = [];
for s = 1:length(subs)
    trls = sort(In_5{s}.Go.Sort);
    Lats = [Lats; In_1{s}.BehMat(trls,7)]; %#ok<*AGROW>
    Lats_SSmean(s) = mean(In_1{s}.BehMat(In_5{s}.Go.Sort,7));
    Lats_SSmedi(s) = median(In_1{s}.BehMat(In_5{s}.Go.Sort,7));
    Lats_SSmode(s) = mode(In_1{s}.BehMat(In_5{s}.Go.Sort,7));
end

% plot
figure('color',[1 1 1])
plot(Lats_SSmean,'linewidth',1.5,'color','b'),hold on
plot(Lats_SSmedi,'linewidth',1.5,'color','r')
plot(Lats_SSmode,'linewidth',1.5,'color','k')
legend('mean','median','mode')

for t = 1:TimeBins
    
    %% extract representation probabilities
    Rep_real = [];
    for s = 1:length(subs)
        trls = sort(In_5{s}.Go.Sort);
        % compute averages for comparisons across subjects
        Rep_SSmean(s) = mean(In_4.PredCont{s}.Cau(trls,t));
        
        % stack them all in a single vector for trial-by-trial comparison
        Rep_real = [Rep_real; In_4.PredCont{s}.Cau(trls,t)];
    end
    
    % subject-level correlation
    [rfooSS, pfooSS] = corrcoef(Lats_SSmedi,Rep_SSmean);
    R_realSS(t) = rfooSS(1,2);
    p_realSS(t) = pfooSS(1,2);
    
    % trial-level correlation
    [rfooTT, pfooTT] = corrcoef(Lats,Rep_real);
    R_realTT(t) = rfooTT(1,2);
    p_realTT(t) = pfooTT(1,2);
end

%% permutations
for p = 1:100
    for t = 1:TimeBins       
        % extract representation probabilities
        Rep_perm = [];
        for s = 1:length(subs)
            trls = sort(In_5{s}.Go.Sort);
            % compute averages for comparisons across subjects
            Rep_SSmean_perm(s) = mean(In_4.PredCont_perm{s,p}.Col(trls,t));
            
            % stack them all in a single vector for trial-by-trial comparison
            Rep_perm = [Rep_perm; (In_4.PredCont_perm{s,p}.Col(trls,t))];
        end
        
        % subject-level correlation
        [rfooSS, pfooSS] = corrcoef(Lats_SSmedi,Rep_SSmean_perm);
        R_permSS(p,t) = rfooSS(1,2);
        p_permSS(p,t) = pfooSS(1,2); %#ok<NASGU>
        
        % trial-level correlation
        [rfooTT, pfooTT] = corrcoef(Lats,Rep_perm);
        R_permTT(p,t) = rfooTT(1,2);
        p_permTT(p,t) = pfooTT(1,2); %#ok<NASGU>
    end
end

%% smooth
R_realTT = smooth(R_realTT);
R_realSS = smooth(R_realSS);
for p = 1:100
    R_permTT(p,:) = smooth(R_permTT(p,:));
%     figure,plot(R_permTT(p,:))
    R_permSS(p,:) = smooth(R_permSS(p,:));
end

%% permutation test
pcluster_TT_p = permtest(R_realTT', R_permTT, 0.016);
pcluster_SS_p = permtest(R_realSS', R_permSS, 0.4);
pcluster_TT_m = permtest(-R_realTT', -R_permTT, 0.016);
pcluster_SS_m = permtest(-R_realSS', -R_permSS, 0.4);

%% plot

%% plot r and p
xspan = 10:10:set_par.Epoch_Dur;
figure('color',[1 1 1])

subplot(2,2,1),plot(xspan,R_realTT,'.','markersize',30),title('TT'),hold on
plot(xspan(pcluster_TT_p > 0.95),R_realTT(pcluster_TT_p > 0.95),'.','markersize',30,'color','r')
plot(xspan(pcluster_TT_m > 0.95),R_realTT(pcluster_TT_m > 0.95),'.','markersize',30,'color','k')
subplot(2,2,3),plot(xspan,p_realTT,'.','markersize',30)

subplot(2,2,2),plot(xspan,R_realSS,'.','markersize',30),title('SS'),hold on
plot(xspan(pcluster_SS_p > 0.95),R_realSS(pcluster_SS_p > 0.95),'.','markersize',30,'color','r')
plot(xspan(pcluster_SS_m > 0.95),R_realSS(pcluster_SS_m > 0.95),'.','markersize',30,'color','k')
subplot(2,2,4),plot(xspan,p_realSS,'.','markersize',30)

keyboard
