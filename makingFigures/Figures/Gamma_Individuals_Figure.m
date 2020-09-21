

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allCDR = cell2mat(gammaPowerAllSubs(:,cdrNum))';
subsNums = 1:sum(allCDR==clnLbl);

if newDVListFlag
    allCDROrig = allCDR;
    allCDR = consensusLabelAllSubs;
    allCDR(allCDR~=allCDROrig) = NaN;
end
allAge = cell2mat(gammaPowerAllSubs(:,ageCol))';
allSex = cell2mat(gammaPowerAllSubs(:,sexCol))';

allSGPower = cell2mat(gammaPowerAllSubs(:,g1NumAreaWise))';
allFGPower = cell2mat(gammaPowerAllSubs(:,g2NumAreaWise))';

allAlphaPower = cell2mat(gammaPowerAllSubs(:,alphaNumAreaWise))';

allTotalPower = allSGPower+allFGPower;
clims = [-1 1.5]; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goodSubs = ismember(allCDR,clnLbl);
dvSubAges = allAge(goodSubs);
dvSubGenders = allSex(goodSubs);
subNums = find(goodSubs); 

for iSub = 1:length(dvSubAges)
    disSubs = subNums(iSub);
    controlSubs = ismember(allAge,unique([dvSubAges(iSub)-ageLim dvSubAges(iSub) dvSubAges(iSub)+ageLim])) & ismember(allSex,dvSubGenders(iSub)) & allCDR==0;
    allPD(iSub) = median(allTotalPower(controlSubs))-allTotalPower(disSubs); 
end

[~,subjectOrder] = sort(allPD,'descend');
dvSubAges = dvSubAges(subjectOrder);
dvSubGenders = dvSubGenders(subjectOrder);
subNums = subNums(subjectOrder);

if newDVListFlag
    goodSubsOrig = ismember(allCDROrig,clnLbl);
    dvSubAgesOrig = allAge(goodSubsOrig);
    dvSubGendersOrig = allSex(goodSubsOrig);
    subNumsOrig = find(goodSubsOrig);
    
    for iSub = 1:length(dvSubAgesOrig)
        disSubsOrig = subNumsOrig(iSub);
        controlSubsOrig = ismember(allAge,unique([dvSubAgesOrig(iSub)-ageLim dvSubAgesOrig(iSub) dvSubAgesOrig(iSub)+ageLim])) & ismember(allSex,dvSubGendersOrig(iSub)) & allCDROrig==0;
        allPDOrig(iSub) = median(allTotalPower(controlSubsOrig))-allTotalPower(disSubsOrig);
    end
    
    [~,subjectOrderOrig] = sort(allPDOrig,'descend');
    subNumsOrig = subNumsOrig(subjectOrderOrig);
    subsNums = find(ismember(subNumsOrig,subNums));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figR = figure('numbertitle', 'off','name','Supplementary Figure 1: TF and topoplots'); colormap(figR,'magma');
figR.PaperType = 'a4';
figR.PaperUnits = 'centimeters';
figR.PaperSize = [18.3 24.7]; % Nature specifications
figR.PaperOrientation = 'Portrait';
figR.PaperPosition = [0 0 figR.PaperSize];
figR.Color = [1 1 1]; % White background

[~,~,hColsPos] = getPlotHandles(1,2,[0.1 0.1 0.8 0.8],0.25,0.001);
[~,~,hRowsPos] = getPlotHandles(14,1,hColsPos{1},0.001,0.001);
for iSub=1:sum(goodSubs)
   hRowPlots{iSub} = getPlotHandles(1,2,hRowsPos{iSub},0.01,0.01);     %#ok<*SAGROW>
end

[hPlots2,hPlots2Pos] = getPlotHandles_Rows(hColsPos{2},[1 2],0.065);
meanCDRColor = hot(8); meanCDRColor([1:3,end-2:end],:) = [];
rColor = plasma(5); rColor([1 end],:)=[];
g1Color = rColor(2,:); g2Color = rColor(3,:); alphaColor = rColor(1,:);
fontSizeLarge = 10; tickLengthMedium = [0.025 0];

freqAxis = freqVals;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear iSubX

CDRScores = getClinicalNumsFromString(clinicalScoresAllSubs(:,CDR_TotalCol));
HMSEScores = getClinicalNumsFromString(clinicalScoresAllSubs(:,HMSECol));
if clnLbl==0.5, clnStr = 'M'; elseif clnLbl==1, clnStr = 'A'; end;

psdFlag=0; %#ok<*NASGU>
tfFlag=1;
PSDSigFlag = 0; 
for iSubX = 1:length(dvSubAges)    
    hPlotsTF = hRowPlots{iSubX};
    
    disSubsAll = subNums(iSubX);
    controlSubs = ismember(allAge,unique([dvSubAges(iSubX)-ageLim dvSubAges(iSubX) dvSubAges(iSubX)+ageLim])) & ismember(allSex,dvSubGenders(iSubX)) & allCDR==0;    
    controlSubsAll = find(controlSubs);    
    Gamma_GroupAnalysis_PSDAndTF;
    drawnow;
    
    clear genStr; if dvSubGenders(iSubX)==1; genStr = 'M'; elseif dvSubGenders(iSubX)==2; genStr = 'F'; end;
    subplot(hPlotsTF(2)); text(0.1,0.5,[num2str(dvSubAges(iSubX)) '/' genStr],'color','w','unit','normalized','parent',gca);
    subplot(hPlotsTF(1)); text(0.1,0.5,num2str(length(controlSubsAll)),'color','w','unit','normalized','parent',gca);    
    subplot(hPlotsTF(2)); text(0.8,0.5,[clnStr num2str(subsNums(iSubX))],'color','w','unit','normalized','parent',gca);    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

psdFlag=1;
tfFlag=0;
PSDSigFlag = 1; 
hPlotsPSD = hPlots2(1); hBar = hPlots2(2);
subplot(hPlotsPSD); hold on;
axPos = get(gca,'position');
hPlotsPSDSigBar = axes('position',[axPos(1) axPos(2)-2/10*axPos(4) axPos(3) 1/20*axPos(4)]);

subsInds = allCDR==clnLbl;
controlSubsInds = true(size(allCDR));

clear controlSubsAll disSubsAll; controlSubsAll = []; disSubsAll = [];
for iCA = 1:length(dvSubAges)
    disSubs = ismember(allAge,dvSubAges(iCA)) & ismember(allSex,dvSubGenders(iCA)) & subsInds;
    disSubsAll = cat(2,disSubsAll,find(disSubs));

    controlSubs = ismember(allAge,unique([dvSubAges(iCA)-ageLim dvSubAges(iCA) dvSubAges(iCA)+ageLim])) & ismember(allSex,dvSubGenders(iCA)) & allCDR==0 & controlSubsInds;
    controlSubsAll = cat(2,controlSubsAll,find(controlSubs));
    
    controlSubsNum(iCA) = sum(controlSubs);
end
disSubsAll = unique(disSubsAll);
controlSubsAll = unique(controlSubsAll);

Gamma_GroupAnalysis_PSDAndTF;
Gamma_GroupAnalysis_bar;
ylim(hBar,[-0.8 1.2]);




