
clear controlSubsAll disSubsAll; controlSubsAll = []; disSubsAll = [];

clear iSubX
noDataSubs = find(isnan(allAlphaPower)); % Important only for no MS trials

for iG=1:3
    switch iG
        case 1; allGP = allAlphaPower; ttlStr = 'Alpha';
        case 2; allGP = allSGPower; ttlStr = 'Slow gamma';
        case 3; allGP = allFGPower; ttlStr = 'Fast gamma';
    end

    clear sgDis sgCon
    sgDis = []; sgCon = [];
    for iSubX = 1:length(dvSubAges)
        disSubsAll = subNums(iSubX);
        if ismember(disSubsAll,noDataSubs); continue; end; % Important only for no MS trials
        
        if ~noNegPowFlag
            controlSubs = ismember(allAge,unique([dvSubAges(iSubX)-ageLim dvSubAges(iSubX) dvSubAges(iSubX)+ageLim])) & ismember(allSex,dvSubGenders(iSubX)) & allCDR==0 & controlSubsInds;
        else
            controlSubs = ismember(allAge,unique([dvSubAges(iSubX)-ageLim dvSubAges(iSubX) dvSubAges(iSubX)+ageLim])) & ismember(allSex,dvSubGenders(iSubX)) & allCDR==0 & allSGPower>0 & allFGPower>0 & controlSubsInds;
        end
        controlSubsAll = setdiff(find(controlSubs),noDataSubs);  
        controlSubsNums(iSubX) = sum(controlSubs); %#ok<*SAGROW>
        
        if isempty(controlSubsAll); continue; end;
        
        medGCon = median(allGP(controlSubsAll));
        medGDis = median(allGP(disSubsAll));
        
        iCDR = allCDR(disSubsAll)*2;
        iGen = allSex(disSubsAll);
        
        markerFaceColor = subgroupColor(iCDR,:);
        
        subplot(hPlots(iG)); hold on;
        plot(medGDis,medGCon,'marker',genderMarker{iGen},'color',subgroupColor(iCDR,:),'markersize',4,'markerfacecolor',markerFaceColor);
                
        sgDis(end+1) = medGDis;
        sgCon(end+1) = medGCon;
    end
    
    axis tight; xL=xlim; yL=ylim;
    axis([floor(min([xL yL])*10)/10 ceil(max([xL yL])*10)/10 floor(min([xL yL])*10)/10 ceil(max([xL yL])*10)/10])
    axis square; xL=xlim; yL=ylim;
    plot(linspace(xL(1),xL(2),100),linspace(yL(1),yL(2),100),'--k');
    title(ttlStr);
    set(gca,'fontsize',fontSizeLarge,'TickDir','out','TickLength',tickLengthMedium);
    
    bsSG = bootstrp(10000,@median,(sgDis-sgCon));
    subplot(hPlots(iG)); hold on;
    axPos = get(gca,'position');
    medAx(iG) = axes('position',[axPos(1)+6/10*axPos(3) axPos(2)+2/10*axPos(4) 3/10*axPos(3) 2/10*axPos(4)]);
    subplot(medAx(iG)); hold on;
    errorbar(median(sgDis-sgCon),std(bsSG),'marker','o','color','k');
    xlim([0.98 1.02]); xLim = xlim;
    plot(linspace(xLim(1),xLim(2),100),zeros(1,100),'-r');
    set(gca,'xtick',[]);
    ylim([-0.5 0.5]);

    % signrank test
    [pSR(iG),~,statsSR(iG)] = signrank(sgDis,sgCon,'tail','left','method','approximate');
    disp([ttlStr '; Wilcoxon signed-rank test: Z=' num2str(round(statsSR(iG).zval,2)) ', p=' num2str(pSR(iG))]); 
end

subplot(hPlots(1,1)); hold on;
xlabel('Change in power (dB): Dis');
ylabel('Change in power (dB): HV');