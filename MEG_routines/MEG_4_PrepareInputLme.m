function MEG_4_PrepareInputLme(set_par,OutFolder,In)
% Takes the computed representation probabilties and put them in shape for
% the LMER regression with R
% G Castegnetti 2017

%% unpack parameters
NumPerm = set_par.NumPerm;
subs = set_par.subs;
folder_R = fullfile(OutFolder,'lmeData');
mkdir(folder_R)
n_trials = set_par.NumTrials; clear set_par
NumDataPoints = size(In.PredCont{1}.Cau,2);

%% stack trials from all subjects - real
lme_Real.Cau = NaN(n_trials*length(subs),NumDataPoints);
lme_Real.Col = NaN(n_trials*length(subs),NumDataPoints);
for s = 1:length(subs)
    lme_Real.Cau(n_trials*(s-1)+1:n_trials*s,:) = In.PredCont{s}.Cau;
    lme_Real.Col(n_trials*(s-1)+1:n_trials*s,:) = In.PredCont{s}.Col;
end
save(fullfile(folder_R,'lme_Real'),'lme_Real')

%% stack trials from all subjects - perm
for p = 1:NumPerm
    lme_Perm.Cau = NaN(n_trials*length(subs),NumDataPoints);
    lme_Perm.Col = NaN(n_trials*length(subs),NumDataPoints);
    for s = 1:length(subs)
        lme_Perm.Cau(n_trials*(s-1)+1:n_trials*s,:) = In.PredCont_perm{s,p}.Cau;
        lme_Perm.Col(n_trials*(s-1)+1:n_trials*s,:) = In.PredCont_perm{s,p}.Col;
    end
    save(fullfile(folder_R,['lme_Perm_',num2str(p)]),'lme_Perm')
end
