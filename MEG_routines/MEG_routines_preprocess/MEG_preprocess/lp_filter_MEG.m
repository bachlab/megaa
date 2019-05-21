function Dnew = lp_filter_MEG(Dtemp, Path)
%% Function Dnew = lp_filter_MEG(Dtemp, Path) is used to low pass filter MEG 
% data. It uses spm_eeg_filter() for filtering
% Input:
%       Dtemp: Meeg data object used for filtering
%       Path: A structure containing different paths and initial variables
% Outut:
%       Dnew: Meeg object with filtered dataset
% Created by saurabh Khemka: saurabh.khemka@uzh.ch
% Date: 14-05-2014
% checked & adapted by Dominik R Bach 14.10.2016
%%-------------------------------------------------------------------------
% last edited 14.10.2016

% Check the no of inputs:
if nargin < 2
    error('Not enough inputs: error in lp_filter_MEG.m');
end
[tempFolder, ~, ~] = fileparts(Dtemp.fnamedat);
filtered_fileName = fullfile(tempFolder, ['lp_' Dtemp.fname]);
if exist(filtered_fileName, 'file')&& Path.checkfiles
    fprintf('-----Skipping low pass filtering: file exist -----------\n');
    Dnew = spm_eeg_load(filtered_fileName);
    return
else
    S.D = Dtemp.fnamedat;
    S.band = 'low';
    S.type = 'butterworth';
    S.freq = 150;
    S.dir = 'twopass';
    S.prefix = 'lp_';
    Dnew = spm_eeg_filter(S);
end
end