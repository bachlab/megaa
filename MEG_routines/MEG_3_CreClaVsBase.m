function Out = MEG_3_CreClaVsBase(set_par,In_1,In_2)
% Given optimal bin and lasso, creates classifier
% G Castegnetti 2017

%% unpack parameters
subs = set_par.subs;
NumPerm = set_par.NumPerm;

if unique(In_2.OptLasso_Cau) == In_2.Lambdas(1)
    In_2.OptLasso_Cau = ones(length(subs),1);
end

for s = 1:length(subs)
    
    %% create X and Ys
    Design = In_1{s}.Design;                                         % retrieve design matrix
    d_Real = In_1{s}.d_Real;                                         % retrieve d_Real
    X_Real = squeeze(d_Real(:,In_2.OptBin,Design(:,1)))';            % sensor data at the outcome
    X_Base = In_1{s}.d_Base;                                         % sensor data at the baseline
    
    %% shuffle labels to create wrong classifiers
    if NumPerm > 0
        for p = 1:NumPerm
            disp(['sub#',num2str(subs(s)),'; permutation ' int2str(p) ' of ' int2str(NumPerm) '...']); % update user
            
            foo = randperm(length(Design)+set_par.NumNullEx);
            
            X_Cau = [X_Real; X_Base];
            X_Col = [X_Real; X_Base];
            
            Y_Cau = [ones(length(Design),1); zeros(set_par.NumNullEx,1)];
            Y_Col = [ones(length(Design),1); zeros(set_par.NumNullEx,1)];
            
            Y_Perm_Cau = Y_Cau(foo);
            Y_Perm_Col = Y_Col(foo);
            
            [Out.PermClass{s,p}.Cau,Out.PermFitInfo{s,p}.Cau] = lassoglm(X_Cau,Y_Perm_Cau,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Cau(s)); % regression with Cau are positive examples
            [Out.PermClass{s,p}.Col,Out.PermFitInfo{s,p}.Col] = lassoglm(X_Col,Y_Perm_Col,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Col(s)); % regression with Col are positive examples
            [Out.PermClass{s,p}.Bas] = zeros(set_par.NumSens,1);
        end
    end
    
    %% correct labels
    X_Cau = [X_Real; X_Base];
    X_Col = [X_Real; X_Base];
    
    [Out.OptClass{s}.Cau,Out.OptFitInfo{s}.Cau] = lassoglm(X_Cau,Y_Cau,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Cau(s)); % regression with Cau are positive examples
    [Out.OptClass{s}.Col,Out.OptFitInfo{s}.Col] = lassoglm(X_Col,Y_Col,'binomial','Alpha',1,'Lambda',In_2.OptLasso_Col(s)); % regression with Col are positive examples
    [Out.OptClass{s}.Bas] = zeros(set_par.NumSens,1);
    
    clear t_Null RandOnsets_Null X_Real X_Base X Y_Cau Y_Col Y_Bas
    
end

