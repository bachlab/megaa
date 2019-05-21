function MEG_AccuracyVsTime(set_par,folders,In_1,In_idx)
% Script to compute the accuracy of the classifiers at each time bin after
% oucome presentation. The accuracy is computed with a leave-one-out cross
% validation procedure.
% G Castegnetti 2017

% unpack parameters
subs        = set_par.subs;
NumRuns     = set_par.NumRuns;
num_NullEx  = set_par.NumNullEx;
n_trials    = set_par.NumTrials;
n_bins      = round(set_par.Epoch_Dur/10);
kfold       = 10;

for s = 1:length(subs)
    
    %% set channels
    Channels = 33:307;%In_1{s}.Chan;
    
    %% adjust behavioural matrix
    bfile = [folders.beha,'AAA_05_MEG_Sno_',num2str(subs(s)),'.mat'];
    load(bfile,'game')
    foo = {game(:).record};
    if subs(s) ~= 2 % because sub#2 has the training session already removed
        foo = {game(37:end).record};
        game = game(37:end);
    end
    BehMat = cell2mat(foo'); % 1:#Tok 2:TokCollSoFar 3:TokDuration 4:PreTokTime 5:TokPos 6:FirstMovPos 7:FirstMovTime 8:MoveBack 9:Caught? 10:Collect?
    clear bfile foo
    
    %% fill matrices with Trl and Bas trials
    d_Trl = NaN(length(Channels),n_bins,n_trials/(NumRuns-1));
    for r = 2:NumRuns
        
        % set correct file name given a folder
        if strcmp(folders.scan,'D:\MATLAB\MATLAB_scripts\MEG\MEG_data\scanner_v2\')
            name_str = 'Tahpdspmmeg';
        elseif strcmp(folders.scan,'D:\MATLAB\MATLAB_scripts\MEG\MEG_data\scanner\')
            name_str = 'hpdspmmeg';
        end
        file_Trl = [folders.scan,'MEG_sub_',num2str(subs(s)),'\eTrl_',name_str,'_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        
        % extract runs and merge them in the same matrix
        load(file_Trl)
        d_Trl(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(Channels,1:n_bins,:); clear D
    end, clear file_Trl r
    
    %% fill a matrix containing the cut Trl epochs
    Trl_Go = In_idx{s}.Go.Sort;
    Trl_St = In_idx{s}.Stay;
    Trl_St = [Trl_St.Conds{:}]';
    d_Real = d_Trl(:,:,sort([Trl_Go; Trl_St]));
    
    %% create (design) matrix with trial numbers and types
    idx_All = [[Trl_Go;Trl_St] [ones(length(Trl_Go),1);zeros(length(Trl_St),1)]];
    [foo idx] = sort(idx_All(:,1));
    Design = [foo(:,1),idx_All(idx,2)]; % this is the matrix used to build the inputs for lassglm
    clear idx_All foo idx trials_Col trials_Cau
    
    %% regression
    
    % vectors of labels
    Y_Go = [Design(:,2)]; % outcomes if Cau are positive examples
    Y_St = [1-Design(:,2)]; % outcomes if Col are positive examples
    Y_Bas = [0*Design(:,2); ones(num_NullEx,1)]; % outcomes if Bas are positive examples
    
    % initialise stuff
    Go.Coeff = {};
    St.Coeff = {};
    Bas.Coeff = {};
    Go.FitInfo = {};
    St.FitInfo = {};
    Bas.FitInfo = {};
    Pred_Go = NaN(length(Y_Go),n_bins);
    Pred_St = NaN(length(Y_Go),n_bins);
    Pred_Bas = NaN(length(Y_Go),n_bins);
    
    % loop over time points after outcome onset
    X_Base = In_1{s}.d_Base; % load baseline
    for t = 1:n_bins
        X_Real = squeeze(d_Real(:,t,:))'; % sensor data at the outcome
%         X = [X_Real; X_Base];
        X = X_Real;
        SizSets = ceil(size(X,1)/kfold);
        SetLabels = randperm(size(X,1));
        for o = 1:kfold
            
            if o < kfold
                TestTrl = SetLabels(1+(o-1)*SizSets:o*SizSets)';
            else
                TestTrl = SetLabels(1+(o-1)*SizSets:end)';
            end
            
            % update user
            disp(['Sub#',int2str(subs(s)),' of ',int2str(subs(end)),'; bin#',int2str(t) ' of ' int2str(n_bins),'; fold#',int2str(o),'; size = ',int2str(length(TestTrl)),'...']);
            
            X_testt = X(TestTrl,:)';                    % test set
            X_train = X; X_train(TestTrl,:) = [];       % training set
            
            Y_Go_red = Y_Go; Y_Go_red(TestTrl) = []; % Cau outcomes
            Y_St_red = Y_St; Y_St_red(TestTrl) = []; % Col outcomes
%             Y_Bas_red = Y_Bas; Y_Bas_red(TestTrl) = []; % Bas outcomes
            
            [foo_Coeff_Go,foo_FitInfo_Go] = lassoglm(X_train,Y_Go_red,'binomial','Alpha',1,'Lambda',0.025); % regression with Cau positive examples
            [foo_Coeff_St,foo_FitInfo_St] = lassoglm(X_train,Y_St_red,'binomial','Alpha',1,'Lambda',0.025); % regression with Col positive examples
%             [foo_Coeff_Bas,foo_FitInfo_Bas] = lassoglm(X_train,Y_Bas_red,'binomial','Alpha',1,'Lambda',0.025); % regression with Bas positive examples
            
            % Cau predictions
            foo_Go = sum(repmat(foo_Coeff_Go,1,size(X_testt,2)).*X_testt,1) + foo_FitInfo_Go.Intercept;
            Pred_Go(TestTrl,t) = round(1./(1+exp(-foo_Go)));
            
            % Col predictions
            foo_St = sum(repmat(foo_Coeff_St,1,size(X_testt,2)).*X_testt,1) + foo_FitInfo_St.Intercept;
            Pred_St(TestTrl,t) = round(1./(1+exp(-foo_St)));
            
            % Bas predictions
%             foo_Bas = sum(repmat(foo_Coeff_Bas,1,size(X_testt,2)).*X_testt,1) + foo_FitInfo_Bas.Intercept;
%             Pred_Bas(TestTrl,t) = round(1./(1+exp(-foo_Bas)));
        end
    end
    clear t t_Null RandOnsets_Null X_Real X_Base X Y_Cau Y_Col Cau Col
    clear d_Real d_Base 
    
    %% test accuracy
    for t = 1:n_bins
        %% Go
        % find true positives
        foo_TP_Go = find(Pred_Go(:,t) == 1 & [Design(:,2)] == 1);
        TP_Go = length(foo_TP_Go);
        
        % find true negatives
        foo_TN_Go = find(Pred_Go(:,t) == 0 & [Design(:,2)] == 0);
        TN_Go = length(foo_TN_Go);
        
        % find false positives
        foo_FP_Go = find(Pred_Go(:,t) == 1 & [Design(:,2)] == 0);
        FP_Go = length(foo_FP_Go);
        
        % find false negatives
        foo_FN_Go = find(Pred_Go(:,t) == 0 & [Design(:,2)] == 1);
        FN_Go = length(foo_FN_Go);
        
        Acc_Pos_Go = TP_Go/(TP_Go + FN_Go);
        Acc_Neg_Go = TN_Go/(TN_Go + FP_Go);
        
        BalAcc_Go(s,t) = mean([Acc_Pos_Go Acc_Neg_Go]);
        
    end
    
end

figure('color',[1 1 1])
for s = 1:length(subs)
    subplot(5,5,s)
    plot(BalAcc_Go(s,:))
end

keyboard