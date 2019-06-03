subs = [1:5 7:9 11:25]; % Subjects
for s = 1:length(subs)
    
    dirSource = ['/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/imported/MEG_sub_',num2str(subs(s))];
    d = spm_select('List', dirSource, '^eOut.*\.mat$');
    
    files = cellstr([repmat([dirSource filesep],size(d,1),1) d]);
    
    S.D = char(files);
    S.recode = 'same';
    cd(dirSource)
    spm_eeg_merge(S)
    
end