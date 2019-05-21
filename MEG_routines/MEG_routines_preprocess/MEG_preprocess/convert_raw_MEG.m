function D = convert_raw_MEG(data_file, Path, subNum, runNum)
%% convert_raw_MEG.m is a function to convert raw MEG data to readable MEG
% data.
% Input:
%       data_file: Name of raw data file
%       Path: a structure containing name of output and input folders
% Output:
%       D = output of the spm_conver_eeg.m
% Created by saurabh Khemka: saurabh.khemka@uzh.ch
% Date: 12-05-2014
% checked & adapted by Dominik R Bach 14.10.2016
%%-------------------------------------------------------------------------
% last edited 14.10.2016

% Check if raw data file exist
if ~exist(data_file, 'file')
    error('MEG raw data is not present: error in extracting raw data')
end
% % Check if converted data file exist
% [~, temp, ~] = fileparts(Path.raw_fileName.name);
Path.analysed.conFileName = fullfile(Path.analysed.dataDir,...
    Path.raw.sub_mainFolderName,['spmmeg_sub_' num2str(subNum) '_run_' num2str(runNum) '.dat']);

if ~exist(fullfile(Path.analysed.dataDir,Path.raw.sub_mainFolderName), 'dir')
    mkdir(fullfile(Path.analysed.dataDir,Path.raw.sub_mainFolderName));
end

if exist(Path.analysed.conFileName, 'file') && Path.checkfiles
    fprintf('--------- Skipping conversion: file exist ---------------\n')
    D = spm_eeg_load(Path.analysed.conFileName);
    return;
else
    S.dataset = data_file;
    S.outfile = fullfile(Path.analysed.dataDir,Path.raw.sub_mainFolderName,['spmmeg_sub_' num2str(subNum) '_run_' num2str(runNum) '.dat']);
    D = spm_eeg_convert(S);
end
end