%% megaa_bf_avgOutput
% Takes subjective chi-squared nifti maps computed by the beamformer and
% average them across subjects in a new nifti file.

clear
close all

spm eeg

subs = [1:5 7:9 11:25];
folder = '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/bf/freq1-49';

filenames = spm_select('List', folder, '^mv.*\.nii$');

for s = 1:numel(subs)
    
    chiMapFile = [folder filesep filenames(s,:)];
    chiMap(:,:,:,s) = spm_read_vols(spm_vol(chiMapFile));

end

chiMapMetadata = spm_vol(chiMapFile);
chiMapMetadata.fname = [folder,filesep,'chiMapAvg.nii'];

spm_write_vol(chiMapMetadata, nanmean(chiMap,4));