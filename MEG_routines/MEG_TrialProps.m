%% MEG_NumTrialsOutcomes
%
% Script to extract the number of trials in which the following for
% outcomes occurred:
%   1 - Go and collected
%   2 - Go and caught
%   3 - Go and not collected (but not caught)
%   4 - Stay
%
% Game struct, legend:
%   1-TokenNumber 2-TokenCount 3-TokenStay 4-TokenAppearance 5-TokenPosition(L/R) 6-FirstMovePosition 7,8-MovLatencies 9-Caught 10-Token
% 
% xy positions:
% ------------|------------------------------------------------------------
%    2,2      |
% 1,2 -- 2,1  |
%    1,1      |
% ------------|

clear
close all

subs = [1:5 7:9 11:25];

folder = 'D:\MATLAB\MATLAB_scripts\MEG\MEG_data\behavioural\';

for s = 1:length(subs)
    
    file = [folder,'AAA_05_MEG_Sno_',num2str(subs(s)),'.mat'];
    load(file)
    
    N = length(game);
    
    dataM = NaN(N-36,10);
    if s ~= 2
        for trl = 37:N
            dataM(trl-36,:) = [game(trl).record];
        end
    else
        for trl = 1:N
            dataM(trl,:) = [game(trl).record];
        end
    end
    
    if s ~= 2, game = game(37:end); end
    for trl = 1:540
        PL(trl) = game(trl).laststate.tokenloss; 
        TL(trl) = game(trl).laststate.predno;  
    end
    
    P = find(dataM(:,9) == 0 & dataM(:,10) == 1);
    N = find(dataM(:,9) == 1);
    f = find(dataM(:,6) ~= 0 & dataM(:,9) == 0 & dataM(:,10) == 0);
    S = find(dataM(:,6) == 0);
    
    Sanity(s) = length(P) + length(N) + length(f) + length(S);
    
    for tl = 1:3
        for pl = 1:6
            Conds_P(tl,pl,s)  = length(intersect(find(TL == tl & PL == pl-1),P));
            Conds_N(tl,pl,s)  = length(intersect(find(TL == tl & PL == pl-1),N));
            Conds_f(tl,pl,s)  = length(intersect(find(TL == tl & PL == pl-1),f));
        end
    end
end

P_mean = round(10*mean(Conds_P,3))/10;
N_mean = round(10*mean(Conds_N,3))/10;
f_mean = round(10*mean(Conds_f,3))/10;

P_std = round(10*std(Conds_P,0,3))/10;
N_std = round(10*std(Conds_N,0,3))/10;
f_std = round(10*std(Conds_f,0,3))/10;

T_mean = mean(squeeze(sum(sum(Conds_P + Conds_N))));
T_std = std(squeeze(sum(sum(Conds_P + Conds_N))));
R_mean = mean(squeeze(sum(sum(Conds_P))./sum(sum(Conds_N))));
R_std = std(squeeze(sum(sum(Conds_P))./sum(sum(Conds_N))));
