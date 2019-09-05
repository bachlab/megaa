function out = megaa_classifyDelib(par,folders,In_1,In_3)
%% ----------------------------------------------------
% Computes probability of representations during decision phase, either
% upon token appearance or trial start
% ----------------------------------------------------
% G Castegnetti --- start: 2017 --- last update: 05/2019

%% Unpack parameters
% ----------------------------------------------------
align = par.align; % 1 = aligned to token appearance; 2 = aligned to trial start;
subs = par.subs;
numRuns = par.NumRuns;
n_trials = par.NumTrials; 
numPerm = par.NumPerm; clear set_par

out.PredCont = cell(length(subs),1);
for s = 1:length(subs)
    
    for r = 2:numRuns
        
        % load epochs to analyse
        % ----------------------------------------------------
        if align == 1
            fileDelib = [folders.scan,'MEG_sub_',num2str(subs(s)),'/eTok_dnhpspmmeg_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        elseif align == 2
            fileDelib = [folders.scan,'MEG_sub_',num2str(subs(s)),'/eTrl_dnhpspmmeg_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        end
        
        load(fileDelib)
        dDelib(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(:,:,:); clear D
        
    end
    
    % Prepare matrix with deliberation data to classify
    % ----------------------------------------------------
    d_Class = dDelib(In_1{s}.Chan,:,:);
    nBins_class = size(d_Class,2);
    clear fileDelib dDelib foo r
    
    keyboard
    %% Classify MEG activity during deliberation
    % ----------------------------------------------------
    for trl = 1:n_trials
        disp(['sub#',num2str(subs(s)),' of ',int2str(subs(end)),'; trial ' int2str(trl) ' of ' int2str(n_trials) '...']); drawnow % update user
        for t = 1:nBins_class
            X_Test = squeeze(d_Class(:,t,trl)); % take vector of predictors (i.e. B at the sensors)
            
            % Cau classifier
            test_Cau_foo = In_3.OptClass{s}.Cau.*X_Test;                        % create linear combination of Coeff*Feat
            linComb_Cau = sum(test_Cau_foo) + In_3.OptFitInfo{s}.Cau.Intercept; % add intercept
            out.PredCont{s}.Cau(trl,t) = 1/(1+exp(-linComb_Cau));               % sigmoid function
            
            % Col classifier
            test_Col_foo = In_3.OptClass{s}.Col.*X_Test;
            linComb_Col = sum(test_Col_foo) + In_3.OptFitInfo{s}.Col.Intercept;
            out.PredCont{s}.Col(trl,t) = 1/(1+exp(-linComb_Col));
            
            % now classify data with wrong classifiers
            for p = 1:numPerm
                
                % Cau perm classifier
                Test_Cau_foo_p = In_3.PermClass{s,p}.Cau.*X_Test;                        % create linear combination of Coeff*Feat
                LinComb_Cau_p = sum(Test_Cau_foo_p) + In_3.PermFitInfo{s}.Cau.Intercept; % add intercept
                out.PredCont_perm{s,p}.Cau(trl,t) = 1/(1+exp(-LinComb_Cau_p));           % sigmoid function
                
                % Col perm classifier
                Test_Col_foo_p = In_3.PermClass{s,p}.Col.*X_Test; 
                LinComb_Col_p = sum(Test_Col_foo_p) + In_3.PermFitInfo{s}.Col.Intercept;
                out.PredCont_perm{s,p}.Col(trl,t) = 1/(1+exp(-LinComb_Col_p)); 
                
            end
        end
    end
    
    clear Test_Cau_foo Test_Col_foo Test_Bas_foo LinComb_Cau LinComb_Col LinComb_Bas 
    clear Test_Cau_foo_p Test_Col_foo_p Test_Bas_foo_p LinComb_Cau_p LinComb_Col_p LinComb_Bas_p t trl X_Test
    
end
