function out = megaa_createClassifierBase(set_par,in_1,in_2)
% Given optimal bin and lasso, creates classifier
% G Castegnetti 2017

%% unpack parameters
subs = set_par.subs;
numPerm = set_par.NumPerm;

if unique(in_2.OptLasso_Cau) == in_2.Lambdas(1)
    in_2.OptLasso_Cau = ones(length(subs),1);
end

for s = 1:length(subs)
    
    %% create X and Ys
    design = in_1{s}.Design;                                         % retrieve design matrix
    d_Real = in_1{s}.d_Real;                                         % retrieve d_Real
    x_Real = squeeze(d_Real(:,in_2.OptBin,design(:,1)))';            % sensor data at the outcome
    x_Base = in_1{s}.d_Base;                                         % sensor data at the baseline
    
    x = [x_Real; x_Base];
    
    y_Cau_foo = design(:,2);
    y_Cau_foo(y_Cau_foo == 0) = nan;
    y_Col_foo = 1-design(:,2);
    y_Col_foo(y_Col_foo == 0) = nan;
    
    y_Cau = [y_Cau_foo; zeros(set_par.NumNullEx,1)];
    y_Col = [y_Col_foo; zeros(set_par.NumNullEx,1)];
    
    %% shuffle labels to create wrong classifiers
    % ------------------------------------------------------
    if numPerm > 0
        for p = 1:numPerm
            disp(['sub#',num2str(subs(s)),'; permutation ' int2str(p) ' of ' int2str(numPerm) '...']); % update user
            
            foo = randperm(length(design)+set_par.NumNullEx);
             
            y_Perm_Cau = y_Cau(foo);
            y_Perm_Col = y_Col(foo);
            
            [out.PermClass{s,p}.Cau,out.PermFitInfo{s,p}.Cau] = lassoglm(x,y_Perm_Cau,'binomial','Alpha',1,'Lambda',in_2.OptLasso_Cau(s)); % regression with Cau are positive examples
            [out.PermClass{s,p}.Col,out.PermFitInfo{s,p}.Col] = lassoglm(x,y_Perm_Col,'binomial','Alpha',1,'Lambda',in_2.OptLasso_Col(s)); % regression with Col are positive examples
            [out.PermClass{s,p}.Bas] = zeros(set_par.NumSens,1);
        end
    end
    
    %% correct labels
    % ------------------------------------------------------
    
    [out.OptClass{s}.Cau,out.OptFitInfo{s}.Cau] = lassoglm(x,y_Cau,'binomial','Alpha',1,'Lambda',in_2.OptLasso_Cau(s)); % regression with Cau are positive examples
    [out.OptClass{s}.Col,out.OptFitInfo{s}.Col] = lassoglm(x,y_Col,'binomial','Alpha',1,'Lambda',in_2.OptLasso_Col(s)); % regression with Col are positive examples
    [out.OptClass{s}.Bas] = zeros(set_par.NumSens,1);
    
    clear t_Null RandOnsets_Null X_Real X_Base X Y_Cau Y_Col Y_Bas
    
end

