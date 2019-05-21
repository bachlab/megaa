function [] = MEG_DataClusters(set_par,In_Real,In_Perm)

subs = set_par.subs;

for s = 1:length(subs)
    RealDataSS_Cau(s,:) = mean(In_Real{s}.Cau.PL,2);
    RealDataSS_Col(s,:) = mean(In_Real{s}.Col.PL,2);
end
RealData_Cau = mean(RealDataSS_Cau,1);
RealData_Col = mean(RealDataSS_Col,1);

for p = 1:set_par.NumPerm
    PermDataAll = In_Perm{p};
    for s = 1:length(subs)
        PermDataSS_Cau(s,:) = mean(PermDataAll{s}.Cau.PL,2);
        PermDataSS_Col(s,:) = mean(PermDataAll{s}.Col.PL,2);
    end
    PermDataSP_Cau(p,:) = mean(PermDataSS_Cau,1);
    PermDataSP_Col(p,:) = mean(PermDataSS_Col,1);
end

DataPct_05_Cau = prctile(PermDataSP_Cau,5,1);
DataPct_95_Cau = prctile(PermDataSP_Cau,95,1);

DataPct_05_Col = prctile(PermDataSP_Col,5,1);
DataPct_95_Col = prctile(PermDataSP_Col,95,1);

figure,plot(DataPct_05_Cau,'color','k'), hold on
plot(DataPct_95_Cau,'color','k')
plot(RealData_Cau,'color','b','linewidth',2)

figure,plot(DataPct_05_Col,'color','k'), hold on
plot(DataPct_95_Col,'color','k')
plot(RealData_Col,'color','b','linewidth',2)

keyboard