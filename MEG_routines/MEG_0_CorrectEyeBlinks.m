function MEG_0_CorrectEyeBlinks(set_par,folders)
% remove_eyeblink_topography_walkthrough.m
% Artefact rejection practical, 1/12/2010
% Laurence Hunt - lhunt@fmrib.ox.ac.uk

%% 1. load in the data

subs = set_par.subs;

% what to do:
comp_eyeblinks = 1;
comp_average = 1;
comp_SVD = 1;
clear_data = 1;
chan2test = 'MRT31';
nu_comp = 1;

for s = 1:length(subs)
    for r = 2:set_par.NumRuns
        
        disp(['Sub#',num2str(s),'; run#',num2str(r)])
        
        filep = [folders.scan,'MEG_sub_' num2str(subs(s))];
        
        dataFile = [filep,'\hpdspmmeg_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];       
        if comp_eyeblinks
            matlabbatch{1}.spm.meeg.preproc.artefact.D = {dataFile};
            matlabbatch{1}.spm.meeg.preproc.artefact.mode = 'mark';
            matlabbatch{1}.spm.meeg.preproc.artefact.badchanthresh = 0.2;
            matlabbatch{1}.spm.meeg.preproc.artefact.append = true;
            matlabbatch{1}.spm.meeg.preproc.artefact.methods.channels{1}.chan = chan2test;
            matlabbatch{1}.spm.meeg.preproc.artefact.methods.fun.eyeblink.threshold = 4;
            matlabbatch{1}.spm.meeg.preproc.artefact.methods.fun.eyeblink.excwin = 0;
            matlabbatch{1}.spm.meeg.preproc.artefact.prefix = 'a';
            spm('defaults', 'EEG');
            spm_jobman('initcfg');
            
            spm_jobman('run', matlabbatch);
            
            clear matlabbatch
            
        end
        
        ydataFile = [filep,'\ahpdspmmeg_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        if comp_average
            matlabbatch{1}.spm.meeg.preproc.epoch.D = {ydataFile};
            matlabbatch{1}.spm.meeg.preproc.epoch.trialchoice.define.timewin = [-500 500];
            matlabbatch{1}.spm.meeg.preproc.epoch.trialchoice.define.trialdef.conditionlabel = 'Eyeblink';
            matlabbatch{1}.spm.meeg.preproc.epoch.trialchoice.define.trialdef.eventtype = 'artefact_eyeblink';
            matlabbatch{1}.spm.meeg.preproc.epoch.trialchoice.define.trialdef.eventvalue = chan2test;
            matlabbatch{1}.spm.meeg.preproc.epoch.trialchoice.define.trialdef.trlshift = 0;
            matlabbatch{1}.spm.meeg.preproc.epoch.bc = 0;
            matlabbatch{1}.spm.meeg.preproc.epoch.eventpadding = 0;
            matlabbatch{1}.spm.meeg.preproc.epoch.prefix = 'z';
            spm_jobman('run', matlabbatch);
            
            clear matlabbatch
        end
        
        % compute SVD:
        zydataFile = [filep,'\zahpdspmmeg_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        if comp_SVD
            matlabbatch{1}.spm.meeg.preproc.sconfounds.D = {zydataFile};
            matlabbatch{1}.spm.meeg.preproc.sconfounds.mode.svd.timewin = [-Inf Inf];
            matlabbatch{1}.spm.meeg.preproc.sconfounds.mode.svd.threshold = NaN;
            matlabbatch{1}.spm.meeg.preproc.sconfounds.mode.svd.ncomp = nu_comp;
            spm_jobman('run', matlabbatch);
            clear matlabbatch
        end
        
        % copy the confound definitions to '*ea*' file:
        if clear_data
            
            matlabbatch{1}.spm.meeg.preproc.sconfounds.D = {ydataFile};
            matlabbatch{1}.spm.meeg.preproc.sconfounds.mode.spmeeg.conffile = {zydataFile}
            spm_jobman('run', matlabbatch);
            clear matlabbatch
            
            matlabbatch{1}.spm.meeg.preproc.correct.D = {ydataFile};
            matlabbatch{1}.spm.meeg.preproc.correct.mode = 'ssp';
            matlabbatch{1}.spm.meeg.preproc.correct.prefix = 'T';
            spm_jobman('run', matlabbatch);
            clear matlabbatch
        end
        
    end
end

end