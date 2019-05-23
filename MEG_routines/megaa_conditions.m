function [conditions, lmeMat] = megaa_conditions(par,folders,In_2)
% Separates trials according to threat level (1-3), potential loss (0-5),
% and upcoming behaviour (Go-Stay)
% G Castegnetti --- start: 2017 --- last update: 05/2019

%% Unpack parameters
% ------------------------------------------------------------
subs = par.subs;
align = par.align;
n_trials = par.NumTrials;
minDuration = par.deliberTime; clear par


%% Loop over subjects
% ------------------------------------------------------------
lmeMat = NaN(n_trials*length(subs),6);
for s = 1:length(subs)
    
    % retrieve BehMat and create vector with movement onsets
    behMat = In_2{s}.BehMat; % 1:#Tok 2:TokCollSoFar 3:TokDuration 4:PreTokTime 5:TokPos 6:FirstMovPos 7:FirstMovTime 8:MoveBack 9:Caught? 10:Collect?
    
    % find trials with epochs long enough (Go = 1; Stay = -1)
    % --------------------------------------------------------
    trialsRetain = nan(n_trials,1);
    if align == 1
        trialsRetain(behMat(:,7) > minDuration) = 1;
        trialsRetain(behMat(:,7) == 0) = -1;
    elseif align == 2
        trialsRetain(behMat(:,4) > minDuration & behMat(:,7) > 0) = 1;
        trialsRetain(behMat(:,4) > minDuration & behMat(:,7) == 0) = -1;
    end
    lmeMat(n_trials*(s-1)+1:n_trials*s,8) = behMat(:,7);
    
    
    % extract threat levels and potential losses
    % --------------------------------------------------------
    bfile = [folders.beha,'AAA_05_MEG_Sno_',num2str(subs(s)),'.mat'];
    load(bfile,'game')
    if s ~= 2, game = game(37:end); end
    for trl = 1:n_trials
        threatMagn(trl) = game(trl).laststate.tokenloss; %#ok<AGROW>
        threatProb(trl) = game(trl).laststate.predno;  %#ok<AGROW>
    end
    
    
    % extract outcome during previous trial (1=P, -1=N, 0=Avoid)
    % --------------------------------------------------------
    Design = In_2{s}.Design;
    Design(:,2) = -(2*In_2{s}.Design(:,2) - 1);
    PrevOut = zeros(n_trials,1);
    for i = 1:n_trials-1
        if ismember(i,Design(:,1))
            PrevOut(i+1) = Design(Design(:,1) == i,2);
        end
    end
    lmeMat(n_trials*(s-1)+1:n_trials*s,7) = PrevOut;
    
    
    % R-MAT - subject, run, trial, TL, PL, Go/Stay
    % --------------------------------------------------------
    lmeMat(n_trials*(s-1)+1:n_trials*s,1) = subs(s);     % sub number
    lmeMat(n_trials*(s-1)+1:n_trials*(s-1)+108,2) = 2;   % run 2
    lmeMat(n_trials*(s-1)+109:n_trials*(s-1)+216,2) = 3; % run 3
    lmeMat(n_trials*(s-1)+217:n_trials*(s-1)+324,2) = 4; % run 4
    lmeMat(n_trials*(s-1)+325:n_trials*(s-1)+432,2) = 5; % run 5
    lmeMat(n_trials*(s-1)+433:n_trials*(s-1)+540,2) = 6; % run 6
    lmeMat(n_trials*(s-1)+1:n_trials*s,3) = 1:n_trials;  % trial number
    
    lmeMat(n_trials*(s-1)+1:n_trials*s,4) = threatProb; % TL
    lmeMat(n_trials*(s-1)+1:n_trials*s,5) = threatMagn; % PL
    
    idx_Stay_R = find(trialsRetain == -1);
    lmeMat(n_trials*(s-1)+idx_Stay_R,6) = 0;    % Go
    idx_go = find(trialsRetain == 1);
    lmeMat(n_trials*(s-1)+idx_go,6) = 1;      % Stay

    
    % Condition matrix
    % --------------------------------------------------------
    conditions = [trialsRetain, threatProb', threatMagn'];
    
end
