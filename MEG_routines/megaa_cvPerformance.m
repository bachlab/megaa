function out = megaa_cvPerformance(par,folders,In)
%% -------------------------------------------------------------
% Script to compute the accuracy of the classifiers at each time bin after
% oucome presentation. The accuracy is computed with a leave-one-out cross
% validation procedure.
% -------------------------------------------------------------
% G Castegnetti --- start: 2017 --- last update: 05/2019

% unpack parameters
n_bins      = par.NumTrainBins;
num_NullEx  = par.NumNullEx;
n_trials    = par.NumTrials;
kfold       = 10;
fs          = filesep;
whichTp     = par.whichTpTrain;
whichTm     = par.whichTmTrain;

% Take subject-specific vector of channels retained
channels = In.Chan_sub; clear In

% Allocate memory for output
out = cell(length(par.subs),1);

%% Loop over subjects
% -------------------------------------------------------------
% These are the optimal lasso coefficients. Decomment them (and 
% change the lines with the regression) to calculate the accuracy with them.
optLasso = [0.0055;0.0055;0.0565;0.0080;0.0025;0.0045;0.0115;0.0035;0.0175;0.0040;0.0055;0.0055;0.0035;0.0060;0.0060;0.0155;0.0110;0.0055;0.0060;0.0045;0.0050;0.0055;0.0045];
for s = 1:length(par.subs)
    
    %% adjust behavioural matrix
    % -------------------------------------------------------------
    bfile = [folders.beha,'AAA_05_MEG_Sno_',num2str(par.subs(s)),'.mat'];
    load(bfile,'game')
    foo = {game(:).record};
    if par.subs(s) ~= 2 % because sub#2 has the training session already removed
        foo = {game(37:end).record};
        game = game(37:end);
    end
    behMat = cell2mat(foo'); % 1:#Tok 2:TokCollSoFar 3:TokDuration 4:PreTokTime 5:TokPos 6:FirstMovPos 7:FirstMovTime 8:MoveBack 9:Caught? 10:Collect?
    out{s}.BehMat = behMat; % store behavioural output
    clear bfile foo
    
    
    %% Extract ITIs and threat probability/magnitude
    % -------------------------------------------------------------
    iti = nan(n_trials,1);
    threatProb = nan(n_trials,1);
    threatMagn = nan(n_trials,1);
    for trl = 1:n_trials
        iti(trl) = game(trl).laststate.waitbreak;
        threatProb(trl) = game(trl).laststate.predno;
        threatMagn(trl) = game(trl).laststate.tokenloss;
    end, clear trl
    
    
    %% Find which trials were either Col or Cau
    % -------------------------------------------------------------
    % If training restricted to one threat level or potential loss, select
    % relevant trials now.
    
    % If we want to consider all threat probabilities and/or magnitudes
    % (i.e. par = 100), set a condition that is always true.
    if whichTp == 100
        threatProb = 100*ones(length(behMat),1);
    end
    if whichTm == 100
        threatMagn = 100*ones(length(behMat),1);
    end
    
    % Find trials that meet all conditions.
    trials_Col = zeros(length(behMat),1);
    trials_Cau = zeros(length(behMat),1);
    for j = 1:length(trials_Col)
        trials_Col(j) = ~isempty(find(game(j).posmat(:,7),1)) && game(j).tokenrecord == 1 && threatProb(j) == whichTp && threatMagn(j) == whichTm;
        trials_Cau(j) = ~isempty(find(game(j).posmat(:,3) + game(j).posmat(:,4) == 3 ,1)) && threatProb(j) == whichTp && threatMagn(j) == whichTm;
    end
    clear j
    
    % Balance the training to the smallest probability-specific sample
    rng(29)
    if false
        for tl = 1:3
            for k = 1:n_trials
                
                % Find how many samples are available for each threat probability
                foo1(k) = sum(~isempty(find(game(k).posmat(:,7),1)) && game(k).tokenrecord == 1 && threatProb(k) == tl);
                foo2(k) = sum(~isempty(find(game(k).posmat(:,3) + game(k).posmat(:,4) == 3 ,1)) && threatProb(k) == tl);
            end
            sampleCount(tl,1) = sum(foo1);
            sampleCount(tl,2) = sum(foo2);
        end
        percSamples = sum(sampleCount,2);
        minSamples = min(percSamples);
        percDiff = (sampleCount(whichTp) - minSamples)/sampleCount(whichTp);
        if percDiff ~= 0
            idxCol = find(trials_Col);
            idxCau = find(trials_Cau);
            foo1 = idxCol(randperm(numel(idxCol)));
            foo2 = idxCau(randperm(numel(idxCau)));
            foo1 = foo1(1:round(percDiff*numel(idxCol)));
            foo2 = foo2(1:round(percDiff*numel(idxCau)));
            trials_Col(foo1) = [];
            trials_Cau(foo2) = [];
            
        end
    end
    clear game k foo1 foo2 sampleCount percSamples minSamples percDiff
    
    
    %% Create matrices containing the field at the sensors
    % -------------------------------------------------------------
    d_Col = NaN(size(channels,1),n_bins,n_trials/(par.NumRuns-1));
    d_Cau = NaN(size(channels,1),n_bins,n_trials/(par.NumRuns-1));
    d_Nul = NaN(size(channels,1),n_bins,n_trials/(par.NumRuns-1));
    for r = 2:par.NumRuns
        
        % Set correct file name given a folder
        if par.ebCorr == 0
            name_str = 'dnhpspmmeg';
        else
            name_str = 'Tahpdspmmeg';
        end
        file_Col = [folders.scan,'MEG_sub_',num2str(par.subs(s)),fs,'eCol_',name_str,'_sub_',num2str(par.subs(s)),'_run_',num2str(r)];
        file_Cau = [folders.scan,'MEG_sub_',num2str(par.subs(s)),fs,'eCau_',name_str,'_sub_',num2str(par.subs(s)),'_run_',num2str(r)];
        file_Nul = [folders.scan,'MEG_sub_',num2str(par.subs(s)),fs,'eBas_',name_str,'_sub_',num2str(par.subs(s)),'_run_',num2str(r)];
        
        % extract runs and merge them in the same matrix
        load([file_Col,'.mat'])
        D.path = [folders.scan,'MEG_sub_',num2str(par.subs(s))];
        d_Col(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(channels(:,s),1:n_bins,:); clear D
        
        load([file_Cau,'.mat'])
        D.path = [file_Cau,'.dat'];
        d_Cau(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(channels(:,s),1:n_bins,:); clear D
        
        load([file_Nul,'.mat'])
        D.path = [file_Nul,'.dat'];
        d_Nul(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(channels(:,s),1:n_bins,:); clear D
    end
    clear file_Col file_Cau file_Bas r
    
    %% Prepare training data (i.e. field at the sensors) for the classifier
    % -------------------------------------------------------------
    d_Real = nan(size(channels,1),n_bins,n_trials);
    d_Real(:,:,logical(trials_Col)) = d_Col(:,:,logical(trials_Col));
    d_Real(:,:,logical(trials_Cau)) = d_Cau(:,:,logical(trials_Cau));
    
    
    %% Create design matrix with trial numbers and types
    % -------------------------------------------------------------
    idx_Col = find(trials_Col);
    idx_Cau = find(trials_Cau);
    idx_All = [[idx_Col;idx_Cau] [zeros(length(idx_Col),1);ones(length(idx_Cau),1)]];
    [foo idx] = sort(idx_All);
    design = [foo(:,1),foo(idx(:,1),2)]; % this is the matrix used to build the inputs for lassglm
    clear idx_Col idx_Cau idx_All foo idx trials_Col 
    
    aaa = cumsum(trials_Cau);
    figure,plot(aaa)
    %% Create matrix with null examples
    % -------------------------------------------------------------
%     idx = (2:n_trials)';
%     TrlRem = idx(iti(1:end-1) > 2000);
%     TrlRem = TrlRem(randperm(length(TrlRem)));
%     TrlRem = TrlRem(1:num_NullEx);
%     OnsRem = round(1 + 99*rand(num_NullEx,1));
%     foo_Base = NaN(num_NullEx,size(d_Nul,1));
%     for b = 1:num_NullEx
%         foo_Base(b,:) = squeeze(d_Nul(:,OnsRem(b),TrlRem(b))); % sensor data at the baseline
%     end
%     d_Nul = foo_Base;
%     out{s}.d_Base = d_Nul; % save d_Base
%     clear idx trl_rem
%     
%     %% Train classifier
%     % -------------------------------------------------------------
%     
%     % Class labels
%     y_Cau = [design(:,2); zeros(num_NullEx,1)]; % outcomes if Cau are positive examples
%     y_Col = [1-design(:,2); zeros(num_NullEx,1)]; % outcomes if Col are positive examples
%     y_Bas = [0*design(:,2); ones(num_NullEx,1)]; % outcomes if Bas are positive examples
%     
%     % Allocate memory
%     cau.Coeff = {};
%     col.Coeff = {};
%     bas.Coeff = {};
%     cau.FitInfo = {};
%     col.FitInfo = {};
%     bas.FitInfo = {};
%     pred_Cau = nan(length(y_Cau),n_bins);
%     pred_Col = nan(length(y_Cau),n_bins);
%     
%     % Loop over post-outcome time points
%     for t = 1:n_bins
%         x_Real = squeeze(d_Real(:,t,design(:,1)))'; % sensor data at the outcome
%         x_Base = d_Nul;                            % sensor data at the baseline
%         x = [x_Real; x_Base];
%         
%         foo = cvpartition(y_Col,'kfold',10);
%         
%         
%         for o = 1:kfold
%             
%             trainingSet = training(foo,o);
%             testSet = ~trainingSet;
%             
%             % update user
%             disp(['Sub#',int2str(par.subs(s)),' of ',int2str(par.subs(end)),'; bin#',int2str(t) ' of ' int2str(n_bins),'; fold#',int2str(o),'; size = ',int2str(length(testSet)),'...']);
%             
%             x_test = x(testSet,:)';     % test set
%             x_train = x;                % training set
%             x_train(testSet,:) = [];    % remove test trials from training set
%             
%             y_Cau_red = y_Cau; y_Cau_red(testSet) = []; % Cau outcomes
%             y_Col_red = y_Col; y_Col_red(testSet) = []; % Col outcomes
%             
%             [foo_Coeff_Cau,foo_FitInfo_Cau] = lassoglm(x_train,y_Cau_red,'binomial','Alpha',1,'Lambda',0.025); % regression with Cau positive examples
%             [foo_Coeff_Col,foo_FitInfo_Col] = lassoglm(x_train,y_Col_red,'binomial','Alpha',1,'Lambda',0.025); % regression with Col positive examples
%             
%             % Cau predictions
%             foo_Cau = sum(repmat(foo_Coeff_Cau,1,size(x_test,2)).*x_test,1) + foo_FitInfo_Cau.Intercept;
%             pred_Cau(testSet,t) = round(1./(1+exp(-foo_Cau)));
%             
%             % Col predictions
%             foo_Col = sum(repmat(foo_Coeff_Col,1,size(x_test,2)).*x_test,1) + foo_FitInfo_Col.Intercept;
%             pred_Col(testSet,t) = round(1./(1+exp(-foo_Col)));
%             
%         end
%     end
%     clear t t_Null RandOnsets_Null X_Real X_Base X Y_Cau Y_Col Cau Col
%     
%     out{s}.Pred_Cau = pred_Cau;
%     out{s}.Pred_Col = pred_Col;
%     out{s}.Chan = channels(:,s);
%     out{s}.Design = design;
%     out{s}.BasTrl = TrlRem;
%     out{s}.BasOns = OnsRem;
%     out{s}.d_Real = d_Real;
%     
%     clear d_Real d_Base Design
    
end

