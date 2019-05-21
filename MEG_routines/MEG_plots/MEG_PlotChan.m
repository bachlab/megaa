clear
% close all

mydir  = pwd;
idcs   = strfind(mydir,'/');
newdir = mydir(1:idcs(end)-1);
addpath(fullfile(mydir(1:idcs(end)-1),'MEG_plots'))

folders.scan = fullfile(newdir,'MEG_data','ScanData');
load(fullfile(newdir,'MEG_ROU_out','E0S135B0_t300','Out_S0_OptCha.mat'))

subs = [1:5 7:9 11:25];
NumRuns = 6;

Chan_all = Out_0.Chan_sub(:)-32;
for i = 1:275
    Chan_occurr(i) = -0.2+rand;%0*sum(Chan_all == i);
end

file = [folders.scan,'/MEG_sub_1/dnhpspmmeg_sub_1_run_2.mat'];
load(file)

% plot
eye_x = [D.channels(:).X_plot2D]'; % x for scatter plot
eye_y = [D.channels(:).Y_plot2D]'; % y for scatter plot
figure('color',[1 1 1])
scatter(eye_x, eye_y, 250, Chan_occurr, 'filled'), caxis([0 1])
colormap(gray)