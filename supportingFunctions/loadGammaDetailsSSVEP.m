
clear demographicDetails nameCol ageCol sexCol cdrCol
demographicDetails = load(fullfile(workbookFolder,[projectName 'Details.mat']), 'demographicDetails');
demographicDetails = demographicDetails.demographicDetails;
nameCol = find(strcmpi(demographicDetails(1,:),'subjectName'));
ageCol = find(strcmpi(demographicDetails(1,:),'Age'));
sexCol = find(strcmpi(demographicDetails(1,:),'Sex'));
cdrCol = find(strcmpi(demographicDetails(1,:),'CDR'));

clear gammaDetails ssvepVals tfPowerVals stPowerVsFreqTFCPAreaWise blPowerVsFreqTFCPAreaWise diffPowerTFCP_Topo allProtocolsBLData
% gammaDetails = load(fullfile(workbookFolder,[projectName 'AnalysisDetails_bipolar.mat']),'ssvepVals','tfPower_tfcp','logPowerVsFreqTFCP','diffPowerTFCP_Topo');
gammaDetails = load(fullfile(workbookFolder,[projectName 'AnalysisDetails_bipolar.mat']),...
    'ssvepValsAreaWise','tfPower_tfcpAreaWise','stPowerVsFreqTFCPAreaWise','blPowerVsFreqTFCPAreaWise',...
    'diffPowerTFCP_Topo','allProtocolsBLData_TFCP');%,'gammaPowerValsAreaWise_TFCP','alphaPowerValsAreaWise_TFCP','blPowerVsFreq_TFCPGamma_AreaWise','stPowerVsFreq_TFCPGamma_AreaWise');
ssvepVals = gammaDetails.ssvepValsAreaWise;
tfPowerVals = gammaDetails.tfPower_tfcpAreaWise;
stPowerVsFreqTFCPAreaWise = gammaDetails.stPowerVsFreqTFCPAreaWise;
blPowerVsFreqTFCPAreaWise = gammaDetails.blPowerVsFreqTFCPAreaWise;
diffPowerTFCP_Topo = gammaDetails.diffPowerTFCP_Topo;
allProtocolsBLData = gammaDetails.allProtocolsBLData_TFCP;
% gammaPowerValsAreaWise_TFCP = gammaDetails.gammaPowerValsAreaWise_TFCP;
% alphaPowerValsAreaWise_TFCP = gammaDetails.alphaPowerValsAreaWise_TFCP;
% blPowerVsFreq_TFCPGamma_AreaWise = gammaDetails.blPowerVsFreq_TFCPGamma_AreaWise;
% stPowerVsFreq_TFCPGamma_AreaWise = gammaDetails.stPowerVsFreq_TFCPGamma_AreaWise;

% clear gammaDetailsUnipolar allProtocolsBLData
% gammaDetailsUnipolar = load(fullfile(workbookFolder,[projectName 'AnalysisDetails_unipolar.mat']),'allProtocolsBLData_TFCP');
% allProtocolsBLData = gammaDetailsUnipolar.allProtocolsBLData_TFCP;
    
%%%%%%%%
% numSubjectsPerProject = cat(2,numSubjectsPerProject,sum(~cellfun(@isempty,ssvepVals(:,2))));

if strcmpi(projectName,'VisualGamma'); numIndices = 1:2;
elseif strcmpi(projectName,'AgeProjectRound1'); numIndices = 2:4;
elseif strcmpi(projectName,'ADGammaProject'); numIndices = 1:3;
end;
subjectNums = cell(1,size(ssvepVals,1));
allSubNames = cell(1,size(ssvepVals,1));
for iSub = 1:size(ssvepVals,1)
    subjectNums{iSub} = (ssvepVals{iSub,1}(numIndices));
    allSubNames{iSub}  = ssvepVals{iSub,1};
end
%%%%%%%%%

gridType = 'EEG';
if strcmpi(projectName,'VisualGamma')
    projectName = 'VisualGamma'; gridType = 'EEG';
    [subjectNamesAll,expDatesAll,protocolNamesAll,~,~,capLayoutsAll,protocolTypesAll] = eval(['allProtocols' upper(projectName(1)) projectName(2:end) gridType]);
    giveFolderSubjectString = 'fullfile(allExtractedDataFolder,gridType,subNames{1});';
else
    [subjectNamesAll,expDatesAll,protocolNamesAll,protocolTypesAll,capLayoutsAll] = loadProjectDetails(projectName,1);
    giveFolderSubjectString = 'fullfile(allExtractedDataFolder,gridType,projectName,subNames{1});';
end
% if strcmpi(projectName,'VisualGamma')
%     projectName = 'VisualGamma'; gridType = 'EEG';
%     [subjectNamesAll,~,~,~,~,~,protocolTypesAll] = eval(['allProtocols' upper(projectName(1)) projectName(2:end) gridType]);
% else
%     [subjectNamesAll,~,~,protocolTypesAll] = loadProjectDetails(projectName);
% end

% protNums = ismember(protocolTypesAll,{'SF' 'SF_ORI' 'SF_ORI_New'})';
% subsForProt = unique(subjectNamesAll(protNums));
% subNamesForProt = intersect(allSubNames,subsForProt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear protNums subsForProt subNamesForProt
protNums = ismember(protocolTypesAll,{'TFCP'})';
subsForProt = unique(subjectNamesAll(protNums));
subNamesForProt = intersect(allSubNames,subsForProt);

clear expDateForSub protocolNamesForSub protocolTypesForSub capLayoutForSub
for iSubs = 1:length(subNamesForProt)
    expDateForSub(iSubs) = unique(expDatesAll(ismember(subjectNamesAll,subNamesForProt{iSubs}) & protNums'));
    protocolNamesForSub{iSubs} = unique(protocolNamesAll(ismember(subjectNamesAll,subNamesForProt{iSubs}) & protNums'));
    protocolTypesForSub(iSubs) = unique(protocolTypesAll(ismember(subjectNamesAll,subNamesForProt{iSubs}) & protNums'));
    capLayoutForSub(iSubs) = unique(capLayoutsAll(ismember(subjectNamesAll,subNamesForProt{iSubs}) & protNums'));
end