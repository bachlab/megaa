%% MEG_epochs
% Script to epoch MEG sensor data
%
% G Castegnetti 10/10/2017

clear
close all
restoredefaultpath
addpath D:\MATLAB\MATLAB_tools\spm12\

spm eeg
folder = 'D:\MATLAB\MATLAB_scripts\MEG\MEG_data\scanner\';
bfolder = 'D:\MATLAB\MATLAB_scripts\MEG\MEG_data\behavioural\';

sr = 100;
L_epoch = 1;
n_trials = 540;
IEI = NaN(n_trials,1);
AA = [];
NumRuns = 6;
subs = [1:5 7:9 11:25];

%% loop over people and sessions
for s = 1:length(subs)
    for r = 2:NumRuns
        
        file_ep = [folder,'MEG_sub_',num2str(subs(s)),'\hpdspmmeg_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        bfile = [bfolder,'AAA_05_MEG_Sno_',num2str(subs(s)),'.mat'];
        load(file_ep)
        
        % select triggers (here the first 36 are already excluded)
        Types = {D.trials(:).events.type};
        Values = [D.trials(:).events.value];
        Times = [D.trials(:).events.time];
        Triggers_idx = find(strcmp(Types,'frontpanel trigger') & Values >= 1 & Values <= 18);
        Triggers = Times(Triggers_idx)';
        
        % create matrix with behavioural data
        load(bfile)
        if subs(s) ~= 2 % sub 2 has the training already excluded
            foo = {game(37:end).record};
            game = game(37:end);
        else
            foo = {game(:).record};
        end
        BehMat = cell2mat(foo');
        
        % common seetings
        S.D = file_ep;
        S.bc = 0;
        
        %% epochs from trial start
        EpochStart = round(sr*(Triggers)) + 1;
        EpochEnd = EpochStart + sr*L_epoch*3;
        S.trl = [EpochStart,EpochEnd,zeros(length(EpochStart),1)];
        S.prefix = 'eTrl_';
        D_e_TokApp_Mov = spm_eeg_epochs(S);
        e_TokApp_Record.trl = S.trl;
        
        %% epochs baseline
%         EpochStart = round(sr*(Triggers)) - sr*L_epoch;
%         EpochEnd = EpochStart + sr*L_epoch - 1;
%         S.trl = [EpochStart,EpochEnd,zeros(length(EpochStart),1)];
%         S.prefix = 'eBas_';
%         D_e_TokApp_Mov = spm_eeg_epochs(S);
%         e_TokApp_Record.trl = S.trl;
        
        %% epochs from token appearance
%         AppSeq = zeros(length(BehMat),1);
%         AppSeqTimes = zeros(length(BehMat),1);
%         for i = 1:length(AppSeq)
%             foo = find(game(i).posmat(:,5) + game(i).posmat(:,6) == 3 ,1);
%             if ~isempty(foo)
%                 AppSeq(i) = foo;
%                 AppSeqTimes(i) = game(i).posmat(AppSeq(i),10) - game(i).posmat(1,10);
%             end
%         end
%         EpochStart = round(sr*(Triggers + 0.001*AppSeqTimes((108*(r-2)+1):(108*(r-1))))) + 1;
%         EpochEnd = EpochStart + sr*L_epoch;
%         S.trl = [EpochStart,EpochEnd,zeros(length(EpochStart),1)];
%         S.prefix = 'eTok_';
%         D_e_TokApp_Mov = spm_eeg_epochs(S);
%         e_TokApp_Record.trl = S.trl;
        
        %% epochs from token collection
        % find time points at which tokens were collected
%         GoToken = zeros(length(BehMat),1);
%         GoTokenTimes = zeros(length(BehMat),1);
%         for i = 1:length(GoToken)
%             foo = find(game(i).posmat(:,7),1);
%             if ~isempty(foo) && game(i).tokenrecord == 1
%                 GoToken(i) = foo;
%                 GoTokenTimes(i) = game(i).posmat(GoToken(i)+2,10) - game(i).posmat(1,10);
% %                 GoTokenTimes(i) = game(i).posmat(GoToken(i),10) - game(i).posmat(1,10); % epoch cut when the token is collected, not after going back
%             end
%         end
%         EpochStart_Col = round( sr*(Triggers + 0.001*GoTokenTimes((108*(r-2)+1):(108*(r-1))))) + 1;
%         EpochEnd_Col = EpochStart_Col + sr*L_epoch;
%         S.trl = [EpochStart_Col,EpochEnd_Col,zeros(length(EpochStart_Col),1)];
%         S.prefix = 'eCol_';
%         D_e_TokColl = spm_eeg_epochs(S);
%         e_TokCol_Record.trl = S.trl;
%         e_TokCol_Record.Occurs = GoToken;
%         e_TokCol_Record.OccursTimes = GoTokenTimes;
        
        %% epochs from caught
        % find time points at which people were caught
%         Caught = zeros(length(BehMat),1);
%         CaughtTimes = zeros(length(BehMat),1);
%         for i = 1:length(Caught)
%             foo = find(game(i).posmat(:,3) + game(i).posmat(:,4) == 3 ,1);
%             if ~isempty(foo);
%                 Caught(i) = foo;
%                 CaughtTimes(i) = game(i).posmat(Caught(i),10) - game(i).posmat(1,10);
%             end
%         end
%         EpochStart_Cau = round(sr*(Triggers + 0.001*CaughtTimes((108*(r-2)+1):(108*(r-1))))) + 1;
%         EpochEnd_Cau = EpochStart_Cau + sr*L_epoch;
%         S.trl = [EpochStart_Cau,EpochEnd_Cau,zeros(length(EpochStart_Cau),1)];
%         S.prefix = 'eCau_';
%         %         D_e_Caught = spm_eeg_epochs(S);
%         e_Caught_Record.trl = S.trl;
%         e_Caught_Record.Occurs = Caught;
%         e_Caught_Record.OccursTimes = CaughtTimes;
        
        %% compute times between Col/Cau and next trial onset
%         idx_Cau = Caught > 0;
%         idx_Col = GoToken > 0;
%         for i = 1:n_trials/5
%             if idx_Cau(i) == 1 && i < n_trials/5
%                 IEI((r-2)*n_trials/5 + i) = Triggers(i+1)*sr - EpochEnd_Cau(i);
%             elseif idx_Col(i) == 1 && i < n_trials/5
%                 IEI((r-2)*n_trials/5 + i) = Triggers(i+1)*sr - EpochEnd_Col(i);
%             elseif i == n_trials/5
%                 IEI((r-2)*n_trials/5 + i) = Inf;
%             end
%         end
    end
%     save([folder,'MEG_sub_',num2str(subs(s)),'\IEIs_sub_',num2str(subs(s))],'IEI')
%     AA = [AA;IEI];
end
