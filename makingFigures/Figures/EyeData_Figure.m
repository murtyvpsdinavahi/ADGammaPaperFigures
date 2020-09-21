
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figR = figure('numbertitle', 'off','name','Eye data'); colormap(figR,'jet');
figR.PaperType = 'a4';
figR.PaperUnits = 'centimeters';
figR.PaperSize = [18.3 24.7/2];
figR.PaperOrientation = 'Portrait';
figR.PaperPosition = [0 0 figR.PaperSize];
figR.Color = [1 1 1]; % White background
[~,~,hPlotsPos] = getPlotHandles(1,3,[0.1 0.1 0.8 0.8],0.1,0.15,0);
hPlotsEye = getPlotHandles(3,2,hPlotsPos{1},0.001,0.001,0);
[hPlotsMS,~,hPlotsMSPos] = getPlotHandles(3,1,hPlotsPos{2},0.001,0.075,0);
hPlotsPupil = getPlotHandles(1,2,hPlotsMSPos{3},0.001,0.075,0);
hPlots = getPlotHandles(3,1,hPlotsPos{3},0.001,0.01,0);

meanCDRColor = hot(8); meanCDRColor([1:3,end-2:end],:) = [];

g1Color = 'c'; g2Color = 'm';         
subgroupColor = [0 0 0; 0.4 0.4 0.4];
genderMarker = {'^' 'v'};
fontSizeLarge = 10; tickLengthMedium = [0.025 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allCDR = cell2mat(gammaPowerAllSubs(:,cdrNum))';
allAge = cell2mat(gammaPowerAllSubs(:,ageCol))';
allSex = cell2mat(gammaPowerAllSubs(:,sexCol))';

allSGPower = SGammaNoMS;
allFGPower = FGammaNoMS;
allAlphaPower = alphaNoMS;

goodSubs = allCDR==0;
numGoodSubs = sum(goodSubs);

clear allPower; allPower = cell2mat(gammaPowerAllSubs(:,g1NumAreaWise))';    
clear goodSubsGamma; goodSubsGamma = ~isnan(allPower) & goodSubs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% timeVals
timeValsEyePos = timeValsEyeDataSubject;
timeValsEyePos = timeValsEyePos(timeValsEyePos>=-0.5 & timeValsEyePos<=0.75);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EyeData_EyeMovements;
EyeData_Pupil;
