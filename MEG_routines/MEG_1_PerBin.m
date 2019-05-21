function BalAcc = MEG_1_PerBin(set_par,In)

n_bins = set_par.NumTrainBins;
subs = set_par.subs;
figure('color',[1 1 1])
for s = 1:length(subs)
    for t = 1:n_bins
        %% Cau
        % find true positives
        foo_TP_Cau = find(In{s}.Pred_Cau(:,t) == 1 & [In{s}.Design(:,2); zeros(set_par.NumNullEx,1)] == 1);
        TP_Cau = length(foo_TP_Cau);
        
        % find true negatives
        foo_TN_Cau = find(In{s}.Pred_Cau(:,t) == 0 & [In{s}.Design(:,2); zeros(set_par.NumNullEx,1)] == 0);
        TN_Cau = length(foo_TN_Cau);
        
        % find false positives
        foo_FP_Cau = find(In{s}.Pred_Cau(:,t) == 1 & [In{s}.Design(:,2); zeros(set_par.NumNullEx,1)] == 0);
        FP_Cau = length(foo_FP_Cau);
        
        % find false negatives
        foo_FN_Cau = find(In{s}.Pred_Cau(:,t) == 0 & [In{s}.Design(:,2); zeros(set_par.NumNullEx,1)] == 1);
        FN_Cau = length(foo_FN_Cau);
        
        Acc_Pos_Cau = TP_Cau/(TP_Cau + FN_Cau);
        Acc_Neg_Cau = TN_Cau/(TN_Cau + FP_Cau);

        BalAcc.Cau(s,t) = mean([Acc_Pos_Cau Acc_Neg_Cau]);
        
        %% Col
        % find true positives
        foo_TP_Col = find(In{s}.Pred_Col(:,t) == 1 & [1-In{s}.Design(:,2); zeros(set_par.NumNullEx,1)] == 1);
        TP_Col = length(foo_TP_Col);
        
        % find true negatives
        foo_TN_Col = find(In{s}.Pred_Col(:,t) == 0 & [1-In{s}.Design(:,2); zeros(set_par.NumNullEx,1)] == 0);
        TN_Col = length(foo_TN_Col);
        
        % find false positives
        foo_FP_Col = find(In{s}.Pred_Col(:,t) == 1 & [1-In{s}.Design(:,2); zeros(set_par.NumNullEx,1)] == 0);
        FP_Col = length(foo_FP_Col);
        
        % find false negatives
        foo_FN_Col = find(In{s}.Pred_Col(:,t) == 0 & [1-In{s}.Design(:,2); zeros(set_par.NumNullEx,1)] == 1);
        FN_Col = length(foo_FN_Col);

        Acc_Pos_Col = TP_Col/(TP_Col + FN_Col);
        Acc_Neg_Col = TN_Col/(TN_Col + FP_Col);

        BalAcc.Col(s,t) = mean([Acc_Pos_Col Acc_Neg_Col]);
        
        %% Bas
        % find true positives
        foo_TP_Bas = find(In{s}.Pred_Bas(:,t) == 1 & [0*In{s}.Design(:,2); ones(set_par.NumNullEx,1)] == 1);
        TP_Bas = length(foo_TP_Bas);
        
        % find true negatives
        foo_TN_Bas = find(In{s}.Pred_Bas(:,t) == 0 & [0*In{s}.Design(:,2); ones(set_par.NumNullEx,1)] == 0);
        TN_Bas = length(foo_TN_Bas);
        
        % find false positives
        foo_FP_Bas = find(In{s}.Pred_Bas(:,t) == 1 & [0*In{s}.Design(:,2); ones(set_par.NumNullEx,1)] == 0);
        FP_Bas = length(foo_FP_Bas);
        
        % find false negatives
        foo_FN_Bas = find(In{s}.Pred_Bas(:,t) == 0 & [0*In{s}.Design(:,2); ones(set_par.NumNullEx,1)] == 1);
        FN_Bas = length(foo_FN_Bas);

        Acc_Pos_Bas = TP_Bas/(TP_Bas + FN_Bas);
        Acc_Neg_Bas = TN_Bas/(TN_Bas + FP_Bas);

        BalAcc.Bas(s,t) = mean([Acc_Pos_Bas Acc_Neg_Bas]);
        
    end
    
    BalAcc.Cau(s,:) = smooth(BalAcc.Cau(s,:));
    BalAcc.Col(s,:) = smooth(BalAcc.Col(s,:));
    BalAcc.Bas(s,:) = smooth(BalAcc.Bas(s,:));
    
end