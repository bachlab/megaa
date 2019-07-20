subs = [1:5 7:9 11:25]; % Subjects

folder = '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/bf/pow_1-50_600ms';

%% Smooth first
for s = 1:numel(subs)
    disp(['Smoothing sub#',num2str(subs(s))])
    fileCol = [folder,'_P/uv_pow_cond_Col_ceOut_dnhpspmmeg_sub_',num2str(subs(s)),'_run_2.nii,1'];
    fileCau = [folder,'_N/uv_pow_cond_Cau_ceOut_dnhpspmmeg_sub_',num2str(subs(s)),'_run_2.nii,1'];
    sfileCol = [folder,'_P/suv_pow_cond_Col_ceOut_dnhpspmmeg_sub_',num2str(subs(s)),'_run_2.nii,1'];
    sfileCau = [folder,'_N/suv_pow_cond_Cau_ceOut_dnhpspmmeg_sub_',num2str(subs(s)),'_run_2.nii,1'];
    spm_smooth(fileCol,sfileCol,[10 10 10]);
    spm_smooth(fileCau,sfileCau,[10 10 10]);
end

job{1}.spm.stats.factorial_design.dir = {'/Users/gcastegnetti/Desktop/stds/MEGAA/analysis'};

for s = 1:numel(subs)
    fileCol = [folder,'_P/suv_pow_cond_Col_ceOut_dnhpspmmeg_sub_',num2str(subs(s)),'_run_2.nii,1'];
    fileCau = [folder,'_N/suv_pow_cond_Cau_ceOut_dnhpspmmeg_sub_',num2str(subs(s)),'_run_2.nii,1'];
    job{1}.spm.stats.factorial_design.des.pt.pair(s).scans = {fileCol; fileCau};
end

job{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
job{1}.spm.stats.factorial_design.des.pt.ancova = 0;
job{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
job{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
job{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
job{1}.spm.stats.factorial_design.masking.im = 1;
job{1}.spm.stats.factorial_design.masking.em = {''};
job{1}.spm.stats.factorial_design.globalc.g_omit = 1;
job{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
job{1}.spm.stats.factorial_design.globalm.glonorm = 1;

spm('defaults', 'EEG');
spm_jobman('run', job);