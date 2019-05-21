function D2 = notch_filter_MEG(D1, Path)
%% notch_filter_MEG.m is a function that removes the ac component from the
% dataset. It is a band pass filtered and employes spm_eeg_filter in the
% computation.
% Input:
%       D1 = An MEG object obtained after MEG data high pass filtering
%       Path = a structure containing the name of folders and checkfile
%       parameter
% Output:
%       D2 = An MEG object containing the output of notch_filter_MEG.m
% Created by saurabh Khemka: saurabh.khemka@uzh.ch
% Date: 12-05-2014
% checked & adapted by Dominik R Bach 14.10.2016
%%-------------------------------------------------------------------------
% last edited 14.10.2016

% Check the no of inputs:
if nargin < 2
    error('Not enough inputs: error in notch_filter_MEG.m')
end
%% Filtering
%--------------------------------------------------------------------------
[tempFolder, tempFile, ~] = fileparts(D1.fnamedat);
acRemoved_fileName = fullfile(tempFolder, ['nhp' tempFile '.mat']);
% if exist(acRemoved_fileName, 'file') && Path.checkfiles
%     fprintf('-------- Skipping notch filtering: file exist -------------\n');
%     D2 = spm_eeg_load(acRemoved_fileName);
%     return;
% else
S.D = D1.fnamedat;
S.type = 'butterworth';
S.freq = [49 51];
S.dir = 'twopass';
S.band = 'stop';
S.prefix = 'n';
D2 = spm_eeg_filter(S);
% end
end