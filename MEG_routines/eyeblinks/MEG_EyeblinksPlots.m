function EB_tot = MEG_EyeblinksPlots(IN,Count_ET,Count_MEG)
% function that plots eyeblinks data
%
% G Castegnetti 2016

NumRuns = IN.NumRuns;
subs = IN.subs;

EB_tot = zeros(340,1);

file = Count_MEG{s,r-1};
load(file)
pd = EyeblinksCont(:,2);
subplot(1,5,r-1),plot(pd), hold on
plot(Count_ET(r-1)*ones(length(pd),1),'r')
EB_tot = EB_tot + pd;
