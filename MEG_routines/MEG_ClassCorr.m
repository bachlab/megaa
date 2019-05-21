function Out_ClassCorr = MEG_ClassCorr(set_par,In_5,idx)

subs = set_par.subs;
NumPerm = set_par.NumPerm;
MinDuration = set_par.Epoch_Dur;
MinDur_idx = round(MinDuration/10);

Cau_Real = cell(length(subs),1);
Col_Real = cell(length(subs),1);
Corr_All_Real = NaN(length(subs),MinDur_idx);
figure
for s = 1:length(subs)
    Cau_Real{s} = In_5.PredCont{s}.Cau(idx{s}.All,1:MinDur_idx);
    Col_Real{s} = In_5.PredCont{s}.Col(idx{s}.All,1:MinDur_idx);
    
    for i = 1:MinDur_idx
       foo = corrcoef(Cau_Real{s}(:,i),Col_Real{s}(:,i));
       Corr_All_Real(s,i) = foo(2,1);
    end
    subplot(5,5,s),plot(smooth(Corr_All_Real(s,:)))
end
figure,plot(smooth(mean(Corr_All_Real,1)))
Out_ClassCorr = 1;