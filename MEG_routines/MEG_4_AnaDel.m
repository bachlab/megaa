function Out = MEG_4_AnaDel(set_par,folders,In_1,In_3)
% Computes probability of representations during decision phase, either
% upon token appearance or trial start
% G Castegnetti 2017

%% unpack parameters
align = set_par.align; % 1 = aligned to token appearance; 2 = aligned to trial start;
subs = set_par.subs;
NumRuns = set_par.NumRuns;
n_trials = set_par.NumTrials; 
NumPerm = set_par.NumPerm; clear set_par

Out.PredCont = cell(length(subs),1);
for s = 1:length(subs)
    
    for r = 2:NumRuns
        
        %% load epochs to analyse
        if align == 1
            file_Analyse = [folders.scan,'MEG_sub_',num2str(subs(s)),'/eTok_dnhpspmmeg_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        elseif align == 2
            file_Analyse = [folders.scan,'MEG_sub_',num2str(subs(s)),'/eTrl_dnhpspmmeg_sub_',num2str(subs(s)),'_run_',num2str(r),'.mat'];
        end
        
        load(file_Analyse)
        d_Analyse(:,:,(108*(r-2)+1):(108*(r-1))) = D.data(:,:,:); clear D
        
    end
    
    %% fill matrix to classify
    d_Class = d_Analyse(In_1{s}.Chan,:,:);
    N_bins_class = size(d_Class,2);
    clear file_Analyse d_Analyse foo r
    
    %% classify bins during deliberation phase (real labels)
    for trl = 1:n_trials
        disp(['sub#',num2str(subs(s)),' of ',int2str(subs(end)),'; trial ' int2str(trl) ' of ' int2str(n_trials) '...']); drawnow % update user
        for t = 1:N_bins_class
            X_Test = squeeze(d_Class(:,t,trl)); % take vector of predictors (i.e. B at the sensors)
            
            % Cau classifier
            Test_Cau_foo = In_3.OptClass{s}.Cau.*X_Test;                        % create linear combination of Coeff*Feat
            LinComb_Cau = sum(Test_Cau_foo) + In_3.OptFitInfo{s}.Cau.Intercept; % add intercept
            Out.PredCont{s}.Cau(trl,t) = 1/(1+exp(-LinComb_Cau));               % sigmoid function
            
            % Col classifier
            Test_Col_foo = In_3.OptClass{s}.Col.*X_Test;
            LinComb_Col = sum(Test_Col_foo) + In_3.OptFitInfo{s}.Col.Intercept;
            Out.PredCont{s}.Col(trl,t) = 1/(1+exp(-LinComb_Col));
            
%             % Bas classifier
%             Test_Bas_foo = In_3.OptClass{s}.Bas.*X_Test;
%             LinComb_Bas = sum(Test_Bas_foo) + In_3.OptFitInfo{s}.Bas.Intercept;
%             Out.PredCont{s}.Bas(trl,t) = 1/(1+exp(-LinComb_Bas));
            
            % now classify data with wrong classifiers
            for p = 1:NumPerm
                
                % Cau perm classifier
                Test_Cau_foo_p = In_3.PermClass{s,p}.Cau.*X_Test;                        % create linear combination of Coeff*Feat
                LinComb_Cau_p = sum(Test_Cau_foo_p) + In_3.PermFitInfo{s}.Cau.Intercept; % add intercept
                Out.PredCont_perm{s,p}.Cau(trl,t) = 1/(1+exp(-LinComb_Cau_p));           % sigmoid function
                
                % Col perm classifier
                Test_Col_foo_p = In_3.PermClass{s,p}.Col.*X_Test; 
                LinComb_Col_p = sum(Test_Col_foo_p) + In_3.PermFitInfo{s}.Col.Intercept;
                Out.PredCont_perm{s,p}.Col(trl,t) = 1/(1+exp(-LinComb_Col_p)); 
                
%                 % Bas perm classifier
%                 Test_Bas_foo_p = In_3.PermClass{s,p}.Bas.*X_Test;
%                 LinComb_Bas_p = sum(Test_Bas_foo_p) + In_3.PermFitInfo{s}.Bas.Intercept;
%                 Out.PredCont_perm{s,p}.Bas(trl,t) = 1/(1+exp(-LinComb_Bas_p));
            end
        end
    end
    
    clear Test_Cau_foo Test_Col_foo Test_Bas_foo LinComb_Cau LinComb_Col LinComb_Bas 
    clear Test_Cau_foo_p Test_Col_foo_p Test_Bas_foo_p LinComb_Cau_p LinComb_Col_p LinComb_Bas_p t trl X_Test
    
end
