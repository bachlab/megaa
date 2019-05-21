function D1 = downsample_MEG(D, Path)
% Function downsample_MEG.m downsamples the original/filtered MEG data to
% provided sampling frequency. We perform this analysis to compute time
% frequency spectrogram as original data is sampled at high frequency.
% Input
%       D = An MEG object containing MEG data
%       Path = a structure containing the name of folders and checkfile
%       parameter
% Output:
%       D1 = An MEG object containing the output of notch_filter_MEG.m
% Created by Saurabh Khemka on 31-07-2014
% Last edited on :

S.D = D.fnamedat;
S.fsample_new = 100; % new sampling rate
S.prefix='d';
D1 = spm_eeg_downsample(S);

end