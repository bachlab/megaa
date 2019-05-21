function [Count_out L_run] = MEG_DetectEyeblinksET(file)
% function that counts eyeblinks from the eyetracker (channel 316)
%
% G Castegnetti 2016

disp_fig = 0; % plot eyetracker trace for sanity check

D = spm_eeg_load(file);
d = D(:,:,:);
pd = d(316,:);
pd_end = find(pd > -0.1);
pd = zscore(pd(1:(pd_end(1)-1)));

L_run = round((pd_end(1)-1)/100);

Count = 0;
BlinksPos = [];
for i = 2:length(pd)
    if pd(i) < -2.5 && pd(i-1) > -2.5
        Count = Count + 1;
        BlinksPos = [BlinksPos i];
    end
end

Count_out = [Count 60*Count/L_run];

if disp_fig == 1
    figure,plot(pd), hold on
    plot(BlinksPos,-2.5*ones(length(BlinksPos),1),'marker','o')
end

end

