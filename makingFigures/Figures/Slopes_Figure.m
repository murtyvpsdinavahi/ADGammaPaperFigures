

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figR = figure('numbertitle', 'off','name','Figure 1: TF and topoplots');
figR.PaperType = 'a4';
figR.PaperUnits = 'centimeters';
figR.PaperSize = [18.3 24.7/2]; % Nature specifications
figR.PaperOrientation = 'Portrait';
figR.PaperPosition = [0 0 figR.PaperSize];
figR.Color = [1 1 1]; % White background

[hP1,~,hPlotsPos] = getPlotHandles(2,2,[0.1 0.1 0.8 0.8],0.1,0.15,0); axis(hP1(2,1),'off');

[~,~,hPlotsPSDPos] = getPlotHandles(30,3,hPlotsPos{1,1},0.001,0.001,1);
hPowers = getPlotHandles(1,3,hPlotsPos{1,2},0.02,0.02,0);
hSlopes = getPlotHandles(1,3,hPlotsPos{2,2},0.02,0.02,0);

meanCDRColor = hot(8); meanCDRColor([1:3,end-2:end],:) = [];
rColor = plasma(5); rColor([1 end],:)=[];
g1Color = rColor(2,:); g2Color = rColor(3,:); alphaColor = rColor(1,:);
fontSizeLarge = 10; tickLengthMedium = [0.025 0];
subgroupColor = [0 0 0; 0.4 0.4 0.4];
genderMarker = {'^' 'v'};

freqPoints = 1:find(freqVals==100);
freqAxis = freqVals(freqPoints);
clims = [-1 1.5]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allCDR = cell2mat(gammaPowerAllSubs(:,cdrNum))';
allAge = cell2mat(gammaPowerAllSubs(:,ageCol))';
allSex = cell2mat(gammaPowerAllSubs(:,sexCol))';

p1=3; p2=1; p3=2;

for iC=1:3
    switch iC
        case 1; clnLbl = [0.5 1];
        case 2; clnLbl = 0.5;
        case 3; clnLbl = 1;
    end
    goodSubs = ismember(allCDR,clnLbl);
    dvSubAges = allAge(goodSubs);
    dvSubGenders = allSex(goodSubs);
    subNums = find(goodSubs);

    clear controlSubsAll disSubsAll; controlSubsAll = []; disSubsAll = [];
    for iCA = 1:length(dvSubAges)
        disSubs = ismember(allAge,dvSubAges(iCA)) & ismember(allSex,dvSubGenders(iCA)) & goodSubs;
        disSubsAll = cat(2,disSubsAll,find(disSubs));

        controlSubs = ismember(allAge,unique([dvSubAges(iCA)-ageLim dvSubAges(iCA) dvSubAges(iCA)+ageLim])) & ismember(allSex,dvSubGenders(iCA)) & allCDR==0;
        controlSubsAll = cat(2,controlSubsAll,find(controlSubs));
    end
    disSubsAll = unique(disSubsAll);
    controlSubsAll = unique(controlSubsAll);

    hPlotsPSDAgePos = hPlotsPSDPos(:,iC); 
    Slopes_PSDvsAge;
    drawnow;
end

dvSubAges = allAge(allCDR>0);
dvSubGenders = allSex(allCDR>0);
subNums = find(allCDR>0);
if remove92yAD
    dvSubGenders(dvSubAges==92)=[];
    dvSubAges(dvSubAges==92)=[];
end

clear hPlots;
hPlots = hPowers;
allSGPower = squeeze(bandPowerAllElecs(iRef,:,2)); %#ok<*NASGU>
allFGPower = squeeze(bandPowerAllElecs(iRef,:,3));
allAlphaPower = squeeze(bandPowerAllElecs(iRef,:,1));
controlSubsInds = true(size(allCDR));

Gamma_IndividualAnalysis_scatter;
subplot(hPlots(1)); hold on;
xlabel('Raw power: Dis');
ylabel('Raw power: HV');
drawnow;

clear hPlots;
hPlots = hSlopes;
allAlphaPower = cell2mat(squeeze(slopeAllSubsAllElecs(iRef,:,p1)));
allSGPower = cell2mat(squeeze(slopeAllSubsAllElecs(iRef,:,p2)));
allFGPower = cell2mat(squeeze(slopeAllSubsAllElecs(iRef,:,p3)));

Gamma_IndividualAnalysis_scatter;
subplot(hPlots(1)); hold on;
xlabel('Slopes: Dis');
ylabel('Slopes: HV');

iP=p1; title(hPlots(1),[num2str(computeSlopesAtFreqs{iP}(1)) '-' num2str(computeSlopesAtFreqs{iP}(2)) ' Hz'])
iP=p2; title(hPlots(2),[num2str(computeSlopesAtFreqs{iP}(1)) '-' num2str(computeSlopesAtFreqs{iP}(2)) ' Hz'])
iP=p3; title(hPlots(3),[num2str(computeSlopesAtFreqs{iP}(1)) '-' num2str(computeSlopesAtFreqs{iP}(2)) ' Hz'])
drawnow;
