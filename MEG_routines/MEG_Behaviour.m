function MEG_Behaviour(par,folders)
% ~~~
% Behavioural results from the MEGAA study
% ~~~
% G Castegnetti --- start: 05/2019 --- last update: 05/2019

%% Initialise
% -----------------------------------

% unpack parameters
n_trials = par.NumTrials;

% allocate memory for output
Out = cell(length(par.subs),1); 

%% loop over subjects
% -----------------------------------
for s = 1:length(par.subs)
    
    %% Adjust behavioural matrix
    % ----------------------------------------
    bfile = [folders.beha,'AAA_05_MEG_Sno_',num2str(par.subs(s)),'.mat'];
    load(bfile,'game')
    foo = {game(:).record};
    if par.subs(s) ~= 2 % because sub#2 has the training session already removed
        foo = {game(37:end).record};
        game = game(37:end);
    end
    BehMat = cell2mat(foo'); % 1:#Tok 2:TokCollSoFar 3:TokDuration 4:PreTokTime 5:TokPos 6:FirstMovPos 7:FirstMovTime 8:MoveBack 9:Caught? 10:Collect?
    clear bfile foo
    
    
    %% extract ITIs
    % ----------------------------------------
    ITI = NaN(n_trials,1);
    for trl = 1:n_trials
        ITI(trl) = game(trl).laststate.waitbreak;
    end, clear trl
    
    
    %% Find trials that were either Col or Cau
    % ----------------------------------------
    trials_Col = zeros(length(BehMat),1);
    trials_Cau = zeros(length(BehMat),1);
    for j = 1:length(trials_Col)
        trials_Col(j) = ~isempty(find(game(j).posmat(:,7),1)) && game(j).tokenrecord == 1;
        trials_Cau(j) = ~isempty(find(game(j).posmat(:,3) + game(j).posmat(:,4) == 3 ,1));
    end
    clear game j
    
    % Discard last trial otherwise index gets bigger than vector length
    trials_Col(end) = false;
    trials_Cau(end) = false;
    
    % Extract reaction times from subsequent trial
    rtAfterCol = BehMat(1+find(trials_Col),7);
    rtAfterCau = BehMat(1+find(trials_Cau),7);
    rtAfterCol(rtAfterCol == 0) = [];
    rtAfterCau(rtAfterCau == 0) = [];

    % Only retain GO trials and average RT
    rtAfterCol_SSavg(s) = mean(rtAfterCol);
    rtAfterCau_SSavg(s) = mean(rtAfterCau);
      
    
end

%% Statistics
% -------------------------------------

% RT after Col vs RT after Cau
[h,p,~,stats] = ttest(rtAfterCol_SSavg,rtAfterCau_SSavg);
