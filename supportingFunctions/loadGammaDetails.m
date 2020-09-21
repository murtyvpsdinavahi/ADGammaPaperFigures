
clear demographicDetails nameCol ageCol sexCol labelCol
demographicDetails = load(fullfile(workbookFolder,[projectName 'Details.mat']), 'demographicDetails');
demographicDetails = demographicDetails.demographicDetails;
nameCol = find(strcmpi(demographicDetails(1,:),'subjectName'));
ageCol = find(strcmpi(demographicDetails(1,:),'Age'));
sexCol = find(strcmpi(demographicDetails(1,:),'Sex'));
labelCol = find(strcmpi(demographicDetails(1,:),'Label'));
consensusLabelCol = find(strcmpi(demographicDetails(1,:),'consensusLabel'));
%%%%%%%%

% Get clinical data
clear clinicalDetails nameClinicalDetailsCol CDR_TotalCol HMSECol 
clinicalDetails = load(fullfile(workbookFolder,[projectName 'ClinicalDetails.mat']), 'clinicalDetails');
clinicalDetails = clinicalDetails.clinicalDetails;
nameClinicalDetailsCol = find(strcmpi(clinicalDetails(1,:),'subjectName'));
CDR_TotalCol = find(strcmpi(clinicalDetails(1,:),'CDR_Total'));
HMSECol = find(strcmpi(clinicalDetails(1,:),'HMSE'));

clinScoreCols = [CDR_TotalCol HMSECol];

clinScoreNames = {'CDR_Total' 'HMSE'};


%%%%%%%%
% For bipolar scheme
clear gammaDetails
gammaDetails = load(fullfile(workbookFolder,[projectName 'AnalysisDetails_bipolar.mat']),...
    'gammaPowerValsAreaWise','alphaPowerValsAreaWise','tfPower_sfAreaWise','blPowerVsFreq_SFAreaWise','stPowerVsFreq_SFAreaWise',...
    'diffPowerSF_Ori_Topo','gammaPowerValsAreaWiseNoMS','alphaPowerValsAreaWiseNoMS','gammaPowerValsAreaWiseNarrowerBand',...
    'gammaPowerValsAreaWise_TFCP','alphaPowerValsAreaWise_TFCP','blPowerVsFreq_TFCPGamma_AreaWise','stPowerVsFreq_TFCPGamma_AreaWise');

clear gammaPowerValsAreaWise alphaPowerValsAreaWise tfPower_sfAreaWise blPowerVsFreq_SFAreaWise...
    stPowerVsFreq_SFAreaWise diffPowerSF_Ori_Topo gammaPowerValsAreaWiseNoMS alphaPowerValsAreaWiseNoMS gammaPowerValsAreaWiseNarrowerBand...
    
gammaPowerValsAreaWise = gammaDetails.gammaPowerValsAreaWise;
alphaPowerValsAreaWise = gammaDetails.alphaPowerValsAreaWise;
tfPower_sfAreaWise = gammaDetails.tfPower_sfAreaWise;
blPowerVsFreq_SFAreaWise = gammaDetails.blPowerVsFreq_SFAreaWise;
stPowerVsFreq_SFAreaWise = gammaDetails.stPowerVsFreq_SFAreaWise;
diffPowerSF_Ori_Topo = gammaDetails.diffPowerSF_Ori_Topo;
gammaPowerValsAreaWiseNoMS = gammaDetails.gammaPowerValsAreaWiseNoMS;
alphaPowerValsAreaWiseNoMS = gammaDetails.alphaPowerValsAreaWiseNoMS;
gammaPowerValsAreaWiseNarrowerBand = gammaDetails.gammaPowerValsAreaWiseNarrowerBand;

gammaPowerValsAreaWise_TFCP = gammaDetails.gammaPowerValsAreaWise_TFCP;
alphaPowerValsAreaWise_TFCP = gammaDetails.alphaPowerValsAreaWise_TFCP;
blPowerVsFreq_TFCPGamma_AreaWise = gammaDetails.blPowerVsFreq_TFCPGamma_AreaWise;
stPowerVsFreq_TFCPGamma_AreaWise = gammaDetails.stPowerVsFreq_TFCPGamma_AreaWise;


%%{
% For unipolar scheme
clear gammaDetailsUnipolar 
gammaDetailsUnipolar = load(fullfile(workbookFolder,[projectName 'AnalysisDetails_unipolar.mat']),'blPowerVsFreq_SFAreaWise','allProtocolsBLData');
clear blPowerVsFreq_SFAreaWiseUnipolar allProtocolsBLData 
blPowerVsFreq_SFAreaWiseUnipolar = gammaDetailsUnipolar.blPowerVsFreq_SFAreaWise;
allProtocolsBLData = gammaDetailsUnipolar.allProtocolsBLData;

%}
%%%%%%%%

subjectNums = cell(1,size(gammaPowerValsAreaWise,1));
allSubNames = cell(1,size(gammaPowerValsAreaWise,1));
for iSub = 1:size(gammaPowerValsAreaWise,1)
    subjectNums{iSub} = (gammaPowerValsAreaWise{iSub,1}(1:3));
    allSubNames{iSub}  = gammaPowerValsAreaWise{iSub,1};
end

%%%%%%%%%
[subjectNamesAll,expDatesAll,protocolNamesAll,protocolTypesAll,capLayoutsAll] = loadProjectDetails(projectName,1);
giveFolderSubjectString = 'fullfile(allExtractedDataFolder,gridType,projectName,subNames{1});';

clear protNums subsForProt subNamesForProt
protNums = ismember(protocolTypesAll,{'SF' 'SF_ORI' 'SF_ORI_New'})';
subsForProt = unique(subjectNamesAll(protNums));
subNamesForProt = intersect(allSubNames,subsForProt);

clear expDateForSub protocolNamesForSub protocolTypesForSub capLayoutForSub
for iSubs = 1:length(subNamesForProt)
    expDateForSub(iSubs) = unique(expDatesAll(ismember(subjectNamesAll,subNamesForProt{iSubs}) & protNums'));
    protocolNamesForSub{iSubs} = unique(protocolNamesAll(ismember(subjectNamesAll,subNamesForProt{iSubs}) & protNums'));
    protocolTypesForSub(iSubs) = unique(protocolTypesAll(ismember(subjectNamesAll,subNamesForProt{iSubs}) & protNums'));
    capLayoutForSub(iSubs) = unique(capLayoutsAll(ismember(subjectNamesAll,subNamesForProt{iSubs}) & protNums'));
end



