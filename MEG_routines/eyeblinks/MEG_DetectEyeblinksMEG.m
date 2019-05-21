function EyeblinksCont = MEG_DetectEyeblinksMEG(file,L_run,threshold)
% function that counts eyeblinks from MEG (all channels)
% G Castegnetti 2017

% fill structure to call 'spm_eeg_artefact_eyeblink_gc'
EyeCont.D = file;
EyeCont.mode = 'mark';
EyeCont.threshold = threshold;
EyeCont.append = 0;
EyeCont.excwin = 0;

% call 'spm_eeg_artefact_eyeblink_gc' for every channel
EyeblinksCont = NaN(340,3);
for ch = 33:307
    EyeCont.chanind = ch;
    [eyeb,~,~] = spm_eeg_artefact_eyeblink_gc(EyeCont);
    EyeblinksCont(ch,:) = [ch,eyeb,60*eyeb/L_run];
end


