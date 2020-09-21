clear; clc;
getDefaults;

nameCol=1; ageNum=2; sexNum=3;
alphaDPNum = 8; ssvepValsNum = 6;

tValsUnique = [0 16]; tValsUniqueTopo = 16;

gammaPowerDetails = load(fullfile(finalPlotsSaveFolder,'gammaAnalysis_GoodSubs.mat'),'gammaPowerAllSubs','bipInds31To64',...
    'diffPvsFAllSubsAreaWise','tfDataAllSubsAreaWise','SF_TopoDataAllSubs','clinicalScoresAllSubs','CDR_TotalCol','HMSECol','freqVals');
gammaPowerAllSubs = gammaPowerDetails.gammaPowerAllSubs;
diffPvsFAllSubsAreaWise = gammaPowerDetails.diffPvsFAllSubsAreaWise;
tfDataAllSubsAreaWise = gammaPowerDetails.tfDataAllSubsAreaWise;
SF_TopoDataAllSubs = gammaPowerDetails.SF_TopoDataAllSubs;
clinicalScoresAllSubs = gammaPowerDetails.clinicalScoresAllSubs;
CDR_TotalCol = gammaPowerDetails.CDR_TotalCol;
HMSECol = gammaPowerDetails.HMSECol;
freqVals = gammaPowerDetails.freqVals;

gammaAllSubNames = gammaPowerAllSubs(:,1);

iProject = 1;

labelNumAllCDR = []; sexAllCDR = [];
goodProtDem = []; badProtDem = []; 
subjectCount = 0; anSubNum = 1;
noisySubs{iProject} = {};
noSSSubs{iProject} = {};
nanSubs{iProject} = {};
nSucSubs{iProject} = {};

clear projectName; projectName = projectNames{iProject};
loadGammaDetailsSSVEP;

for iSub = 1:length(gammaAllSubNames)

    subNames{1} = gammaAllSubNames{iSub};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    clear subNumTFCP subNumTFCP_stPvsF subNumTFCP_blPvsF subNumTFCP_tf subNumTopo subNumInGPVals subNumInAllProtBLData
    subNumTFCP = strcmpi(ssvepVals(:,1),subNames{1});
    subNumTFCP_stPvsF = strcmpi(stPowerVsFreqTFCPAreaWise(:,1),subNames{1});
    subNumTFCP_blPvsF = strcmpi(blPowerVsFreqTFCPAreaWise(:,1),subNames{1});
    subNumTFCP_tf = strcmpi(tfPowerVals(:,1),subNames{1});
    subNumTopo = strcmpi(diffPowerTFCP_Topo(:,1),subNames{1});
    subNumInAllProtBLData = strcmpi(allProtocolsBLData(:,1),subNames{1});
    subNumInGPVals = strcmpi(gammaPowerAllSubs(:,1),subNames{1});

    allProtocolsBLData_TFCP = allProtocolsBLData{subNumInAllProtBLData,2};
    if ischar(allProtocolsBLData_TFCP{1})
        if strcmpi(allProtocolsBLData_TFCP{1},'No protocols listed for the subject');
            disp([subNames{1} ': No protocols listed for the subject']); noSSSubs{iProject} = cat(1,noSSSubs{iProject},subNames{1}); 
        else
            disp([subNames{1} ': not analysed: other reasons']); nanSubs{iProject} = cat(1,nanSubs{iProject},subNames{1});
        end
        continue;
    end     

    ageSub = gammaPowerAllSubs{subNumInGPVals,ageCol};
    sexSub = gammaPowerAllSubs{subNumInGPVals,sexCol};
    labelNumSub = gammaPowerAllSubs{subNumInGPVals,cdrNum};
    
    goodProtDem = cat(1,goodProtDem,repmat([ageSub sexSub labelNumSub anSubNum],sum(allProtocolsBLData_TFCP{2}),1));
    badProtDem = cat(1,badProtDem,repmat([ageSub sexSub labelNumSub anSubNum],sum(~allProtocolsBLData_TFCP{2}),1));
    labelNumAllCDR = cat(1,labelNumAllCDR,labelNumSub);
    sexAllCDR = cat(1,sexAllCDR,sexSub);
    anSubNum = anSubNum+1;

    if ~any(allProtocolsBLData_TFCP{2})        
        disp([subNames{1} ': no useful protocols']); noisySubs{iProject} = cat(1,noisySubs{iProject},subNames{1}); continue;             
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ssvepValsAllSubs{subjectCount+1,nameCol} = subNames{1}; %#ok<*SAGROW>
    ssvepValsAllSubs{subjectCount+1,ageNum} = ageSub;
    ssvepValsAllSubs{subjectCount+1,sexNum} = sexSub;

    ssvepValsAllSubs{subjectCount+1,g1NumAreaWise} = gammaPowerAllSubs{subNumInGPVals,g1NumAreaWise};
    ssvepValsAllSubs{subjectCount+1,g2NumAreaWise} = gammaPowerAllSubs{subNumInGPVals,g2NumAreaWise};
    ssvepValsAllSubs{subjectCount+1,alphaDPNum} = gammaPowerAllSubs{subNumInGPVals,alphaNumAreaWise};

    ssvepValsAllSubs{subjectCount+1,ssvepValsNum} = mean(ssvepVals{subNumTFCP,2}{1});
    ssvepValsAllSubs{subjectCount+1,cdrNum} = labelNumSub;

    numTrialsAllSubsSSVEP(subjectCount+1) = ssvepVals{subNumTFCP,2}{3};

    % TF Plots
    tfPlot_TFCP = tfPowerVals{subNumTFCP_tf,2};
    timeValsTF = tfPlot_TFCP{1,2};
    freqValsTF = tfPlot_TFCP{1,3};
    blPosTF = timeValsTF>=blRange(1) & timeValsTF<=blRange(2);
    tfPowerAreaWise = squeeze(mean(tfPlot_TFCP{1,1},1));
    blAreaWise = repmat(squeeze(mean(tfPowerAreaWise(blPosTF,:),1)),length(timeValsTF),1);
    tfDataTFCP(subjectCount+1,:,:) = 10.*log10(tfPowerAreaWise./blAreaWise);    

    stPvsF_TFCP = stPowerVsFreqTFCPAreaWise{subNumTFCP_stPvsF,2};
    blPvsF_TFCP = blPowerVsFreqTFCPAreaWise{subNumTFCP_blPvsF,2};
    diffPvsFAllSubsTFCP(subjectCount+1,:) = 10.*log10(mean(stPvsF_TFCP{1},1)./mean(blPvsF_TFCP{1},1));

    diffPowerTFCP_TopoSub = diffPowerTFCP_Topo{subNumTopo,2}{1};
    tfcpTopo(subjectCount+1,:) = NaN(112,1);
    if length(diffPowerTFCP_TopoSub)==50 % actiCap31Posterior
        tfcpTopo(subjectCount+1,bipInds31To64) = diffPowerTFCP_TopoSub;
    elseif length(diffPowerTFCP_TopoSub)==112 % actiCap64
        tfcpTopo(subjectCount+1,:) = diffPowerTFCP_TopoSub;
    end

    %%%%%%%%%%%%
    diffPvsFAllSubsGamma(subjectCount+1,:) = diffPvsFAllSubsAreaWise(subNumInGPVals,:);
    tfDataGamma(subjectCount+1,:,:) = tfDataAllSubsAreaWise(subNumInGPVals,:,:);
    gammaTopo(subjectCount+1,:,:) = SF_TopoDataAllSubs(subNumInGPVals,:,:);

    %%%%%%%%%%%%
    clinicalScoresSSVEP{subjectCount+1,CDR_TotalCol} = clinicalScoresAllSubs{subNumInGPVals,CDR_TotalCol};
    clinicalScoresSSVEP{subjectCount+1,HMSECol} = clinicalScoresAllSubs{subNumInGPVals,HMSECol};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get trial information
    protType = protocolTypesForSub{ismember(subNamesForProt,subNames{1})};
    expDate = expDateForSub{ismember(subNamesForProt,subNames{1})};
    protName = protocolNamesForSub{ismember(subNamesForProt,subNames{1})};
    trialDataFolder = fullfile(folderSourceString,'trialInfo',projectName,'TFCP'); % MD 02-July-2020

    goodProtFlag = allProtocolsBLData_TFCP{2};
    totalTrials(subjectCount+1) = 0;
    badEyeTrials(subjectCount+1) = 0;
    finalBadTrialscommon(subjectCount+1,:) = 0;
    badTrialscommon(subjectCount+1,:) = 0;
    percAllDiscardedElecs(subjectCount+1) = 0;
    for iProt = 1:length(goodProtFlag)
        if ~goodProtFlag(iProt)
            continue
        end

        clear fileList                     
        fileList = [subNames{1} '-' expDate '-' protName{iProt} '.mat'];             
        trialDetails = load(fullfile(trialDataFolder,fileList),'badTrials','badTrialsUnique','badElecs','totalTrials');

        totalTrials(subjectCount+1) = totalTrials(subjectCount+1) + trialDetails.totalTrials;
        badEyeTrials(subjectCount+1) = badEyeTrials(subjectCount+1) + length(trialDetails.badTrialsUnique.badEyeTrials);
        badTrialscommon(subjectCount+1,:) = badTrialscommon(subjectCount+1,:) + length(trialDetails.badTrials); 
        finalBadTrialscommon(subjectCount+1,:) = ...
            finalBadTrialscommon(subjectCount+1,:) + length(union(trialDetails.badTrialsUnique.badEyeTrials,trialDetails.badTrials));

        goodImpedanceElecs = 1:length(trialDetails.badElecs.elecImpedance);
        goodImpedanceElecs(trialDetails.badElecs.badImpedanceElecs)=[];
        numNoisyElecs = length(trialDetails.badElecs.noisyElecs); % Bad impedance electrodes have already been discarded while saving this variable.
        percAllDiscardedElecs(subjectCount+1) = percAllDiscardedElecs(subjectCount+1) + ((length(trialDetails.badElecs.flatPSDElecs)+numNoisyElecs)./length(goodImpedanceElecs))*100;
    end
    percAllDiscardedElecs(subjectCount+1) = percAllDiscardedElecs(subjectCount+1)./sum(goodProtFlag); % mean percentage across blocks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get eye data
    cleanDataFolder = fullfile(folderSourceString,'decimatedData',projectName,protType);
    if ~strcmpi(subNames{1},'013JM') && ~strcmpi(subNames{1},'014SM') && ~strcmpi(subNames{1},'084VB')

        clear fileLists
        for iProt = 1:length(goodProtFlag)              
            fileLists{iProt} = [subNames{1} '-' expDate '-' protName{iProt} '.mat']; 
        end            
        fileLists(~goodProtFlag)=[];

        [eyeDataSub.eyeDataDegX,eyeDataSub.eyeDataDegY,eyeDataSub.eyeDataArbUnitsP,eyeDataSub.timeValsEyeData] = ...
            getEyeDataIndividualSubject(fileLists,cleanDataFolder);            

        timeValsEyeDataSubject = eyeDataSub.timeValsEyeData;
        eyeTPos = timeValsEyeDataSubject>=-0.5 & timeValsEyeDataSubject<=0.75;

        eyeXDataSubject = eyeDataSub.eyeDataDegX(:,eyeTPos);
        eyeYDataSubject = eyeDataSub.eyeDataDegY(:,eyeTPos);
        eyeXDataSubject = (eyeXDataSubject - repmat(mean(eyeXDataSubject,2),1,size(eyeXDataSubject,2)))';
        eyeYDataSubject = (eyeYDataSubject - repmat(mean(eyeYDataSubject,2),1,size(eyeYDataSubject,2)))';

        stdEyeXDataAllSubs(subjectCount+1) = std(eyeXDataSubject(:));
        stdEyeYDataAllSubs(subjectCount+1) = std(eyeYDataSubject(:));            
    else
        stdEyeXDataAllSubs(subjectCount+1) = NaN;
        stdEyeYDataAllSubs(subjectCount+1) = NaN;            
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nSucSubs{iProject} = cat(1,nSucSubs{iProject},subNames{1}); 
    disp([num2str(subjectCount+1) ': ' subNames{1}]);
    subjectCount = subjectCount+1; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(finalPlotsSaveFolder,'ssvepAnalysis_GoodSubs.mat'));
