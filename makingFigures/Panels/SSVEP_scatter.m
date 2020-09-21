
subNums = find(allCDR>0);

clear controlSubsAll disSubsAll; controlSubsAll = []; disSubsAll = [];

allGP = allGPower; ttlStr = 'SSVEP';
clear sgDis sgCon iSubX iSubY
iSubY=1;
for iSubX = 1:length(dvSubAges)
    disSubsAll = subNums(iSubX);
    controlSubs = ismember(allAge,unique([dvSubAges(iSubX)-ageLim dvSubAges(iSubX) dvSubAges(iSubX)+ageLim])) & ismember(allSex,dvSubGenders(iSubX)) & allCDR==0;
    controlSubsAll = find(controlSubs);        

    if isempty(controlSubsAll); continue; end;

    medGCon = median(allGP(controlSubsAll));
%         sdGCon = std(bootstrp(10000,@median,allGP(controlSubsAll)));
    medGDis = median(allGP(disSubsAll));

    iCDR = allCDR(disSubsAll)*2;
    iGen = allSex(disSubsAll);

    subplot(hScatter); hold on;
    plot(medGDis,medGCon,'marker',genderMarker{iGen},'color',subgroupColor(iCDR,:),'markersize',4,'markerfacecolor',subgroupColor(iCDR,:));
%         errorbar(medGDis,medGCon,sdGCon,'marker',genderMarker{iGen},'color',subgroupColor(iCDR,:),'markersize',4,'markerfacecolor',subgroupColor(iCDR,:));

    sgDis(iSubY) = medGDis;
    sgCon(iSubY) = medGCon;
    iSubY = iSubY+1;
end

axis tight; xL=xlim; yL=ylim;
axis([floor(min([xL yL])*10)/10 ceil(max([xL yL])*10)/10 floor(min([xL yL])*10)/10 ceil(max([xL yL])*10)/10])
axis square; xL=xlim; yL=ylim;
plot(linspace(xL(1),xL(2),100),linspace(yL(1),yL(2),100),'--k');
title(ttlStr);
set(gca,'fontsize',fontSizeLarge,'TickDir','out','TickLength',tickLengthMedium);
xlabel('Change in power (dB): Dis');
ylabel('Change in power (dB): HV');

bsSG = bootstrp(10000,@median,(sgDis-sgCon));
subplot(hScatter); hold on;
axPos = get(gca,'position');
axes('position',[axPos(1)+6/10*axPos(3) axPos(2)+2/10*axPos(4) 3/10*axPos(3) 2/10*axPos(4)]);
subplot(gca); hold on;
errorbar(median(sgDis-sgCon),std(bsSG),'marker','o','color','k');
xlim([0.98 1.02]); xLim = xlim;
plot(linspace(xLim(1),xLim(2),100),zeros(1,100),'-r');
set(gca,'xtick',[]);
ylim([-3 1]);

% signrank test
[pSR,~,statsSR] = signrank(sgDis,sgCon,'tail','left','method','approximate');
disp(['Wilcoxon signed-rank test: Z=' num2str(round(statsSR.zval,2)) ', p=' num2str(pSR)]); 
