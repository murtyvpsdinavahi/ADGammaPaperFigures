

for iG=1:3
    switch iG
        case 1; allGP = allAlphaPower; gStr = 'Alpha';
        case 2; allGP = allSGPower; gStr = 'Slow gamma';
        case 3; allGP = allFGPower; gStr = 'Fast gamma';
    end

    gpGroupAll = []; cdrGroupAll = [];
    for iCDR=1:2
        switch iCDR
            case 1; subNums = controlSubsAll; shFac = -0.2;
            case 2; subNums = disSubsAll; shFac = 0.2;
        end

        medG = median(allGP(subNums));
        bsG = std(bootstrp(10000,@median,allGP(subNums)));

        subplot(hBar); hold on;
        errorbar(iG+shFac,medG,bsG,'linestyle','none','marker','none','color',meanCDRColor(iCDR,:)); hold on;
        bar(iG+shFac,medG,0.4,'facecolor',meanCDRColor(iCDR,:),'facealpha',0.85);
        
        % Statistics
        gpGroupAll = cat(2,gpGroupAll,allGP(subNums));
        cdrGroupAll = cat(2,cdrGroupAll,repmat(iCDR,size(subNums)));
    end
    [pGP(iG),tblGP{iG}] = kruskalwallis(gpGroupAll,cdrGroupAll,'off'); %#ok<SAGROW>
    disp([gStr '; KW test: X2(' num2str(tblGP{iG}{4,3}) ')=' num2str(round(tblGP{iG}{2,5},2)) ', p=' num2str(tblGP{iG}{2,6})]); 
end

subplot(hBar); hold on;
axis([0 4 -0.75 1]);% axis square
ylabel('Change in power (dB)');
set(gca,'xtick',1:3,'xticklabel',{'Alpha' 'SG' 'FG'});
set(gca,'fontsize',fontSizeLarge,'TickDir','out','TickLength',tickLengthMedium);
