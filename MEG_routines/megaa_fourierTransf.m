function megaa_fourierTransf(par,data,conds)
%% Computes fourier
% ----------------------------------------------------
% G Castegnetti --- start: 06/2019

whichTp = par.whichTpTrain;
delibTime = par.deliberTime;
subs = par.subs;


%% Compute Fourier transform of the outcome representation
% ----------------------------------------------------
for s = 1:numel(subs)
    
    threatProb = conds{s}(:,2);
    if whichTp ~= 100
        trialsRetain = threatProb == whichTp;
    else
        trialsRetain = true(numel(threatProb),1);
    end
    
    conds{s}(~trialsRetain,:) = nan;
    
    choice = conds{s}(:,1);
    threatProb = conds{s}(:,2);
    threatMagn = conds{s}(:,3);
    
    % Take data
    % ----------------------------------------------------
    dataSub = [];
    try
        dataSub = data.out_4.PredCont{s}.Col;
    catch
        dataSub = data.Out_4.PredCont{s}.Col;
    end
    
    dataSub = [dataSub(:,1), dataSub(:,1), dataSub];
    for i = 1:540
        dataSub(i,:) = smooth(dataSub(i,:),8);
    end
    dataSub = dataSub(:,1:round(delibTime/10));
    
    
    fs = 100;            % Sampling frequency
    fT = 1/fs;            % Sampling period
    fsamples = 150;             % Length of signal
    ftime = (0:fsamples-1)*fT;       % Time vector
    for trl = 1:540
        if ~isnan(choice(trl))
            fY = fft(dataSub(trl,:));
            foo = abs(fY/fsamples);
            fVec(trl,:) = foo(1:fsamples/2+1);
        else
            fVec(trl,:) = nan(1,fsamples/2+1);
        end
    end
    xspan = fs*(0:(fsamples/2))/fsamples;
    fVec_sub(:,s) = nanmean(fVec,1);
    
%     figure,plot(fVec_sub(:,s))
    
    % Divide conditions by threat probability
    % ----------------------------------------------------
    trls.tp1(s,:) = mean(dataSub(threatProb == 1 & ~isnan(choice),:),1);
    trls.tp2(s,:) = mean(dataSub(threatProb == 2 & ~isnan(choice),:),1);
    trls.tp3(s,:) = mean(dataSub(threatProb == 3 & ~isnan(choice),:),1);
    
    
    % Divide conditions by threat magnitude
    % ----------------------------------------------------
    trls.tm0(s,:) = mean(dataSub(threatMagn == 0 & ~isnan(choice),:),1);
    trls.tm1(s,:) = mean(dataSub(threatMagn == 1 & ~isnan(choice),:),1);
    trls.tm2(s,:) = mean(dataSub(threatMagn == 2 & ~isnan(choice),:),1);
    trls.tm3(s,:) = mean(dataSub(threatMagn == 3 & ~isnan(choice),:),1);
    trls.tm4(s,:) = mean(dataSub(threatMagn == 4 & ~isnan(choice),:),1);
    trls.tm5(s,:) = mean(dataSub(threatMagn == 5 & ~isnan(choice),:),1);
    
    
    % Divide conditions by choice
    % ----------------------------------------------------
    trls.go(s,:) = mean(dataSub(choice == 1,:),1);
    trls.stay(s,:) = mean(dataSub(choice == -1,:),1);
    
end



%% Plot
% ----------------------------------------------------
figure('color',[1 1 1])
xspan = fs*(0:(fsamples/2))/fsamples;
plot(xspan,mean(fVec_sub',1),'linewidth',2), xlabel('Frequency (Hz)'), ylabel('Power')
set(gca,'fontsize',14)
