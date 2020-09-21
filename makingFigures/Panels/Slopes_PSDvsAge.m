
yLimsPSD = [];
yLimsSlopes = [];
clear hAx goodSubsGPower
gNum = 1;
clear plotPosPSD; plotPosPSD = hPlotsPSDAgePos{30};
hPlotsPSD_CDR = subplot('position',[plotPosPSD(1) plotPosPSD(2) plotPosPSD(3) plotPosPSD(4)*30]);

clear PvsFAll blSlopsAll iAgeAll
PvsFAll = []; blSlopsAll = []; iCDRAll = [];
for iCDR = 1:2
    clear cdrCatAllSubs; 
    switch iCDR
        case 1; cdrGroup = controlSubsAll; clnStr = 'HV';
        case 2; cdrGroup = disSubsAll; clnStr = 'DV';
    end

    subplot(hPlotsPSD_CDR); hold on;
    clear PvsFGroup meanPvsF stdPvsF semPvsF txtStr        
    PvsFGroup = squeeze(log10(blPvsFSubAllElecs(iRef,cdrGroup,freqPoints)));
    numSubsGroup = size(PvsFGroup,1);

    % Plot PSDs
    clear bootStat meanPvsF stdPvsF semPvsF    
    bootStat = bootstrp(10000,getLoc,PvsFGroup);
    medianPvsF = getLoc(PvsFGroup); stdPvsF = std(bootStat);
    patch([freqAxis';flipud(freqAxis')],[medianPvsF'-stdPvsF';flipud(medianPvsF'+stdPvsF')],meanCDRColor(iCDR,:),'linestyle','none','FaceAlpha',0.4);
    plot(freqAxis,medianPvsF,'color',meanCDRColor(iCDR,:),'linewidth',1);  

    clear txtStr               
    txtStr = [clnStr ': ' num2str(numSubsGroup)];
    text(0.7,0.9-0.05*iCDR,txtStr,'unit','normalized','color',meanCDRColor(iCDR,:));

    PvsFAll = cat(2,PvsFAll,PvsFGroup');        
    iCDRAll = cat(2,iCDRAll,repmat(iCDR,1,size(PvsFGroup,1))); 
end

clear xValsAll yValsAll
xValsAll = []; yValsAll = [];
for iFreq=1:length(freqAxis)
    pPvsF2(iFreq) = kruskalwallis(PvsFAll(iFreq,:),iCDRAll,'off');

    clear xMidPos xBegPos xEndPos
    xMidPos = freqAxis(iFreq);
    if iFreq==1; xBegPos = xMidPos; else xBegPos = xMidPos-(freqAxis(iFreq)-freqAxis(iFreq-1))/2; end;
    if iFreq==length(freqAxis); xEndPos = xMidPos; else xEndPos = xMidPos+(freqAxis(iFreq+1)-freqAxis(iFreq))/2; end
    clear xVals; xVals = [xBegPos xEndPos xEndPos xBegPos]';
    clear yVals; yVals = [0 0 1 1]';
    xValsAll = cat(2,xValsAll,xVals);
    yValsAll = cat(2,yValsAll,yVals);    

    if squeeze(pPvsF2(iFreq))<0.05 && squeeze(pPvsF2(iFreq))>0.01;      
        subplot('position',hPlotsPSDAgePos{1});
        patch(xVals,yVals,'r','linestyle','none');
        axis tight;
    end

    if squeeze(pPvsF2(iFreq))<0.01;      
        subplot('position',hPlotsPSDAgePos{2});
        patch(xVals,yVals,'g','linestyle','none');
        axis tight;
    end
end
subplot('position',hPlotsPSDAgePos{1}); xlim([0 100]);
subplot('position',hPlotsPSDAgePos{2}); xlim([0 100]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
