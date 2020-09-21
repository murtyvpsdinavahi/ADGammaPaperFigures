

for iCl = 1:2

    getDisSubsAndControlsList;
    
    for iCDR=1:2
            clear cdrCatAllSubs; 
            switch iCDR
                case 1; cdrGroup = controlSubsAll; subText = 'Healthy';
                case 2; cdrGroup = disSubsAll; subText = clnText;
            end
            
        eyeDataForSub = squeeze(meanEyeXDataAllSubs(cdrGroup,:));
        noEyeDataSubs = isnan(mean(eyeDataForSub,2)) | sum(eyeDataForSub==zeros(size(eyeDataForSub)),2)==size(eyeDataForSub,2);
        for iDir = 1:2
        
            clear eyeAllSubs PvsFGroup
            if iDir==1; eyeAllSubs = meanEyeXDataAllSubs; elseif iDir==2; eyeAllSubs = meanEyeYDataAllSubs; end;
            PvsFGroup = squeeze(eyeAllSubs(cdrGroup,:));            
            PvsFGroup(noEyeDataSubs,:)=[];

            subplot(hPlotsEye(iDir,iCl)); hold on;
            clear meanPvsF stdPvsF semPvsF
            clear bootStat
            bootStat = bootstrp(10000,getLoc,PvsFGroup);
            medianPvsF = getLoc(PvsFGroup); stdPvsF = std(bootStat);
            patch([timeValsEyePos';flipud(timeValsEyePos')],[medianPvsF'-stdPvsF';flipud(medianPvsF'+stdPvsF')],meanCDRColor(iCDR,:),'linestyle','none','FaceAlpha',0.4);
            plot(timeValsEyePos,medianPvsF,'color',meanCDRColor(iCDR,:),'linewidth',1); 
            xlim([-0.5 0.75]); ylim([-0.15 0.15]);
            
            if iDir==1
                text(0.1,0.9-0.1*iCDR,[subText ': ' num2str(size(PvsFGroup,1))],'unit','normalized','color',meanCDRColor(iCDR,:));
            end
        end    
    
        clear PvsFGroup
        PvsFGroup = squeeze(psthMSAllSubs(cdrGroup,:));
        PvsFGroup(noEyeDataSubs,:)=[];
        subplot(hPlotsEye(3,iCl)); hold on;
        clear meanPvsF stdPvsF semPvsF
        clear bootStat
        bootStat = bootstrp(10000,getLoc,PvsFGroup);
        medianPvsF = getLoc(PvsFGroup); stdPvsF = std(bootStat);
        patch([timeValsMS';flipud(timeValsMS')],[medianPvsF'-stdPvsF';flipud(medianPvsF'+stdPvsF')],meanCDRColor(iCDR,:),'linestyle','none','FaceAlpha',0.4);
        plot(timeValsMS,medianPvsF,'color',meanCDRColor(iCDR,:),'linewidth',1);
        xlim([-0.5 0.75]); ylim([-1 3]);
        
        text(0.1,0.9-0.1*iCDR,[subText ': ' num2str(size(PvsFGroup,1))],'unit','normalized','color',meanCDRColor(iCDR,:));            
    drawnow;
    end
end

for iCl = 1:2
    
    noEyeDataSubs = find(isnan(meanMSFreqAllSubs));
    getDisSubsAndControlsList;
    
    for iCDR=1:2
            clear cdrCatAllSubs; 
            switch iCDR
                case 1; cdrGroup = controlSubsAll; cdrString = 'HV';
                case 2; cdrGroup = disSubsAll; if iCl==1; cdrString = 'MCI'; elseif iCl==2; cdrString = 'AD'; end;
            end
        clear subGroup; subGroup = setdiff(cdrGroup,noEyeDataSubs);

        clear MSMagCell; MSMagCell = MSMagAllSubs(subGroup);
        clear peakVelocityCell; peakVelocityCell = peakVelocityAllSubs(subGroup);

        clear MSMagMat; MSMagMat=[];
        clear peakVelocityMat; peakVelocityMat=[];
        for iSub = 1:length(subGroup)
            MSMagMat = cat(2,MSMagMat,MSMagCell{iSub});
            peakVelocityMat = cat(2,peakVelocityMat,peakVelocityCell{iSub});
        end

        numMS(iCl,iCDR) = length(MSMagMat);
        MSMagMatMedian(iCl,iCDR) = median(MSMagMat);
        peakVelocityMatMedian(iCl,iCDR) = median(peakVelocityMat);
        meanMSFreq(iCl,iCDR) = median(meanMSFreqAllSubs(subGroup)); clear bootStatMS; bootStatMS = bootstrp(10000,@median,meanMSFreqAllSubs(subGroup)); semMSFreq(iCl,iCDR) = std(bootStatMS);
        subplot(hPlotsMS(iCl)); hold on;  
        plot(log10(MSMagMat),log10(peakVelocityMat),'linestyle','none','marker','.','markersize',1,'color',meanCDRColor(iCDR,:));
        xlim([-2 2]); ylim([0 3]);
        
    end

    subplot(hPlotsMS(iCl)); hold on;
    pasteAsImage(subplot(hPlotsMS(iCl)));
    axis square;
    text(0.1,0.9,'m,se=','unit','normalized');
    text(0.1,0.8,'n=','unit','normalized');
    for iCDR = 1:2
        plot(log10(MSMagMatMedian(iCl,iCDR)),log10(peakVelocityMatMedian(iCl,iCDR)),'marker','+','markersize',6,'color',meanCDRColor(iCDR,:));
        text(0.3*iCDR,0.9,[num2str(round(meanMSFreq(iCl,iCDR),2),2) ',' num2str(round(semMSFreq(iCl,iCDR),2),2) ' /s'],'unit','normalized','color',meanCDRColor(iCDR,:));
        text(0.2*iCDR,0.8,num2str(numMS(iCl,iCDR)),'unit','normalized','color',meanCDRColor(iCDR,:));
    end
    ylabel('Peak velocity (deg/s)'); xlabel('Max displacement (deg)');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iCl=1:2
    subplot(hPlotsEye(1,iCl));
    if iCl==1; ylabel('Eye-position: horizontal (deg)'); end;
    xlim([-0.5 0.75])

    subplot(hPlotsEye(2,iCl));
    if iCl==1; ylabel('Eye-position: vertical (deg)'); end;
    xlim([-0.5 0.75])

    subplot(hPlotsEye(3,iCl));
    if iCl==1; xlabel('Time (s)'); end;
    if iCl==1; ylabel('Microsaccade rate (/s)'); end;
    xlim([-0.5 0.75])
    set(gca,'xtick',[-0.5 0 0.75],'xticklabel',[-0.5 0 0.75]);
end