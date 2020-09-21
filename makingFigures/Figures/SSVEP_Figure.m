

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figR = figure('numbertitle', 'off','name','Figure 4: SSVEP');
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

[hPlots2,hColRowsPos] = getPlotHandles_Columns(hRowsPos{2},[1 1 1],0.065);
hBar = hPlots2(1);

hTopoPlots = getPlotHandles(2,1,hColRowsPos{2},0.01,0.01);
hTopo{1} = hTopoPlots(1);
hTopo{2} = hTopoPlots(2);

hScatter = hPlots2(3);

meanCDRColor = hot(8); meanCDRColor([1:3,end-2:end],:) = [];
rColor = plasma(5); rColor([1 end],:)=[];
g1Color = rColor(2,:); g2Color = rColor(3,:); alphaColor = rColor(1,:);
fontSizeLarge = 10; tickLengthMedium = [0.025 0];

subgroupColor = [0 0 0; 0.4 0.4 0.4];
genderMarker = {'^' 'v'};

freqAxis = freqVals;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allCDR = cell2mat(ssvepValsAllSubs(:,cdrNum))';
allAge = cell2mat(ssvepValsAllSubs(:,ageNum))';
allSex = cell2mat(ssvepValsAllSubs(:,sexNum))';

allGPower = cell2mat(ssvepValsAllSubs(:,ssvepValsNum))';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dvSubAges = allAge(allCDR>0);
dvSubGenders = allSex(allCDR>0);

if remove92yAD
    dvSubGenders(dvSubAges==92)=[];
    dvSubAges(dvSubAges==92)=[];
end

clear controlSubsAll disSubsAll; controlSubsAll = []; disSubsAll = [];
for iCA = 1:length(dvSubAges)
    disSubs = ismember(allAge,dvSubAges(iCA)) & ismember(allSex,dvSubGenders(iCA)) & allCDR>0;
    disSubsAll = cat(2,disSubsAll,find(disSubs));

    controlSubs = ismember(allAge,unique([dvSubAges(iCA)-ageLim dvSubAges(iCA) dvSubAges(iCA)+ageLim])) & ismember(allSex,dvSubGenders(iCA)) & allCDR==0;
    controlSubsAll = cat(2,controlSubsAll,find(controlSubs));
end
disSubsAll = unique(disSubsAll);
controlSubsAll = unique(controlSubsAll);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SSVEP_PSDAndTF;
SSVEP_bar;
SSVEP_topoplots;
SSVEP_scatter;
