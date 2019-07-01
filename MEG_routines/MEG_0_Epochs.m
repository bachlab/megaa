function MEG_0_Epochs(set_par,folders)
%% Function to cut epochs in the MEGAA experiment
% ~~~
% GX Castegnetti --- start 08/2016 --- last update 05/2019

% set some parameters
sr = 100;
NumRuns = 6;
subs = set_par.subs;

% length of different epochs of interests
L_epoch_Out = 1.1;
L_epoch_Bas = 2;
L_epoch_Trl = 2;
L_epoch_Tok = 0.5;


%% loop over subjects and sessions
for s = 1:length(subs)
    for r = 2:NumRuns
        
        % update user
        disp(['Epoching sub#',num2str(subs(s)),' of ',int2str(subs(end)),'; run ' int2str(r) ' of ' int2str(6) '...']);
        
        file_ep = [folders.scan,'MEG_sub_',num2str(subs(s)),'/dnhpspmmeg_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        bfile = [folders.beha,'AAA_05_MEG_Sno_',num2str(subs(s)),'.mat'];
        load(file_ep)
        
        % select triggers (here the first 36 are already excluded)
        Types = {D.trials(:).events.type};
        foo_Values = NaN(1,length(Types));
        for i = 1:length(Types)
            if isnumeric(D.trials.events(i).value)
                foo_Values(i) = D.trials.events(i).value;
            end
        end
        
        Values = foo_Values;
        Times = [D.trials(:).events.time];
        Triggers_idx = strcmp(Types,'frontpanel trigger') & Values >= 1 & Values <= 18;
        Triggers = Times(Triggers_idx)';
        
        % create matrix with behavioural data
        load(bfile)
        if subs(s) ~= 2 % sub 2 has the training already excluded
            foo = {game(37:end).record};
            game = game(37:end);
        else
            foo = {game(:).record};
        end
        behMat = cell2mat(foo');
        
        % common seetings
        S.D = file_ep;
        S.bc = 0;
        
        %% epochs from trial start
        %         EpochStart = round(sr*(Triggers));
        %         EpochEnd = EpochStart + sr*L_epoch_Trl;
        %         S.trl = [EpochStart,EpochEnd,zeros(length(EpochStart),1)];
        %         S.prefix = 'eTrl_';
        %         spm_eeg_epochs(S);
        %         e_TokApp_Record.trl = S.trl;
        
        %% epochs baseline
        % ------------------------------------------------------
        %         EpochEnd = round(sr*(Triggers));
        %         EpochStart = EpochEnd - sr*L_epoch_Bas;
        %         S.trl = [EpochStart,EpochEnd,zeros(length(EpochStart),1)];
        %         S.trl(1,1:2) = S.trl(1,1:2) + 2000;
        %         S.prefix = 'eBas_';
        %         spm_eeg_epochs(S);
        %         e_TokApp_Record.trl = S.trl;
        
        %% epochs from token appearance
        % ------------------------------------------------------
        %         AppSeq = zeros(length(BehMat),1);
        %         AppSeqTimes = zeros(length(BehMat),1);
        %         for i = 1:length(AppSeq)
        %             foo = find(game(i).posmat(:,5) + game(i).posmat(:,6) == 3 ,1);
        %             if ~isempty(foo)
        %                 AppSeq(i) = foo;
        %                 AppSeqTimes(i) = game(i).posmat(AppSeq(i),10) - game(i).posmat(1,10);
        %             end
        %         end
        %         EpochStart = round(sr*(Triggers + 0.001*AppSeqTimes((108*(r-2)+1):(108*(r-1)))));
        %         EpochEnd = EpochStart + sr*L_epoch_Tok;
        %         S.trl = [EpochStart,EpochEnd,zeros(length(EpochStart),1)];
        %         S.prefix = 'eTok_';
        %         spm_eeg_epochs(S);
        %         e_TokApp_Record.trl = S.trl;
        
        %% epochs from token collection
        % ------------------------------------------------------
        % find time points at which tokens were collected
        GoToken = zeros(length(behMat),1);
        GoTokenTimes = zeros(length(behMat),1);
        for i = 1:length(GoToken)
            foo = find(game(i).posmat(:,7),1);
            if ~isempty(foo) && game(i).tokenrecord == 1
                GoToken(i) = foo;
                GoTokenTimes(i) = game(i).posmat(GoToken(i)+2,10) - game(i).posmat(1,10);
                % GoTokenTimes(i) = game(i).posmat(GoToken(i),10) - game(i).posmat(1,10); % epoch cut when the token is collected, not after going back
            end
        end
        EpochStart_Col = round( sr*(Triggers + 0.001*GoTokenTimes((108*(r-2)+1):(108*(r-1)))));
        EpochEnd_Col = EpochStart_Col + sr*L_epoch_Out;
        %         S.trl = [EpochStart_Col,EpochEnd_Col,zeros(length(EpochStart_Col),1)];
        %         S.prefix = 'eCol_';
        %         spm_eeg_epochs(S);
        %         e_TokCol_Record.trl = S.trl;
        %         e_TokCol_Record.Occurs = GoToken;
        %         e_TokCol_Record.OccursTimes = GoTokenTimes;
        
        %% epochs from caught
        % ------------------------------------------------------
        % find time points at which people were caught
        Caught = zeros(length(behMat),1);
        CaughtTimes = zeros(length(behMat),1);
        for i = 1:length(Caught)
            foo = find(game(i).posmat(:,3) + game(i).posmat(:,4) == 3 ,1);
            if ~isempty(foo)
                Caught(i) = foo;
                CaughtTimes(i) = game(i).posmat(Caught(i),10) - game(i).posmat(1,10);
            end
        end
        EpochStart_Cau = round(sr*(Triggers + 0.001*CaughtTimes((108*(r-2)+1):(108*(r-1)))));
        EpochEnd_Cau = EpochStart_Cau + sr*L_epoch_Out;
        %         S.trl = [EpochStart_Cau,EpochEnd_Cau,zeros(length(EpochStart_Cau),1)];
        %         S.prefix = 'eCau_';
        %         spm_eeg_epochs(S);
        %         e_Caught_Record.trl = S.trl;
        %         e_Caught_Record.Occurs = Caught;
        %         e_Caught_Record.OccursTimes = CaughtTimes;
        
        clear i
        
        %% epochs all outcomes for BF
        % ------------------------------------------------------
        % Distinguish outcome type
        i = 1;
        outcomes = [];
        outcomeOnsets = [];
        idx = false(108,1);
        for j = (108*(r-2)+1):(108*(r-1))
            fooCol = find(game(j).posmat(:,7),1);
            fooCau = find(game(j).posmat(:,3) + game(j).posmat(:,4) == 3 ,1);
            if ~isempty(find(game(j).posmat(:,7),1)) && game(j).tokenrecord == 1
                idx(j-108*(r-2)) = true;
                outcomes(i) = 1; %#ok<*AGROW>
                S.conditionlabels{i} = 'Col';
                outColIdx = fooCol;
                outcomeOnsets(i) = game(j).posmat(outColIdx+2,10) - game(j).posmat(1,10);
                i = i + 1;
            elseif ~isempty(find(game(j).posmat(:,3) + game(j).posmat(:,4) == 3 ,1))
                idx(j-108*(r-2)) = true;
                outcomes(i) = -1;
                S.conditionlabels{i} = 'Cau';
                outCauIdx = fooCau;
                outcomeOnsets(i) = game(j).posmat(outCauIdx,10) - game(j).posmat(1,10);
                i = i + 1;
            end
        end
        
        epochStart = round(sr*(Triggers(idx) + 0.001*outcomeOnsets')) - 10;
        epochEnd = epochStart + sr*L_epoch_Out + 10;
        S.trl = [epochStart, epochEnd, -10+zeros(length(epochStart),1)];
        S.bc = 1;
        S.prefix = 'eOut_';
        spm_eeg_epochs(S);
        clear S
        
    end
end
