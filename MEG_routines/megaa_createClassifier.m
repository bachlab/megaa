function Out = megaa_createClassifier(par,In_1,In_2)
%% Given optimal bin and lambda, creates classifier
% -------------------------------------------------------------
% G Castegnetti --- start: 2017 --- last update 05/2019

%% Loop over subjects
% -------------------------------------------------------------
for s = 1:length(par.subs)
    
    %% create X and Ys
    % -------------------------------------------------------------
    Design = In_1{s}.Design;                                         % retrieve design matrix
    Y_Cau = [Design(:,2); zeros(par.NumNullEx,1)];               % outcomes if Cau are positive examples
    Y_Col = [1-Design(:,2); zeros(par.NumNullEx,1)];             % outcomes if Col are positive examples
    
    d_Real = In_1{s}.d_Real;                                         % retrieve d_Real
    X_Real = squeeze(d_Real(:,In_2.OptBin,Design(:,1)))';            % sensor data at the outcome
    X_Base = In_1{s}.d_Base;                                         % sensor data at the baseline
    X = [X_Real; X_Base];
    
    %% Train classifiers with permuted class labels
    % -------------------------------------------------------------
    if par.NumPerm > 0
        for p = 1:par.NumPerm
            foo = randperm(length(Design));
            disp(['sub#',num2str(par.subs(s)),'; permutation ' int2str(p) ' of ' int2str(par.NumPerm) '...']); % update user
            Y_Cau_Perm = [Y_Cau(foo); Y_Cau(length(Design)+1:end)];
            Y_Col_Perm = [Y_Col(foo); Y_Col(length(Design)+1:end)];
            [Out.PermClass{s,p}.Cau,Out.PermFitInfo{s,p}.Cau] = lassoglm(X,Y_Cau_Perm,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Cau(s)); % regression with Cau are positive examples
            [Out.PermClass{s,p}.Col,Out.PermFitInfo{s,p}.Col] = lassoglm(X,Y_Col_Perm,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Col(s)); % regression with Col are positive examples
        end
    end
    
    %% Train classifiers with permuted class labels
    % -------------------------------------------------------------
    [Out.OptClass{s}.Cau,Out.OptFitInfo{s}.Cau] = lassoglm(X,Y_Cau,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Cau(s)); % regression with Cau are positive examples
    [Out.OptClass{s}.Col,Out.OptFitInfo{s}.Col] = lassoglm(X,Y_Col,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Col(s)); % regression with Col are positive examples
    
    foo_Col  = sum(repmat(Out.OptClass{s}.Col',size(X,1),1).*X,2) + Out.OptFitInfo{s}.Col.Intercept;
    Pred_Col{s} = round(1./(1+exp(-foo_Col)));
    
    clear t_Null RandOnsets_Null X_Real X_Base X Y_Cau Y_Col
    
    
end
