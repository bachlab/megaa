%% megaa_bf_avgOutput
% Takes subjective chi-squared nifti maps computed by the beamformer and
% average them across subjects in a new nifti file.

clear
close all

restoredefaultpath, clear RESTOREDEFAULTPATH_EXECUTED
fs = filesep;

addpath('/Users/gcastegnetti/Desktop/tools/matlab/spm12')

spm eeg

subs = [1:5 7:9 11:25];
folderChi = '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/bf/chiSq_0-50_bc_N';

filenames = spm_select('List', folderChi, '^mv.*\.nii$');

for s = 1:numel(subs)
    
    chiMapFile = [folderChi filesep filenames(s,:)];
    chiMap(:,:,:,s) = spm_read_vols(spm_vol(chiMapFile));
    
end

chiMapMetadata = spm_vol(chiMapFile);
chiMapMetadata.fname = [folderChi,filesep,'chiMap.nii'];

% Write chi-map or pow-map
% --------------------------------------------------
spm_write_vol(chiMapMetadata, nanmean(chiMap,4));

% Create t-map
% --------------------------------------------------
% tMap = zeros(size(chiMap,1),size(chiMap,2),size(chiMap,3));
% for x = 1:size(chiMap,1)
%     disp(['x = ',num2str(x)])
%     for y = 1:size(chiMap,2)
%         for z = 1:size(chiMap,3)
%             if ~isnan(sum(chiMap(x,y,z,:)))
%                 [~,~,~,stats] = ttest(squeeze(chiMap(x,y,z,:)));
%                 tMap(x,y,z) = stats.tstat;
%             end
%         end
%     end
% end
% 
% tMapMetadata = spm_vol(chiMapFile);
% tMapMetadata.fname = [folderChi,filesep,'tMap.nii'];
% tMapMetadata.descrip =  'R-map';
% spm_write_vol(tMapMetadata, tMap);


% t-test between conditions
% --------------------------------------------------
% folderCol = '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/bf/freq_0-49_Col';
% folderCau = '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/bf/freq_0-49_Cau';
% 
% filenamesCol = spm_select('List', folderCol, '^uv.*\.nii$');
% filenamesCau = spm_select('List', folderCau, '^uv.*\.nii$');
% 
% for s = 1:numel(subs)
%     
%     mapFileCol = [folderCol filesep filenamesCol(s,:)];
%     mapFileCau = [folderCau filesep filenamesCau(s,:)];
%     
%     sourceMapCol(:,:,:,s) = spm_read_vols(spm_vol(mapFileCol));
%     sourceMapCau(:,:,:,s) = spm_read_vols(spm_vol(mapFileCau));
%     
% end
% 
% tMap2Conds = zeros(size(sourceMapCol,1),size(sourceMapCol,2),size(sourceMapCol,3));
% for x = 1:size(sourceMapCol,1)
%     disp(['x = ',num2str(x)])
%     for y = 1:size(sourceMapCol,2)
%         for z = 1:size(sourceMapCol,3)
%             if ~isnan(sum(sourceMapCol(x,y,z,:)))
%                 [~,~,~,stats] = ttest(squeeze(sourceMapCau(x,y,z,:) - sourceMapCol(x,y,z,:)));
%                 tMap2Conds(x,y,z) = stats.tstat;
%             end
%         end
%     end
% end
% 
% tMap2CondsMetadata = spm_vol(mapFileCol);
% tMap2CondsMetadata.fname = [folderCol,filesep,'tMap2Conds.nii'];
% tMap2CondsMetadata.descrip = 't-map';
% spm_write_vol(tMap2CondsMetadata, tMap2Conds);
