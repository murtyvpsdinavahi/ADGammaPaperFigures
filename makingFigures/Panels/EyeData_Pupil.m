

for iCl=1:2
    noMSFlag=0; getDisSubsAndControlsList;
    
    switch iCl
        case 1; clnStr = 'MCI';
        case 2; clnStr = 'AD';
    end
    
    subIndexAll=[];
    meanCVPupilGoodSubsAll=[];
    for iCDR=1:2
        clear cdrCatAllSubs;
        switch iCDR
            case 1; cdrGroup = controlSubsAll;
            case 2; cdrGroup = disSubsAll;
        end
        clear goodSubsSGPower; goodSubsSGPower = allSGPower(cdrGroup);
        clear goodSubsFGPower; goodSubsFGPower = allFGPower(cdrGroup);
        clear goodSubsAge; goodSubsAge = allAge(cdrGroup);
        
        meanCVPupilGoodSubs = meanCVPupilAllSubs(setdiff(cdrGroup,noEyeDataSubs))';
        meanCVPupilGoodSubsAll = cat(2,meanCVPupilGoodSubsAll,meanCVPupilGoodSubs);
        subIndexAll = cat(2,subIndexAll,repmat(iCDR,size(meanCVPupilGoodSubs)));
        
        clear bootStat stdStat
        bootStat = bootstrp(10000,getLoc,meanCVPupilGoodSubs);
        stdStat = std(bootStat);
        
        subplot(hPlotsPupil(1,iCl)); hold on;
        bar(iCDR,nanmedian(meanCVPupilGoodSubs),'facecolor',meanCDRColor(iCDR,:),'facealpha',0.4);
        errorbar(iCDR,nanmedian(meanCVPupilGoodSubs),stdStat,'linestyle','none','marker','none','color','k');
    end
    
    pPupil(iCl) = kruskalwallis(meanCVPupilGoodSubsAll,subIndexAll,'off'); %#ok<SAGROW>
    set(gca,'xtick',[1 2],'xticklabel',{'HV' clnStr});
    if iCl==1; ylabel('CV of pupil diameter'); end;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
