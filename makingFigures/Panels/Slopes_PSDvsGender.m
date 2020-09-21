
yLimsPSD = [];
yLimsSlopes = [];
gNum = 1;    
        
clear numSubsGroup
for iRef = 1:2
    clear plotPosPSD; plotPosPSD = hPlotsPSDGenderPos{30,iRef};
    hPlotsPSDGender(iRef) = subplot('position',[plotPosPSD(1) plotPosPSD(2) plotPosPSD(3) plotPosPSD(4)*30]);
    clear PvsFAll blSlopsAll iAgeAll
    PvsFAll = []; blSlopsAll = []; iGenderAll = [];
    for iGender = 1:2

        clear genCatAllSubs; genCatAllSubs = allSex==iGender;
        clear genGroup; genGroup = goodSubsGamma & genCatAllSubs;

        subplot(hPlotsPSDGender(iRef)); hold on;
        clear PvsFGroup meanPvsF stdPvsF semPvsF txtStr
%         PvsFGroup = squeeze(blPvsFSubAllSubs(genGroup,iRef,gNum,2:end));
        PvsFGroup = squeeze(blPvsFSubAllElecs(iRef,genGroup,2:end)); PvsFGroup = log10(PvsFGroup);
        numSubsGroup(iRef,iGender) = size(PvsFGroup,1);

        clear meanPvsF stdPvsF semPvsF
        meanPvsF = mean(PvsFGroup); stdPvsF = std(PvsFGroup); semPvsF = stdPvsF./sqrt(numSubsGroup(iRef,iGender));         
        patch([freqAxis';flipud(freqAxis')],[meanPvsF'-semPvsF';flipud(meanPvsF'+semPvsF')],meanGenderColor(iGender,:),'linestyle','none');

        if iRef==1
            clear txtStr
            if iGender==1; txtStr = ['Male: ' num2str(numSubsGroup(iRef,iGender))];
            elseif iGender==2; txtStr = ['Female: ' num2str(numSubsGroup(iRef,iGender))];
            end                
            text(0.05,0.5-0.05*iGender,txtStr,'unit','normalized','color',meanGenderColor(iGender,:));
        end        

%         clear goodSubsAge; goodSubsAge = allAge(genGroup);    
%         for iAge = 1:length(ageGroups)
%             ageCatSubs(iAge,iGender) = sum(goodSubsAge>=ageGroups{iAge}(1) & goodSubsAge<=ageGroups{iAge}(2));
%         end
    
        PvsFAll = cat(2,PvsFAll,PvsFGroup');        
        iGenderAll = cat(2,iGenderAll,repmat(iGender,1,size(PvsFGroup,1)));                

    end

    clear xValsAll yValsAll
    xValsAll = []; yValsAll = [];
    for iFreq = 1:length(freqAxis)
        [pPvsF(iRef,iFreq),tblPvsF{iRef,iFreq},statsPvsF{iRef,iFreq}] = anova1(PvsFAll(iFreq,:),iGenderAll,'off');

        clear xMidPos xBegPos xEndPos
        xMidPos = freqAxis(iFreq); 
        if iFreq==1; xBegPos = xMidPos; else xBegPos = xMidPos-(freqAxis(iFreq)-freqAxis(iFreq-1))/2; end;
        if iFreq==length(freqAxis); xEndPos = xMidPos; else xEndPos = xMidPos+(freqAxis(iFreq+1)-freqAxis(iFreq))/2; end
        clear xVals; xVals = [xBegPos xEndPos xEndPos xBegPos]';
        clear yVals; yVals = [0 0 1 1]'; 
        xValsAll = cat(2,xValsAll,xVals);
        yValsAll = cat(2,yValsAll,yVals);

        subplot('position',hPlotsPSDGenderPos{1,iRef});
        patch(xVals,yVals,squeeze(pPvsF(iRef,iFreq)),'linestyle','none'); caxis([0 0.05]);
        axis tight;

        subplot('position',hPlotsPSDGenderPos{2,iRef});
        patch(xVals,yVals,squeeze(pPvsF(iRef,iFreq)),'linestyle','none'); caxis([0 0.05/length(freqAxis)]);
        axis tight;
    end     

    subplot(hPlotsPSDGender(iRef)); hold on;
    axis(hPlotsPSDGender(iRef),'tight');
    yLimsPSD = cat(2,yLimsPSD,ylim(hPlotsPSDGender(iRef)));
    drawnow;
end

% subplot(hPlotsPSDGender(2));
% tmpPos = get(gca,'position');
% genHist = axes('position',[tmpPos(1)+tmpPos(3)/2.5 tmpPos(2)+tmpPos(4)/1.5 tmpPos(3)/2 tmpPos(4)/4]);
% hBar = bar(ageCatSubs');
% for iAge = 1:length(ageGroups)
%     hBar(iAge).FaceColor = meanAgeColor(iAge,:);
% end
% xlim([0 3]); ylim([0 max(ageCatSubs(:))+2]);
% ylabel(gca,'n');
% set(gca,'fontsize',fontSizeLarge);
% set(gca,'TickDir','out','TickLength',tickLengthMedium);
% set(gca,'xtick',1:2,'xticklabel',{'M' 'F'});


% yLimsPSDPlot = [min(yLimsPSD) max(yLimsPSD)];
yLimsPSDPlot = [-2.4 2.4]; % TODO  
for iRef=1:2    
    subplot(hPlotsPSDGender(iRef)); hold on;        
    ylim(yLimsPSDPlot); xlim([freqAxis(1) freqAxis(end)]);        
end


for iRef = 1:2
    subplot(hPlotsPSDGender(iRef)); hold on;

    set(gca,'xtick',log10([2 10 50 100 200]),'xticklabel',[2 10 50 100 200]);
    set(gca,'TickDir','out');
    if iRef==1            
        xlabel('Frequency (Hz)'); ylabel('Power (log10(uV2))');
        subplot('position',hPlotsPSDGenderPos{1,iRef}); title('Unipolar');
    else           
        set(gca,'xticklabel',[],'yticklabel',[]);
        subplot('position',hPlotsPSDGenderPos{1,iRef}); title('Bipolar');
    end
        
end

%%%%% Prepare for saving as SVG %%%%%
if saveFlag   
    for iRef=1:2
        pasteAsImage(subplot('position',hPlotsPSDGenderPos{1,iRef})); set(gca,'ytick',[],'xtick',[],'box','off')
        pasteAsImage(subplot('position',hPlotsPSDGenderPos{2,iRef})); set(gca,'ytick',[],'xtick',[],'box','off')
    end
end

