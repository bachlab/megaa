clear
% close all

subs = 1:23;

load('D:\MATLAB\MATLAB_scripts\MEG\MEG_steps_outputs_3\Out_STEP7_AutoC')

%% compute grand means
for s = 1:length(subs)
    AutoC_All_Real_Cau(s,:) = mean(Out_AutoC.AutoC_Real{s}.Cau,1);
    AutoC_All_Real_Col(s,:) = mean(Out_AutoC.AutoC_Real{s}.Col,1);
end
AutoC_Mean_Real_Cau = mean(AutoC_All_Real_Cau,1);
AutoC_Mean_Real_Col = mean(AutoC_All_Real_Col,1);

for p = 1:100
    for s = 1:length(subs)
        foo_perm_Cau(s,:) = mean(Out_AutoC.AutoC_Perm{s,p}.Cau,1);
        foo_perm_Col(s,:) = mean(Out_AutoC.AutoC_Perm{s,p}.Col,1);
    end
    AutoC_Mean_Perm_Cau(p,:) = mean(foo_perm_Cau,1);
    AutoC_Mean_Perm_Col(p,:) = mean(foo_perm_Col,1);
end

%% plot
perm_05_prctile_Cau = prctile(AutoC_Mean_Perm_Cau,5,1);
perm_95_prctile_Cau = prctile(AutoC_Mean_Perm_Cau,95,1);
perm_mean_Cau = mean(AutoC_Mean_Perm_Cau);

perm_05_prctile_Col = prctile(AutoC_Mean_Perm_Col,5,1);
perm_95_prctile_Col = prctile(AutoC_Mean_Perm_Col,95,1);
perm_mean_Col = mean(AutoC_Mean_Perm_Col);

tsp = 10:10:250;
figure('color',[1 1 1])
plot(tsp,perm_mean_Cau(2:end),'linewidth',2.5,'color','k'),hold on
plot(tsp,perm_05_prctile_Cau(2:end),'linewidth',1,'color','k','linestyle',':')
plot(tsp,perm_95_prctile_Cau(2:end),'linewidth',1,'color','k','linestyle',':')

figure,plot(mean(AutoC_Mean_Perm_Col))
hold on, plot(AutoC_Mean_Real_Col)