

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figR = figure('numbertitle', 'off','name','Figure 3: HV vs MCI/AD: Scatter');
figR.PaperType = 'a4';
figR.PaperUnits = 'centimeters';
figR.PaperSize = [18.3 24.7/4*3]; % Nature specifications
figR.PaperOrientation = 'Portrait';
figR.PaperPosition = [0 0 figR.PaperSize];
figR.Color = [1 1 1]; % White background
[hPlots,~,hPlotsPos] = getPlotHandles(1,3,[0.1 0.1 0.8 0.8],0.1,0.15,0);

subgroupColor = [0 0 0; 0.4 0.4 0.4];
genderMarker = {'^' 'v'};
fontSizeLarge = 10; tickLengthMedium = [0.025 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allCDR = cell2mat(gammaPowerAllSubs(:,cdrNum))';
if newDVListFlag
    allCDR_ConsensusList = consensusLabelAllSubs;
    allCDR(allCDR~=allCDR_ConsensusList) = NaN;
end

allAge = cell2mat(gammaPowerAllSubs(:,ageCol))';
allSex = cell2mat(gammaPowerAllSubs(:,sexCol))';

allSGPower = cell2mat(gammaPowerAllSubs(:,g1NumAreaWise))';
allFGPower = cell2mat(gammaPowerAllSubs(:,g2NumAreaWise))';
allAlphaPower = cell2mat(gammaPowerAllSubs(:,alphaNumAreaWise))';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~noNegPowFlag
    subsInds = allCDR>0; saveStr = 'Figure3';
else
    subsInds = allCDR>0 & allSGPower>0 & allFGPower>0; saveStr = 'Figure3_NoNegGamma';
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

if newDVListFlag; saveStr = [saveStr '_ConsensusDiagnosis']; end;

dvSubAges = allAge(subsInds);
dvSubGenders = allSex(subsInds);
subNums = find(subsInds);

if remove92yAD
    dvSubGenders(dvSubAges==92)=[];
    dvSubAges(dvSubAges==92)=[];
end
