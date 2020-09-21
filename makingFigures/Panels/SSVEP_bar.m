
gpGroupAll = []; cdrGroupAll = [];
for iCDR=1:2
    switch iCDR
        case 1; subNums = controlSubsAll; shFac = -0.2;
        case 2; subNums = disSubsAll; shFac = 0.2;
    end

    medG = median(allGPower(subNums));
    bsG = std(bootstrp(10000,@median,allGPower(subNums)));

    subplot(hBar); hold on;
    errorbar(1+shFac,medG,bsG,'linestyle','none','marker','none','color',meanCDRColor(iCDR,:)); hold on;
    bar(1+shFac,medG,0.4,'facecolor',meanCDRColor(iCDR,:),'facealpha',0.85);
    
    % Statistics
    gpGroupAll = cat(2,gpGroupAll,allGPower(subNums));
    cdrGroupAll = cat(2,cdrGroupAll,repmat(iCDR,size(subNums)));
end
[pGP,tblGP] = kruskalwallis(gpGroupAll,cdrGroupAll,'off');
disp(['KW test: X2(' num2str(tblGP{4,3}) ')=' num2str(round(tblGP{2,5},2)) ', p=' num2str(tblGP{2,6})]); 

subplot(hBar); hold on;
axis([0 2 3 7]);% axis square
ylabel('Change in power (dB)');
set(gca,'xtick',1,'xticklabel',{'SSVEP'});
set(gca,'fontsize',fontSizeLarge,'TickDir','out','TickLength',tickLengthMedium);
