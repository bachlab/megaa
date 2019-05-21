function Out = MEG_3_CreCla(set_par,In_1,In_2)
% Given optimal bin and lasso, creates classifier
% G Castegnetti 2017

%% unpack parameters
subs = set_par.subs;
NumPerm = set_par.NumPerm;

for s = 1:length(subs)
    
    %% create X and Ys
    Design = In_1{s}.Design;                                         % retrieve design matrix
    Y_Cau = [Design(:,2); zeros(set_par.NumNullEx,1)];               % outcomes if Cau are positive examples
    Y_Col = [1-Design(:,2); zeros(set_par.NumNullEx,1)];             % outcomes if Col are positive examples
    
    d_Real = In_1{s}.d_Real;                                         % retrieve d_Real
    X_Real = squeeze(d_Real(:,In_2.OptBin,Design(:,1)))';            % sensor data at the outcome
    X_Base = In_1{s}.d_Base;                                         % sensor data at the baseline
    X = [X_Real; X_Base];
    
    %% shuffle labels to create wrong classifiers
    if NumPerm > 0
        for p = 1:NumPerm
            foo = randperm(length(Design));
            disp(['sub#',num2str(subs(s)),'; permutation ' int2str(p) ' of ' int2str(NumPerm) '...']); % update user
%             Y_Cau_Perm = Y_Cau(randperm(length(Design) + set_par.NumNullEx));
%             Y_Col_Perm = Y_Col(randperm(length(Design) + set_par.NumNullEx));
            Y_Cau_Perm = [Y_Cau(foo); Y_Cau(length(Design)+1:end)];
            Y_Col_Perm = [Y_Col(foo); Y_Col(length(Design)+1:end)];
            [Out.PermClass{s,p}.Cau,Out.PermFitInfo{s,p}.Cau] = lassoglm(X,Y_Cau_Perm,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Cau(s)); % regression with Cau are positive examples
            [Out.PermClass{s,p}.Col,Out.PermFitInfo{s,p}.Col] = lassoglm(X,Y_Col_Perm,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Col(s)); % regression with Col are positive examples
        end
    end
    
    %% correct labels
    [Out.OptClass{s}.Cau,Out.OptFitInfo{s}.Cau] = lassoglm(X,Y_Cau,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Cau(s)); % regression with Cau are positive examples
    [Out.OptClass{s}.Col,Out.OptFitInfo{s}.Col] = lassoglm(X,Y_Col,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Col(s)); % regression with Col are positive examples
    
    foo_Col  = sum(repmat(Out.OptClass{s}.Col',size(X,1),1).*X,2) + Out.OptFitInfo{s}.Col.Intercept;
    Pred_Col{s} = round(1./(1+exp(-foo_Col)));
    
    
    clear t_Null RandOnsets_Null X_Real X_Base X Y_Cau Y_Col
    
    %% Channel vector for the activation pattern
%     ClasShort = Out.OptClass{s}.Col;
%     ChanExpan = zeros(275,1);
%     ClasExpan = zeros(275,1);
%     for i = 1:275
%         if ismember(i,In_1{s}.Chan)
%             ChanExpan(i) = 1;
%             ClasExpan(i) = ClasShort(In_1{s}.Chan == i);
%         end
%     end
%     Class{s}.Channels = ChanExpan;
%     Class{s}.Classifier = ClasExpan;
end


