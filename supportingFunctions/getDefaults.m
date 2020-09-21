
projectNames = {'ADGammaProject'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g1NumAreaWise = 4; g2NumAreaWise = 5;
alphaNumAreaWise = 6;
cdrNum = 7; 

gamma1CheckRange = [20 34]; gamma2CheckRange = [36 66]; alphaCheckRange = [8 12];
blRange = [-0.5 0];
blRangeTF = [-0.5 0]; stRangeTF = [0.25 0.75];
timeRangeEye = [-0.5 0.75];

freqsToAvoid = {[0 0] [8 12] [46 54] [96 104] [146 154] [196 204]};
computeSlopesAtFreqs = {[15 45] [55 85] [4 45] [30 80]};

% Specify folders
folderSourceString = 'H:'; allExtractedDataFolder = fullfile(folderSourceString,'Extracted_Data');
finalPlotsSaveFolder = fullfile(folderSourceString,'Plots','ADPaper','Analysis','Latest');
makeDirectory(finalPlotsSaveFolder);
[~,~,~,~,~,~,~,workbookFolder] = loadProjectDetails('ADGammaProject');

allRawAnalysisFolder = fullfile(folderSourceString,'rawAnalysis_ADProject');
giveRawAnalysisSaveString = 'fullfile(allRawAnalysisFolder,gridType,projectName,protType,subNames{1});';

% Electrode details
[elecNames,elecTags,elecNumsAll] = getElectrodeList('actiCap64','bipolar');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define functions for stats
clear getMedian getMean getSTD
getLoc = @(g)(squeeze(median(g,1)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
capLayouts = {'actiCap64' 'actiCap31Posterior'};

for iCap = 1:length(capLayouts)
    capLayout_1 = capLayouts{iCap};
    montageLabelsMat = load(fullfile(pwd,'Montages','Layouts',capLayout_1,[capLayout_1 'Labels.mat']),'montageLabels');
    montageLabels.(capLayout_1) = montageLabelsMat.montageLabels;

    bipolarLocsMat = load(fullfile(pwd,'Montages','Layouts',capLayout_1,['bipChInfo' upper(capLayout_1(1)) capLayout_1(2:end) '.mat']),'bipolarLocs');
    bipolarLocs.(capLayout_1) = bipolarLocsMat.bipolarLocs;
end

bipInds31To64 = load(fullfile(pwd,'Montages','Layouts','actiCap31Posterior','bipInds31To64.mat'));
bipInds31To64 = bipInds31To64.bipInds31To64;

unipInds31To64 = load(fullfile(pwd,'Montages','Layouts','actiCap31Posterior','unipInds31To64.mat'));
unipInds31To64 = unipInds31To64.unipInds31To64;

electrodeListUnipolar = getElectrodeList('actiCap64','unipolar');
electrodeListUnipolar = cell2mat(electrodeListUnipolar{1});

