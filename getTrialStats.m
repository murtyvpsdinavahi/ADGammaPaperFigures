
% Inputs: 
% experimentName: 'Gamma'/'SSVEP'
% finalPlotsSaveFolder: folder where the
% gammaAnalysis/ssvepAnalysis_GoodSubs files are located.
% 
% Outputs:
% Table_AnalysedSubjects:   stats for subjects finally analysed.
% Table_AllSubjects:        stats for analysed subjects as well as noisy subjects
%
% Murty V P S Dinavahi: 21-07-2020
%
function [Table_AnalysedSubjects,Table_AllSubjects] = getTrialStats(experimentName,finalPlotsSaveFolder)

if ~exist('finalPlotsSaveFolder','var') || isempty(finalPlotsSaveFolder)
    finalPlotsSaveFolder = fullfile(folderSourceString,'Plots','ADPaper','Analysis','Latest');
end

if strcmpi(experimentName,'Gamma')
    load(fullfile(finalPlotsSaveFolder,'gammaAnalysis_GoodSubs.mat'));
    allAgeAndGenderMatrix = [cell2mat(gammaPowerAllSubs(:,ageCol)) NaN(size(gammaPowerAllSubs,1),1) cell2mat(gammaPowerAllSubs(:,sexCol)) cell2mat(gammaPowerAllSubs(:,cdrNum))]; %#ok<*NODEF>
elseif strcmpi(experimentName,'SSVEP')
    load(fullfile(finalPlotsSaveFolder,'ssvepAnalysis_GoodSubs.mat'));
    allAgeAndGenderMatrix = [cell2mat(ssvepValsAllSubs(:,ageNum)) NaN(size(ssvepValsAllSubs,1),1) cell2mat(ssvepValsAllSubs(:,sexNum)) cell2mat(ssvepValsAllSubs(:,cdrNum))];
    numTrialsAllSubs = numTrialsAllSubsSSVEP;
    clinicalScoresAllSubs = clinicalScoresSSVEP;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


percBadEyeTrials = (badEyeTrials./totalTrials)*100;

% Calculate stats
for iGroup = 1:4
    
    switch iGroup
        case 1; iCL = 0; groupIndex = allAgeAndGenderMatrix(:,4)==0; grpName = 'Healthy';
        case 2; iCL = 0.5; groupIndex = allAgeAndGenderMatrix(:,4)==0.5; grpName = 'MCI';
        case 3; iCL = 1:3; groupIndex = allAgeAndGenderMatrix(:,4)>0.5; grpName = 'AD';
        case 4; iCL = [0.5 1:3]; groupIndex = allAgeAndGenderMatrix(:,4)>0; grpName = 'MCI+AD';
    end
    Table_AnalysedSubjects(iGroup).Group = grpName; %#ok<*AGROW>
    Table_AllSubjects(iGroup).Group = grpName;
    
    % For all available subjects, including those noisy with noisy data
    numSubsAll = sum(ismember(labelNumAllCDR,iCL));
    numFemalesAll = sum(sexAllCDR(ismember(labelNumAllCDR,iCL)) == 2);
    Table_AllSubjects(iGroup).numSubjects = num2str(numSubsAll);
    Table_AllSubjects(iGroup).numFemales = num2str(numFemalesAll);
    
    numGoodBlocks = sum(ismember(goodProtDem(:,3),iCL));
    numBadBlocks = sum(ismember(badProtDem(:,3),iCL));
    Table_AllSubjects(iGroup).numGoodBlocks = num2str(numGoodBlocks);
    Table_AllSubjects(iGroup).numBadBlocks = num2str(numBadBlocks);
    Table_AllSubjects(iGroup).numTotalBlocks = num2str(numGoodBlocks+numBadBlocks);
    
    % Only for subjects with analysable data
    numSubs = sum(groupIndex);
    numFemales = sum(allAgeAndGenderMatrix(groupIndex,3) == 2);    
    Table_AnalysedSubjects(iGroup).Numbers = [num2str(numSubs) ' (F=' num2str(numFemales) ')'];
    
    minAge = min(allAgeAndGenderMatrix(groupIndex,1));
    maxAge = max(allAgeAndGenderMatrix(groupIndex,1));
    meanAge = mean(allAgeAndGenderMatrix(groupIndex,1));
    stdAge = std(allAgeAndGenderMatrix(groupIndex,1));
        
    Table_AnalysedSubjects(iGroup).AgeRange = getRangeString(minAge,maxAge);
    Table_AnalysedSubjects(iGroup).Age = getMeanString(meanAge,stdAge);
    
    allAgeAndGenderMatrix(groupIndex,2) = iGroup;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Impedances
    if strcmpi(experimentName,'Gamma')
        impdAllElecsGroup = elecImpedances(groupIndex,:);
        impdAllElecsGroup = impdAllElecsGroup(:);

        badElecsGroup = impdAllElecsGroup>=25;
        percBadElecsGroup = sum(badElecsGroup)./length(impdAllElecsGroup)*100;
        impdGoodElecsGroup = impdAllElecsGroup(~badElecsGroup);
        minImpdGoodElecs = min(impdGoodElecsGroup); %#ok<*NASGU>
        maxImpdGoodElecs = max(impdGoodElecsGroup);
        meanImpdGoodElecs = nanmean(impdGoodElecsGroup);
        stdImpdGoodElecs = nanstd(impdGoodElecsGroup);

        Table_AnalysedSubjects(iGroup).PercentageBadElecs = num2str(round(percBadElecsGroup,1));
        Table_AnalysedSubjects(iGroup).ImpedanceRange = getRangeString(minImpdGoodElecs,maxImpdGoodElecs);    
        Table_AnalysedSubjects(iGroup).MeanImpedance = getMeanString(meanImpdGoodElecs,stdImpdGoodElecs);    
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Trial details
    minTotTrials = min(totalTrials(groupIndex));
    maxTotTrials = max(totalTrials(groupIndex));
    meanTotTrials = mean(totalTrials(groupIndex));
    stdTotTrials = std(totalTrials(groupIndex));
    
    Table_AnalysedSubjects(iGroup).TotalTrials_Range = getRangeString(minTotTrials,maxTotTrials);    
    Table_AnalysedSubjects(iGroup).Mean_TotalTrials = getMeanString(meanTotTrials,stdTotTrials); 
    
    %%%%%%%
    minAnalyzedTrials = min(numTrialsAllSubs(groupIndex));
    maxAnalyzedTrials = max(numTrialsAllSubs(groupIndex));
    meanAnalyzedTrials = mean(numTrialsAllSubs(groupIndex));
    stdAnalyzedTrials = std(numTrialsAllSubs(groupIndex));
    
    Table_AnalysedSubjects(iGroup).AnalyzedTrials_Range = getRangeString(minAnalyzedTrials,maxAnalyzedTrials);    
    Table_AnalysedSubjects(iGroup).Mean_AnalyzedTrials = getMeanString(meanAnalyzedTrials,stdAnalyzedTrials);   
    
    %%%%%%%
    if strcmpi(experimentName,'Gamma')
        minAnalyzedTrialsNoMS = min(numTrialsNoMS(groupIndex),[],'omitnan');
        maxAnalyzedTrialsNoMS = max(numTrialsNoMS(groupIndex),[],'omitnan');
        meanAnalyzedTrialsNoMS = nanmean(numTrialsNoMS(groupIndex));
        stdAnalyzedTrialsNoMS = nanstd(numTrialsNoMS(groupIndex));

        Table_AnalysedSubjects(iGroup).NoMicrosaccadesTrials_Range = getRangeString(minAnalyzedTrialsNoMS,maxAnalyzedTrialsNoMS);    
        Table_AnalysedSubjects(iGroup).Mean_NoMicrosaccadesTrials = getMeanString(meanAnalyzedTrialsNoMS,stdAnalyzedTrialsNoMS);   
    end
    %%%%%%%
    minPercBadEyeTrials = min(percBadEyeTrials(groupIndex));
    maxPercBadEyeTrials = max(percBadEyeTrials(groupIndex));
    meanPercBadEyeTrials = mean(percBadEyeTrials(groupIndex));
    stdPercBadEyeTrials = std(percBadEyeTrials(groupIndex));
    
    Table_AnalysedSubjects(iGroup).PercentageBadEyeTrials_Range = getRangeString(minPercBadEyeTrials,maxPercBadEyeTrials);    
    Table_AnalysedSubjects(iGroup).Mean_PercentageBadEyeTrials = getMeanString(meanPercBadEyeTrials,stdPercBadEyeTrials);   
    
    %%%%%%%
    percAllDiscardedElecsGroup = percAllDiscardedElecs(groupIndex);
    minPercAllDiscardedElecs = min(percAllDiscardedElecsGroup);
    maxPercAllDiscardedElecs = max(percAllDiscardedElecsGroup);
    meanPercAllDiscardedElecs = nanmean(percAllDiscardedElecsGroup);
    stdPercAllDiscardedElecs = nanstd(percAllDiscardedElecsGroup);
    
    Table_AnalysedSubjects(iGroup).PercentageDiscardedElecs_Range = getRangeString(minPercAllDiscardedElecs,maxPercAllDiscardedElecs);    
    Table_AnalysedSubjects(iGroup).Mean_PercentageDiscardedElecs = getMeanString(meanPercAllDiscardedElecs,stdPercAllDiscardedElecs);   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Eye-data
    maxSTDEyeX = max(stdEyeXDataAllSubs(groupIndex),[],'omitnan');
    maxSTDEyeY = max(stdEyeYDataAllSubs(groupIndex),[],'omitnan');
    
    Table_AnalysedSubjects(iGroup).maxSTDEyeX = num2str(round(maxSTDEyeX,2));
    Table_AnalysedSubjects(iGroup).maxSTDEyeY = num2str(round(maxSTDEyeY,2));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Clinical scores: CDR, HMSE
    CDR_Total = getClinicalNumsFromString(clinicalScoresAllSubs(groupIndex,CDR_TotalCol));
    CDR_Total(isnan(CDR_Total)) = [];
    uniqueCDR = unique(CDR_Total);
    
    txtStr = [];
    for iU = uniqueCDR
        txtStr = [txtStr num2str(iU) ' (' num2str(sum(CDR_Total==iU)) '); '];
    end
    Table_AnalysedSubjects(iGroup).CDR_Total = txtStr; 
    
    HMSE = getClinicalNumsFromString(clinicalScoresAllSubs(groupIndex,HMSECol));
    minHMSE = min(HMSE,[],'omitnan');
    maxHMSE = max(HMSE,[],'omitnan');
    meanHMSE = nanmean(HMSE);
    stdHMSE = nanstd(HMSE);
    numHMSE = sum(~isnan(HMSE));
    
    Table_AnalysedSubjects(iGroup).HMSE_Range = getRangeString(minHMSE,maxHMSE);    
    Table_AnalysedSubjects(iGroup).Mean_HMSE = getMeanString(meanHMSE,stdHMSE,numHMSE);   
end
end

function string = getMeanString(Mean,STD,Num)
    string = [num2str(round(Mean,1)) ' +/- ' num2str(round(STD,1))];
    if exist('Num','var'); string = [string ' (' num2str(Num) ')']; end;
end

function string = getRangeString(Mean,STD)
    string = [num2str(round(Mean,1)) ' - ' num2str(round(STD,1))];
end

function numMat = getClinicalNumsFromString(strMat)
    for iSub = 1:length(strMat)    
        if strcmp(strMat{iSub},'x') || strcmp(strMat{iSub},'not administeredx'); 
            numMat(1,iSub) = NaN; 
        else
            numMat(1,iSub) = str2num(strMat{iSub}(1:end-1));  %#ok<ST2NM>
        end
    end
end