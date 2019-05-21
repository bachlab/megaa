function D1 = hp_raw_MEG(D, Path)
%% hp_raw_MEG.m is a function to high pass filter the converted MEG data set.
% Input:
%       D = An MEG object obtained after MEG data conversion
%       Path = a structure containing the name of folders and checkfile
%       parameter
% Output:
%       D1 = An MEG object containing the output of hp_raw_MEG.m
% Created by saurabh Khemka: saurabh.khemka@uzh.ch
% Date: 12-05-2014
% checked & adapted by Dominik R Bach 14.10.2016
%%-------------------------------------------------------------------------
% last edited 14.10.2016

% Check the no of inputs:
if nargin < 2
    error('Not enough inputs: error in hp_raw_MEG.m')
end
[tempFolder, tempFile, ~] = fileparts(D.fnamedat);
% filtered_fileName = fullfile(tempFolder, ['hp' tempFile '.mat']);
% notchFiltered_fileName = fullfile(tempFolder, ['nhp' tempFile '.mat']);
% if ~exist(notchFiltered_fileName, 'file')
% if exist(filtered_fileName, 'file')&& Path.checkfiles
%     fprintf('------- Skipping high pass filtering: file exist --------\n');
%     D1 = spm_eeg_load(filtered_fileName);
%     return;
% else
    S.D = D.fnamedat;
    S.band = 'high';
    S.type = 'butterworth';
    S.freq = 0.5;
    S.dir = 'twopass';
    S.prefix = 'hp';
    D1 = spm_eeg_filter(S);
% end
% else
%     D1= [];
% end
end