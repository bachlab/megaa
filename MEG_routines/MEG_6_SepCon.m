function [idx, lmeMat] = MEG_6_SepCon(set_par,folders,In_2)
% Separates trials according to threat level (1-3), potential loss (0-5),
% and upcoming behaviour (Go-Stay)
% G Castegnetti --- start: 2017 --- last update: 05/2019

%% unpack parameters
% ------------------------------------------------------------
subs = set_par.subs;
align = set_par.align;
n_trials = set_par.NumTrials; 
MinDuration = set_par.deliberTime; clear set_par


%% allocate memory
% ------------------------------------------------------------
idx = cell(length(subs),1);
N_Trials_Stay_All = zeros(3,6);
lmeMat = NaN(n_trials*length(subs),6);


%% loop pver subjects
% ------------------------------------------------------------
for s = 1:length(subs)

    % retrieve BehMat and create vector with movement onsets
    BehMat = In_2{s}.BehMat; % 1:#Tok 2:TokCollSoFar 3:TokDuration 4:PreTokTime 5:TokPos 6:FirstMovPos 7:FirstMovTime 8:MoveBack 9:Caught? 10:Collect?
    
    % compute ratio between number of positive and negative outcomes
    P_ex(s)     = sum(1-In_2{s}.Design(:,2));
    N_ex(s)     = sum(In_2{s}.Design(:,2));
    PN_ratio(s) = sum(1-In_2{s}.Design(:,2))./sum(In_2{s}.Design(:,2)); %#ok<AGROW,NASGU>
    
    % find trials with epochs long enough (Go = 1; Stay = -1)
    % --------------------------------------------------------
    Trls = NaN(1,n_trials);
    if align == 1
        Trls(BehMat(:,7) > MinDuration) = 1;
        Trls(BehMat(:,7) == 0) = -1;
    elseif align == 2
        Trls(BehMat(:,4) > MinDuration & BehMat(:,7) > 0) = 1;
        Trls(BehMat(:,4) > MinDuration & BehMat(:,7) == 0) = -1;
    end
    lmeMat(n_trials*(s-1)+1:n_trials*s,8) = BehMat(:,7);

    
    % extract threat levels and potential losses
    % --------------------------------------------------------
    bfile = [folders.beha,'AAA_05_MEG_Sno_',num2str(subs(s)),'.mat'];
    load(bfile,'game')
    if s ~= 2, game = game(37:end); end
    for trl = 1:n_trials
        PL(trl) = game(trl).laststate.tokenloss; %#ok<AGROW>
        TL(trl) = game(trl).laststate.predno;  %#ok<AGROW>
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
    
    lmeMat(n_trials*(s-1)+1:n_trials*s,4) = TL; % TL
    lmeMat(n_trials*(s-1)+1:n_trials*s,5) = PL; % PL
    
    idx_Stay_R = find(Trls == -1);
    lmeMat(n_trials*(s-1)+idx_Stay_R,6) = 0;    % Go
    idx_go = find(Trls == 1);
    lmeMat(n_trials*(s-1)+idx_go,6) = 1;      % Stay
    
    
    % store condition indices
    % --------------------------------------------------------
    idx{s}.All = sort([idx_go idx_Stay_R]);
    disp(['Sub#',num2str(subs(s)),'. App. trials: ',num2str(length(idx_go)),'; Avo. trials: ',num2str(length(idx_Stay_R))]);
    clear game bfile
    
    IDX_GO(s) = length(idx_go);
    IDX_STAY(s) = length(idx_Stay_R);
    
    %% separate conditions
    
    % Go/NoGo
    if align == 1
        [~,idx_go_sort] = sort(BehMat(idx_go,7)); % order trials according to movement latency from token appearance
    elseif align == 2
        [~,idx_go_sort] = sort(BehMat(idx_go,4) + BehMat(idx_go,7)); % order trials according to movement latency from trial start
    end
    
    idx{s}.Go.Sort = idx_go(idx_go_sort);
    lengthApp(s) = length(idx_go);
    N_Trials_Stay = NaN(3,6);
    for tl = 1:3
        for pl = 1:6
            idx{s}.Go.Conds{tl,pl} = find(TL == tl & PL == pl-1 & Trls == 1);
            idx{s}.Stay.Conds{tl,pl} = find(TL == tl & PL == pl-1 & Trls == -1);
            N_Trials_Stay(tl,pl) = length(idx{s}.Stay.Conds{tl,pl}); 
        end
    end
    N_Trials_Stay_All = N_Trials_Stay_All + N_Trials_Stay;
    
end
SS_ex  = [P_ex' N_ex'];

