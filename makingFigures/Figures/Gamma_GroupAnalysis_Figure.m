
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Draw figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figR = figure('numbertitle', 'off','name','Figure 2: TF and topoplots');
figR.PaperType = 'a4';
figR.PaperUnits = 'centimeters';
figR.PaperSize = [18.3 24.7/2]; % Nature specifications
figR.PaperOrientation = 'Portrait';
figR.PaperPosition = [0 0 figR.PaperSize];
figR.Color = [1 1 1]; % White background

[~,hRowsPos] = getPlotHandles_Rows([0.1 0.1 0.8 0.8],[1 2],0.065);
hRow1Plots = getPlotHandles(1,4,hRowsPos{1},0.01,0.01);
axis(hRow1Plots(2),'off');

hPlotsPSD = hRow1Plots(1);
subplot(hPlotsPSD); hold on;
axPos = get(gca,'position');
hPlotsPSDSigBar = axes('position',[axPos(1) axPos(2)-2/10*axPos(4) axPos(3) 1/20*axPos(4)]);
hPlotsTF = hRow1Plots([3 4]);

[hPlots2,hColRowsPos] = getPlotHandles_Columns(hRowsPos{2},[1 3],0.065);
hBar = hPlots2(1);

[~,~,hTopoRowPos] = getPlotHandles(2,1,hColRowsPos{2},0.01,0.01);
hTopo{1} = getPlotHandles(1,3,hTopoRowPos{1},0.01,0.01);
hTopo{2} = getPlotHandles(1,3,hTopoRowPos{2},0.01,0.01);

meanCDRColor = hot(8); meanCDRColor([1:3,end-2:end],:) = [];
rColor = plasma(5); rColor([1 end],:)=[];
g1Color = rColor(2,:); g2Color = rColor(3,:); alphaColor = rColor(1,:);
fontSizeLarge = 10; tickLengthMedium = [0.025 0];

freqAxis = freqVals;
clims = [-1 1.5]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allCDR = cell2mat(gammaPowerAllSubs(:,cdrNum))';
allAge = cell2mat(gammaPowerAllSubs(:,ageCol))';
allSex = cell2mat(gammaPowerAllSubs(:,sexCol))';

if ~NarrowerBandFlag
    allSGPower = cell2mat(gammaPowerAllSubs(:,g1NumAreaWise))';
    allFGPower = cell2mat(gammaPowerAllSubs(:,g2NumAreaWise))';
else
    allSGPower = gammaPowerAllSubsNB(:,1)';
    allFGPower = gammaPowerAllSubsNB(:,2)';
end
allAlphaPower = cell2mat(gammaPowerAllSubs(:,alphaNumAreaWise))';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if subsGroup==1; subsInds = allCDR>0; saveStr = 'Figure2';
elseif subsGroup==2; subsInds = allCDR==0.5; saveStr = 'Figure2_MCI';
elseif subsGroup==3; subsInds = allCDR==1; saveStr = 'Figure2_AD';
end

if ssvepSubsFlag;
    load(fullfile(finalPlotsSaveFolder,'AllAnalysisSSVEP_allEdu.mat'),'ssvepValsAllSubs');
    SSVEPSubs = ssvepValsAllSubs(:,1);
    gammaSubs = gammaPowerAllSubs(:,1);
    controlSubsInds = ismember(gammaSubs,SSVEPSubs)';
    subsInds = subsInds & controlSubsInds; 
    saveStr = [saveStr '_SSVEPSubs'];
else
    controlSubsInds = true(size(allCDR));
end

if consistentMCISubsFlag
    gammaSubs = gammaPowerAllSubs(:,1);
    consistentMCISubs = {'089JL','217SK','224AA'};
    subsInds = subsInds & ~ismember(gammaSubs,consistentMCISubs)'; 
    saveStr = [saveStr '_consistentMCI'];
end
if NarrowerBandFlag; saveStr = [saveStr '_NarrowerBand']; end;

dvSubAges = allAge(subsInds);
dvSubGenders = allSex(subsInds);

if remove92yAD
    dvSubGenders(dvSubAges==92)=[];
    dvSubAges(dvSubAges==92)=[];
end

clear controlSubsAll disSubsAll; controlSubsAll = []; disSubsAll = [];
for iCA = 1:length(dvSubAges)

    disSubs = ismember(allAge,dvSubAges(iCA)) & ismember(allSex,dvSubGenders(iCA)) & subsInds;
    disSubsAll = cat(2,disSubsAll,find(disSubs));

    controlSubs = ismember(allAge,unique([dvSubAges(iCA)-ageLim dvSubAges(iCA) dvSubAges(iCA)+ageLim])) & ismember(allSex,dvSubGenders(iCA)) & allCDR==0 & controlSubsInds;
    controlSubsAll = cat(2,controlSubsAll,find(controlSubs));
    
    controlSubsNum(iCA) = sum(controlSubs); %#ok<SAGROW>
end
disSubsAll = unique(disSubsAll);
controlSubsAll = unique(controlSubsAll);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Gamma_GroupAnalysis_PSDAndTF;
Gamma_GroupAnalysis_bar;
Gamma_GroupAnalysis_topoplots;
