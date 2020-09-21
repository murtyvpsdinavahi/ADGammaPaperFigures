
PvsFGroupAll = []; cdrGroupAll = [];
for iCDR=1:2
    clear cdrCatAllSubs; 
    switch iCDR
        case 1; cdrGroup = controlSubsAll;
        case 2; cdrGroup = disSubsAll;
    end
    
    if isempty(cdrGroup); continue; end;
    clear PvsFGroup tfGroup         
    PvsFGroup = diffPvsFAllSubsAreaWise(cdrGroup,:);
    tfGroup = tfDataAllSubsAreaWise(cdrGroup,:,:);
    numSubsGroup = size(PvsFGroup,1);
    
    % Plot PSDs
    if psdFlag
        subplot(hPlotsPSD); hold on;
        clear bootStat meanPvsF stdPvsF semPvsF    
        bootStat = bootstrp(10000,getLoc,PvsFGroup);
        medianPvsF = getLoc(PvsFGroup); stdPvsF = std(bootStat);
        patch([freqAxis';flipud(freqAxis')],[medianPvsF'-stdPvsF';flipud(medianPvsF'+stdPvsF')],meanCDRColor(iCDR,:),'linestyle','none','FaceAlpha',0.4);
        plot(freqAxis,medianPvsF,'color',meanCDRColor(iCDR,:),'linewidth',1); 
    end

    % Plot TFs        
    if tfFlag        
        clear meanTF
        meanTF = squeeze(median(tfGroup,1));

        if ~saveFlag
            subplot(hPlotsTF(iCDR)); hold on; colormap magma;
            pcolor(timeValsTF,freqValsTF,meanTF'); shading interp;
            caxis(clims); xlim([-0.5 1.2]); ylim([0 100]);
        else
            clear CData spHandle
            CData = squeeze(meanTF');
            spHandle = subplot(hPlotsTF(iCDR));

            clear imData xlims ylims
            [imData,xlims,ylims,clims] = plotPColorAsImage(spHandle,timeValsTF,freqValsTF,CData,[-0.5 1.2],[],clims,colormapName);%,'magma');

            clear timeAxisTF freqAxisTF
            timeAxisTF = timeValsTF((timeValsTF>=xlims(1)) & (timeValsTF<=xlims(2)));
            freqAxisTF = freqValsTF((freqValsTF>=ylims(1)) & (freqValsTF<=ylims(2)));
            imagesc(timeAxisTF,fliplr(freqAxisTF),imData);
            set(spHandle,'ydir','normal');
        end

        set(gca,'box','off');
        set(gca,'fontsize',fontSizeLarge);
        set(gca,'TickDir','out','TickLength',tickLengthMedium);
        xLims = xlim;
        if ~SSVEPFlag
            makeBox(gca,xLims,gamma1CheckRange,'w',1,'-','H');
            makeBox(gca,xLims,gamma2CheckRange,'w',1,'--','H'); 
            makeBox(gca,xLims,alphaCheckRange,'w',1,':','H'); 
        end
        set(gca,'xtick',[0 0.8],'xticklabel',[]);
        set(gca,'ytick',[0 50 100],'yticklabel',[]);
    end
    
    if PSDSigFlag
        clear txtStr
        if iCDR==1; txtStr = ['HV, n=' num2str(numSubsGroup)];
        elseif iCDR==2; txtStr = ['Dis, n=' num2str(numSubsGroup)];
        end
        title(txtStr,'color',meanCDRColor(iCDR,:));

        PvsFGroupAll = cat(2,PvsFGroupAll,PvsFGroup');
        cdrGroupAll = cat(2,cdrGroupAll,repmat(iCDR,1,size(PvsFGroup,1)));
    end
end

if PSDSigFlag
    clear xValsAll yValsAll
    xValsAll = []; yValsAll = [];
    for iFreq=1:length(freqAxis)
        pPvsF2(iFreq) = kruskalwallis(PvsFGroupAll(iFreq,:),cdrGroupAll,'off'); %#ok<SAGROW>

        clear xMidPos xBegPos xEndPos
        xMidPos = freqAxis(iFreq);
        if iFreq==1; xBegPos = xMidPos; else xBegPos = xMidPos-(freqAxis(iFreq)-freqAxis(iFreq-1))/2; end;
        if iFreq==length(freqAxis); xEndPos = xMidPos; else xEndPos = xMidPos+(freqAxis(iFreq+1)-freqAxis(iFreq))/2; end
        clear xVals; xVals = [xBegPos xEndPos xEndPos xBegPos]';
        clear yVals; yVals = [0 0 1 1]';
        xValsAll = cat(2,xValsAll,xVals);
        yValsAll = cat(2,yValsAll,yVals);    

        if squeeze(pPvsF2(iFreq))<0.05 && squeeze(pPvsF2(iFreq))>0.01;      
            subplot(hPlotsPSDSigBar);
            patch(xVals,yVals,'k','linestyle','none');
            axis tight;
        end

        if squeeze(pPvsF2(iFreq))<0.01;      
            subplot(hPlotsPSDSigBar);
            patch(xVals,yVals,'g','linestyle','none');
            axis tight;
        end
    end
    subplot(hPlotsPSDSigBar); xlim([0 100]); axis off;
end

if psdFlag
    subplot(hPlotsPSD);
    xlim([0 100]); ylim([-4 4]);
    if PSDSigFlag; ylim([-1 1.5]); ylabel(gca,'Change in power (dB)'); end
    
    set(gca,'fontsize',fontSizeLarge);
    set(gca,'TickDir','out','TickLength',tickLengthMedium);
    xLims = xlim; yLims = ylim;
    if ~SSVEPFlag
        makeBox(gca,gamma1CheckRange,yLims,g1Color,1,'-','V');
        makeBox(gca,gamma2CheckRange,yLims,g2Color,1,'--','V'); 
        makeBox(gca,alphaCheckRange,yLims,alphaColor,1,':','V'); 
    end
    plot(linspace(xLims(1),xLims(2),100),zeros(1,100),'linewidth',1,'linestyle',':','color',[0 0 0]);
end

if tfFlag
    subplot(hPlotsTF(end,1));
    if PSDSigFlag
        xlabel(gca,'Time (s)');
        ylabel(gca,'Frequency (Hz)');
    end
    set(gca,'xtick',[0 0.8],'xticklabel',[0 0.8]);
    set(gca,'ytick',[0 50 100],'yticklabel',[0 50 100]);

    subplot(hPlotsTF(end,end));
    tmpPos = get(gca,'Position');
    cbPos = [tmpPos(1)+tmpPos(3)+0.005 tmpPos(2) 0.0075 tmpPos(4)];
    if saveFlag
        cbData = imread('colorBarMagma.png');
        hCB = subplot('Position',cbPos);
        cbarAxis = clims(1):0.001:clims(2);
        imagesc([0 1],fliplr(cbarAxis),cbData);
    else
        hCB = colorbar('Position',cbPos);
    end
    set(hCB,'ydir','normal','box','off');
    set(hCB,'xtick',[],'ytick',[clims(1) 0 clims(2)],'yticklabel',[clims(1) 0 clims(2)]);
    set(hCB,'yaxislocation','right');
    ylabel(hCB,'dB');
    set(hCB,'fontsize',fontSizeLarge,'TickDir','out','TickLength',tickLengthMedium);
end
%%%%%%%%%%%%
