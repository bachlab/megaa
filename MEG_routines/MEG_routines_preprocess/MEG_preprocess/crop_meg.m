function Dtemp = crop_meg(Dnew, varargin)
if nargin <1
    error('Not enough input: error in crop_meg.m');
end

S.D = Dnew.fnamedat;
S.prefix = 'c';
chanindices= 33:307;
S.channels = Dnew.chanlabels(chanindices);
Dtemp = spm_eeg_crop(S);
end