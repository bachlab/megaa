function filename = preprocessing_MEG
% preprocessing_meg.m is a script to preprocess MEG data
% Created by Saurabh Khemka: saurabh.khemka@uzh.ch
% Date: 12.05.2014
% checked & adapted by Dominik R Bach 14.10.2016
% adapted to match Kurth-Nelson et al. 2016 by G Castegnetti 09.01.2017
%%-------------------------------------------------------------------------
% last edited 02.05.2017 by G Castegnetti

clear all
close all
% addpath D:\MATLAB\MATLAB_tools\spm12\
spm('defaults', 'EEG');


% Path of raw data of MEG and preprocessed data after analysis.
Path.raw.dataDir = '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/raw';
Path.analysed.dataDir = '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/imported';
Path.checkfiles = 1;
% List of all the subjects
subList = [1:5 7:9 11:25];
for subIndex = 1:length(subList)
    % Name of the subject specific folder
    Path.raw.sub_mainFolderName = ['MEG_sub_' num2str(subList(subIndex))];
    Path.raw.sub_dataFolders = dir(fullfile(Path.raw.dataDir, ...
        Path.raw.sub_mainFolderName,'*.ds'));
    % Check if the data folder is empty for this subject
    if isempty(Path.raw.sub_mainFolderName)
        error('MEG raw data folder is empty')
    end
    
    disp(['*** Preprocessing subject ' num2str(subList(subIndex)) ' ****']);
    for folderIndex = 2:length(Path.raw.sub_dataFolders)
        Path.raw.sub_fileName = dir(fullfile(Path.raw.dataDir,Path.raw.sub_mainFolderName,...
            Path.raw.sub_dataFolders(folderIndex).name, '*.meg4'));
        
        % Name of subject specific raw data file full path
        dataFileName = fullfile(Path.raw.dataDir,Path.raw.sub_mainFolderName,...
        Path.raw.sub_dataFolders(folderIndex).name,...
        Path.raw.sub_fileName.name);
        %% Convert the raw data into mat and data file
        %------------------------------------------------------------------
        D = convert_raw_MEG(dataFileName, Path, subList(subIndex), folderIndex);
        
%         %% Reducing file size
%         Dcropped = crop_meg(D);
        
        %% High pass filter the MEG data
        % -----------------------------------------------------------------
        D1 = hp_raw_MEG(D, Path);
        
        %% High pass filter the MEG data
        % -----------------------------------------------------------------
        D2 = notch_filter_MEG(D1, Path);
        
        %% Downsampling
        %------------------------------------------------------------------
        D3 = downsample_MEG(D2, Path);
        filename{subIndex,folderIndex} = fullfile(path(D3),fname(D3));
        
    end
end
