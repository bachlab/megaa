function Out_1 = MEG_1_OptBin_CvKFold(set_par,folders,In)
% Script to compute the accuracy of the classifiers at each time bin after
% oucome presentation. The accuracy is computed with a leave-one-out cross
% validation procedure.
% G Castegnetti 2017

% unpack parameters
subs = set_par.subs;
NumRuns = set_par.NumRuns;
n_bins = set_par.NumTrainBins;
num_NullEx = set_par.NumNullEx;
n_trials = set_par.NumTrials;
kfold = 10;

Channels = In.Chan_sub; clear In

Out_1 = cell(length(subs),1); % allocate memory for output

for s = 1:length(subs)
    
    %% adjust behavioural matrix
    bfile = [folders.beha,'AAA_05_MEG_Sno_',num2str(subs(s)),'.mat'];
    load(bfile,'game')
    foo = {game(:).record};
    if subs(s) ~= 2 % because sub#2 has the training session already removed
        foo = {game(37:end).record};
        game = game(37:end);
    end
    BehMat = cell2mat(foo'); % 1:#Tok 2:TokCollSoFar 3:TokDuration 4:PreTokTime 5:TokPos 6:FirstMovPos 7:FirstMovTime 8:MoveBack 9:Caught? 10:Collect?
    Out_1{s}.BehMat = BehMat; % store behavioural output
    clear bfile foo
    
    %% extract ITIs
    ITI = NaN(n_trials,1);
    for trl = 1:n_trials
        ITI(trl) = game(trl).laststate.waitbreak;
    end, clear trl
    
    %% find Col and Cau trials indices
    trials_Col = zeros(length(BehMat),1);
    trials_Cau = zeros(length(BehMat),1);
    for j = 1:length(trials_Col)
        trials_Col(j) = ~isempty(find(game(j).posmat(:,7),1)) && game(j).tokenrecord == 1;
        trials_Cau(j) = ~isempty(find(game(j).posmat(:,3) + game(j).posmat(:,4) == 3 ,1));
        trials_Col(j) = []; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mod 28/08
    end
    clear game j
    
    %% fill matrices with Col and Cau trials
    d_Col = NaN(275,n_bins,n_trials/(NumRuns-1));
    d_Cau = NaN(275,n_bins,n_trials/(NumRuns-1));
    d_Base = NaN(275,n_bins,n_trials/(NumRuns-1));
    for r = 2:NumRuns
        
        % set correct file name given a folder
        if strcmp(folders.scan,'D:\MATLAB\MATLAB_scripts\MEG\MEG_data\scanner_v2\')
            name_str = 'Tahpdspmmeg';
        elseif strcmp(folders.scan,'D:\MATLAB\MATLAB_scripts\MEG\MEG_data\ScanData\')
            name_str = 'dnhpspmmeg';
        end
        file_Col = [folders.scan,'MEG_sub_',num2str(subs(s)),'\eCol_',name_str,'_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        file_Cau = [folders.scan,'MEG_sub_',num2str(subs(s)),'\eCau_',name_str,'_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        file_Bas = [folders.scan,'MEG_sub_',num2str(subs(s)),'\eBas_',name_str,'_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        
        % extract runs and merge them in the same matrix
%         load(file_Col)
%         d_Col(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(Channels(:,s),1:n_bins,:); clear D
%         load(file_Cau)
%         d_Cau(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(Channels(:,s),1:n_bins,:); clear D
%         load(file_Bas)
%         d_Base(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(Channels(:,s),1:n_bins,:); clear D
        
        load(file_Col)
        d_Col(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(33:307,1:n_bins,:); clear D
        load(file_Cau)
        d_Cau(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(33:307,1:n_bins,:); clear D
        load(file_Bas)
        d_Base(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(33:307,1:n_bins,:); clear D
    end
    clear file_Col file_Cau file_Bas r
    
    %% fill a matrix containing the cut epochs corresponding to the trial type, including null examples
%     TrialTypes = -1*trials_Col + trials_Cau; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mod 28/08
    TrialTypes = 1*trials_Cau;
    d_Real = NaN(275,n_bins,n_trials);
    for i = 1:n_trials
        if TrialTypes(i) == -1
            d_Real(:,:,i) = d_Col(:,:,i);
        elseif TrialTypes(i) == 1
            d_Real(:,:,i) = d_Cau(:,:,i);
        end
    end
%     clear TrialTypes i d_Col d_Cau
    
    %% create (design) matrix with trial numbers and types
    idx_Col = find(trials_Col);
    idx_Cau = find(trials_Cau);
    idx_All = [[idx_Col;idx_Cau] [zeros(length(idx_Col),1);ones(length(idx_Cau),1)]];
    [foo idx] = sort(idx_All);
    Design = [foo(:,1),foo(idx(:,1),2)]; % this is the matrix used to build the inputs for lassglm
    clear idx_Col idx_Cau idx_All foo idx trials_Col trials_Cau
    
    %% create baseline matrix
    idx = (2:n_trials)';
    TrlRem = idx(ITI(1:end-1) > 2000);
    TrlRem = TrlRem(randperm(length(TrlRem)));
    TrlRem = TrlRem(1:num_NullEx);
    OnsRem = round(1 + 99*rand(num_NullEx,1));
    foo_Base = NaN(num_NullEx,size(d_Base,1));
    for b = 1:num_NullEx
        foo_Base(b,:) = squeeze(d_Base(:,OnsRem(b),TrlRem(b))); % sensor data at the baseline
    end
    d_Base = foo_Base;
    Out_1{s}.d_Base = d_Base; % save d_Base
    clear idx trl_rem
    
    %% regression
    
    % vectors of labels
    Y_Cau = [Design(:,2); zeros(num_NullEx,1)]; % outcomes if Cau are positive examples
    Y_Col = [1-Design(:,2); zeros(num_NullEx,1)]; % outcomes if Col are positive examples
    Y_Bas = [0*Design(:,2); ones(num_NullEx,1)]; % outcomes if Bas are positive examples
    
    % initialise stuff
    Cau.Coeff = {};
    Col.Coeff = {};
    Bas.Coeff = {};
    Cau.FitInfo = {};
    Col.FitInfo = {};
    Bas.FitInfo = {};
    Pred_Cau = NaN(length(Y_Cau),n_bins);
    Pred_Col = NaN(length(Y_Cau),n_bins);
    Pred_Bas = NaN(length(Y_Cau),n_bins);
    
    % loop over time points after outcome onset
%     for t = 1:n_bins
%         X_Real = squeeze(d_Real(:,t,Design(:,1)))'; % sensor data at the outcome
%         X_Base = d_Base;                            % sensor data at the baseline
%         X = [X_Real; X_Base];
%         SizSets = ceil(size(X,1)/kfold);
%         SetLabels = randperm(size(X,1));
%         for o = 1:kfold
%             
%             if o < kfold
%                 TestTrl = SetLabels(1+(o-1)*SizSets:o*SizSets)';
%             else
%                 TestTrl = SetLabels(1+(o-1)*SizSets:end)';
%             end
%             
%             % update user
%             disp(['Sub#',int2str(subs(s)),' of ',int2str(subs(end)),'; bin#',int2str(t) ' of ' int2str(n_bins),'; fold#',int2str(o),'; size = ',int2str(length(TestTrl)),'...']);
%             
%             X_testt = X(TestTrl,:)';                    % test set
%             X_train = X; X_train(TestTrl,:) = [];       % training set
%             
%             Y_Cau_red = Y_Cau; Y_Cau_red(TestTrl) = []; % Cau outcomes
%             Y_Col_red = Y_Col; Y_Col_red(TestTrl) = []; % Col outcomes
%             Y_Bas_red = Y_Bas; Y_Bas_red(TestTrl) = []; % Bas outcomes
%             
%             [foo_Coeff_Cau,foo_FitInfo_Cau] = lassoglm(X_train,Y_Cau_red,'binomial','Alpha',1,'Lambda',0.025); % regression with Cau positive examples
%             [foo_Coeff_Col,foo_FitInfo_Col] = lassoglm(X_train,Y_Col_red,'binomial','Alpha',1,'Lambda',0.025); % regression with Col positive examples
%             [foo_Coeff_Bas,foo_FitInfo_Bas] = lassoglm(X_train,Y_Bas_red,'binomial','Alpha',1,'Lambda',0.025); % regression with Bas positive examples
%             
%             % Cau predictions
%             foo_Cau = sum(repmat(foo_Coeff_Cau,1,size(X_testt,2)).*X_testt,1) + foo_FitInfo_Cau.Intercept;
%             Pred_Cau(TestTrl,t) = round(1./(1+exp(-foo_Cau)));
%             
%             % Col predictions
%             foo_Col = sum(repmat(foo_Coeff_Col,1,size(X_testt,2)).*X_testt,1) + foo_FitInfo_Col.Intercept;
%             Pred_Col(TestTrl,t) = round(1./(1+exp(-foo_Col)));
%             
%             % Bas predictions
%             foo_Bas = sum(repmat(foo_Coeff_Bas,1,size(X_testt,2)).*X_testt,1) + foo_FitInfo_Bas.Intercept;
%             Pred_Bas(TestTrl,t) = round(1./(1+exp(-foo_Bas)));
%         end
%     end
%     clear t t_Null RandOnsets_Null X_Real X_Base X Y_Cau Y_Col Cau Col
%     
     TrainData{s}.d_Real = [squeeze(d_Real(:,30,Design(:,1)))'; d_Base];
%     Out_1{s}.Pred_Cau = Pred_Cau;
%     Out_1{s}.Pred_Col = Pred_Col;
%     Out_1{s}.Pred_Bas = Pred_Bas;
%     Out_1{s}.Chan = Channels(:,s);
%     Out_1{s}.Design = Design;
%     Out_1{s}.BasTrl = TrlRem;
%     Out_1{s}.BasOns = OnsRem;
%     
%     clear d_Real d_Base Design
    
end
keyboard