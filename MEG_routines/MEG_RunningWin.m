function Out_AutoC = MEG_RunningWin(set_par,In_5,idx)

%% import parameters
subs        = set_par.subs;
NumTrials   = set_par.NumTrials;
NumPerm     = set_par.NumPerm;
MinDuration = set_par.Epoch_Dur;
MinDur_idx  = round(MinDuration/10);

%% maximum time lag
WinWidth = 50;
WinIdx = round(WinWidth/10);

for s = 1:length(subs)
    s
    for trl = 1:NumTrials
        Prob_Cau = In_5.PredCont{s}.Cau(trl,1:MinDur_idx);
        Prob_Col = In_5.PredCont{s}.Col(trl,1:MinDur_idx);
        Win_Cau_Real(trl,:) = conv(diff(Prob_Cau),ones(1,WinIdx));
        Win_Col_Real(trl,:) = conv(diff(Prob_Col),ones(1,WinIdx));
    end
    
    Out_AutoC.AutoC_Real{s}.Cau = Win_Cau_Real;
    Out_AutoC.AutoC_Real{s}.Col = Win_Col_Real;
    
    %     % compute autocorrelation for every trial with permuted labels
    %     for p = 1:NumPerm
    %         AutoC_Cau_Perm = NaN(NumTrials,WinIdx+1);
    %         AutoC_Col_Perm = NaN(NumTrials,WinIdx+1);
    %         for trl = 1:NumTrials
    %             AutoC_Cau_Perm(trl,:) = autocorr(In_5.PredCont_perm{s,p}.Cau(trl,1:MinDur_idx),WinIdx);
    %             AutoC_Col_Perm(trl,:) = autocorr(In_5.PredCont_perm{s,p}.Col(trl,1:MinDur_idx),WinIdx);
    %         end
    %         Out_AutoC.AutoC_Perm{s,p}.Cau = AutoC_Cau_Perm;
    %         Out_AutoC.AutoC_Perm{s,p}.Col = AutoC_Col_Perm;
    %     end
    %
    Win_Grand_Cau(s,:) = mean(Win_Cau_Real(idx{s}.All,:));
    Win_Grand_Col(s,:) = mean(Win_Col_Real(idx{s}.All,:));
    
end
keyboard