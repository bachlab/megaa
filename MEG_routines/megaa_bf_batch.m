%-----------------------------------------------------------------------
% Job saved on 17-May-2019 12:40:29 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (12.2)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

subs = [1:5 7:9 11:25];

for s = 1:length(subs)
    
    % Update user
    disp(['Computing source localisation for sub#',num2str(subs(s))])
    
    subFolder = ['/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/imported/MEG_sub_',num2str(subs(s))];
    
    data = spm_select('List', subFolder, '^ceOut.*\.mat$');
    files = cellstr([repmat([subFolder filesep],size(data,1),1) data]);
    
    
    bf_dir = [subFolder,filesep,'bf_1-49_pow'];
    if ~exist(bf_dir,'dir'), mkdir(bf_dir), end
    
    
    %% Prepare input data
    % --------------------------------------------------------------
    job{1}.spm.meeg.source.headmodel.D = files;
    job{1}.spm.meeg.source.headmodel.val = 1;
    job{1}.spm.meeg.source.headmodel.comment = '';
    job{1}.spm.meeg.source.headmodel.meshing.meshes.template = 1;
    job{1}.spm.meeg.source.headmodel.meshing.meshres = 2;
    job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'nas';
    job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.select = 'nas';
    job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'lpa';
    job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.select = 'FIL_CTF_L';
    job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'rpa';
    job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.select = 'FIL_CTF_R';
    job{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 0;
    job{1}.spm.meeg.source.headmodel.forward.eeg = 'EEG BEM';
    job{1}.spm.meeg.source.headmodel.forward.meg = 'Single Shell';
    
    job{2}.spm.tools.beamforming.data.dir = {bf_dir};
    job{2}.spm.tools.beamforming.data.D(1) = cfg_dep('M/EEG head model specification: M/EEG dataset(s) with a forward model', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','D'));
    job{2}.spm.tools.beamforming.data.val = 1;
    job{2}.spm.tools.beamforming.data.gradsource = 'inv';
    job{2}.spm.tools.beamforming.data.space = 'MNI-aligned';
    job{2}.spm.tools.beamforming.data.overwrite = 0;
    job{3}.spm.tools.beamforming.sources.BF(1) = cfg_dep('Prepare data: BF.mat file', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
    
    
    %% Define source space for beamforming
    % --------------------------------------------------------------
    job{3}.spm.tools.beamforming.sources.reduce_rank = [2 3];
    job{3}.spm.tools.beamforming.sources.keep3d = 1;
    job{3}.spm.tools.beamforming.sources.plugin.grid.resolution = 5;
    job{3}.spm.tools.beamforming.sources.plugin.grid.space = 'MNI template';
    job{3}.spm.tools.beamforming.sources.visualise = 1;
    
    
    %% Define features for covariance computation
    % --------------------------------------------------------------
    job{4}.spm.tools.beamforming.features.BF(1) = cfg_dep('Define sources: BF.mat file', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
    job{4}.spm.tools.beamforming.features.whatconditions.all = 1;
    job{4}.spm.tools.beamforming.features.woi = [0 600];
    job{4}.spm.tools.beamforming.features.modality = {'MEG'};
    job{4}.spm.tools.beamforming.features.fuse = 'no';
    job{4}.spm.tools.beamforming.features.plugin.cov.foi = [1 49];
    job{4}.spm.tools.beamforming.features.plugin.cov.taper = 'hanning';
    job{4}.spm.tools.beamforming.features.regularisation.minkatrunc.reduce = 1;
    job{4}.spm.tools.beamforming.features.bootstrap = false;
    
    
    %% Compute inverse projectors
    % --------------------------------------------------------------
    job{5}.spm.tools.beamforming.inverse.BF(1) = cfg_dep('Covariance features: BF.mat file', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
    job{5}.spm.tools.beamforming.inverse.plugin.lcmv.orient = true;
    job{5}.spm.tools.beamforming.inverse.plugin.lcmv.keeplf = false;
    
    
    %% Compute output
    % --------------------------------------------------------------
    job{6}.spm.tools.beamforming.output.BF(1) = cfg_dep('Inverse solution: BF.mat file', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
%     job{6}.spm.tools.beamforming.output.plugin.image_mv.isdesign.custom.whatconditions.condlabel = {'Col';'Cau'}';
%     job{6}.spm.tools.beamforming.output.plugin.image_mv.isdesign.custom.contrast = [1 -1];
%     job{6}.spm.tools.beamforming.output.plugin.image_mv.isdesign.custom.woi = [0 600];
%     job{6}.spm.tools.beamforming.output.plugin.image_mv.datafeatures = 'sumpower';
%     job{6}.spm.tools.beamforming.output.plugin.image_mv.foi = [1 49];
%     job{6}.spm.tools.beamforming.output.plugin.image_mv.result = 'chi square';
%     job{6}.spm.tools.beamforming.output.plugin.image_mv.sametrials = false;
%     job{6}.spm.tools.beamforming.output.plugin.image_mv.modality = 'MEG';
    
    job{6}.spm.tools.beamforming.output.plugin.image_power.whatconditions.condlabel = {'Col';'Cau'}';
    job{6}.spm.tools.beamforming.output.plugin.image_power.sametrials = false;
    job{6}.spm.tools.beamforming.output.plugin.image_power.woi = [0 600];
    job{6}.spm.tools.beamforming.output.plugin.image_power.foi = [0 49];
    job{6}.spm.tools.beamforming.output.plugin.image_power.contrast = 1;
    job{6}.spm.tools.beamforming.output.plugin.image_power.logpower = false;
    job{6}.spm.tools.beamforming.output.plugin.image_power.result = 'singleimage';
    job{6}.spm.tools.beamforming.output.plugin.image_power.scale = 1;
    job{6}.spm.tools.beamforming.output.plugin.image_power.powermethod = 'trace';
    job{6}.spm.tools.beamforming.output.plugin.image_power.modality = 'MEG';
    
    %% Write out results
    % --------------------------------------------------------------
    job{7}.spm.tools.beamforming.write.BF(1) = cfg_dep('Output: BF.mat file', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
    job{7}.spm.tools.beamforming.write.plugin.nifti.normalise = 'no';
    job{7}.spm.tools.beamforming.write.plugin.nifti.space = 'mni';
    
    
    %% run batch
    % --------------------------------------------------------------
    spm('defaults', 'EEG');
    spm_jobman('run', job);
    
end


