
cLims = [-1 1.5];
refType = 'bipolar'; capLayout = {'actiCap64'};
clear cL bL chanlocs iElec electrodeList noseDir
switch refType
    case 'unipolar'
        cL = load(fullfile(pwd,'Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
        chanlocs = cL.chanlocs;
        for iElec = 1:length(chanlocs)
            electrodeList{1}{iElec} = iElec;
        end
        noseDir = '+X';
    case 'bipolar'
        cL = load(fullfile(pwd,'Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
        bL = load(fullfile(pwd,'Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat']));
        chanlocs = cL.eloc;
        for iElec = 1:length(chanlocs)
            electrodeList{1}{iElec} = bL.bipolarLocs(iElec,:);
        end
        noseDir = '+X';
end

for iCDR=1:2
    switch iCDR
        case 1; cdrGroup = controlSubsAll;
        case 2; cdrGroup = disSubsAll;
    end
    clear goodSubsSGTopo; goodSubsSGTopo = SF_TopoDataAllSubs(cdrGroup,:,1);
    clear goodSubsFGTopo; goodSubsFGTopo = SF_TopoDataAllSubs(cdrGroup,:,2);
    clear goodSubsAlphaTopo; goodSubsAlphaTopo = SF_TopoDataAllSubs(cdrGroup,:,3);

    for iG=1:3
        clear diffPower
        switch iG
            case 1; diffPower = squeeze(nanmedian(goodSubsAlphaTopo,1));
            case 2; diffPower = squeeze(nanmedian(goodSubsSGTopo,1));
            case 3; diffPower = squeeze(nanmedian(goodSubsFGTopo,1));            
        end
        subplot(hTopo{iCDR}(iG)); cla; hold on;    
        diffPower(isnan(diffPower)) = 999;
        topoplot(diffPower,chanlocs,'electrodes','off','style','blank','drawaxis','off','nosedir',noseDir,'emarkercolors',diffPower); caxis(cLims);
        if saveFlag; pasteAsImage(gca,[],[],[],colormapName); axis(gca,'off'); end;
    end    
    
    if iCDR==2
        subplot(hTopo{end}(end));
        clear cbData tmpPos hCB cbarAxis
        cbData = imread('colorbarMagma.png');
        tmpPos = get(gca,'Position');
        if ~saveFlag 
            hCB = colorbar('position',[tmpPos(1)+tmpPos(3)+0.005 tmpPos(2) 0.005 tmpPos(4)]);
        else
            hCB = subplot('Position',[tmpPos(1)+tmpPos(3)+0.005 tmpPos(2) 0.005 tmpPos(4)]);
            cbarAxis = cLims(1):0.001:cLims(2);
            imagesc([0 1],fliplr(cbarAxis),cbData);
        end
        set(hCB,'ydir','normal','box','off');
        set(hCB,'xtick',[],'ytick',[cLims(1) 0 cLims(2)],'yticklabel',[cLims(1) 0 cLims(2)]);
        set(hCB,'yaxislocation','right');
        ylabel(hCB,'dB');
        set(hCB,'fontsize',fontSizeLarge,'TickDir','out','TickLength',tickLengthMedium);
    end
end
