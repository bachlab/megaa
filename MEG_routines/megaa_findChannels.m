function out = megaa_findChannels(set_par,folders)
% G Castegnetti 2017
% find best channels according to number of eyeblinks

spm eeg

subs = set_par.subs;
NumRuns = set_par.NumRuns;

ChToRetain = 135; % number of best channels to retain for the analysis
EB_thresh = 4; % threshold for eyeblink recognition in MEG

EB_tot_MEG = zeros(275,1);
Chan_sub = zeros(ChToRetain,length(subs));
for s = 1:length(subs)
    a{s} = figure('color',[1 1 1]);
    EB_sub_MEG = zeros(275,1);
    for r = 2:NumRuns
        file = [folders.scan,'MEG_sub_',num2str(subs(s)),'/dnhpspmmeg_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        load(file)
       
        [EB_count_ET, L_run] = MEG_DetectEyeblinksET(file); % count eyeblinks from eyetracker
        EB_run_MEG = MEG_DetectEyeblinksMEG(file,L_run,EB_thresh); % count eyeblinks from MEG
        mkdir([folders.scan,'MEG_sub_',num2str(subs(s)),'\eyeblinks'])
        
        % plot
        eye_x = [D.channels(:).X_plot2D]'; % x for scatter plot
        eye_y = [D.channels(:).Y_plot2D]'; % y for scatter plot
        EB_run_MEG_275 = EB_run_MEG(33:307,2);
        set(0,'CurrentFigure',a{s})
        subplot(2,5,(r-1)+5),scatter(eye_x, eye_y, 20, EB_run_MEG_275, 'filled'),caxis([0 400])
        subplot(2,5,r-1),plot(EB_run_MEG_275),ylim([0 400]),title([int2str(subs(s)), 'N_{ET} = ',num2str(EB_count_ET(1)),', N_{MEG} = ',num2str(max(EB_run_MEG_275))])
        EB_sub_MEG = EB_sub_MEG + EB_run_MEG_275; % sum counts over sessions for single subject evaluation
    end
    [~, idx_sort_sub] = sort(EB_sub_MEG); % order single-sub sensors according to eyeblink count
    Chan_sub(:,s) = idx_sort_sub(1:ChToRetain); % retain only so many channels for single sub.
    EB_tot_MEG = EB_tot_MEG + EB_sub_MEG; % sum counts over subjects
end
[~, idx_sort_tot] = sort(EB_tot_MEG); % order sensors according to eyeblink count

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% 32 MUST BE ADDED TO OFFSET THE CHANNEL NUMBERS %%%%%%%%%%%%%%
out.Chan_sub = 32 + Chan_sub;
out.Chan_tot = 32 + idx_sort_tot(1:ChToRetain); % retain only so many channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%