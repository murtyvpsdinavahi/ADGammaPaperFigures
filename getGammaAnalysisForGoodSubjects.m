clear; clc;
getDefaults;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
projectName = projectNames{1};
loadGammaDetails;
goodSubjects = getGoodSubjects(projectName,0);
cleanDataFolder = fullfile(folderSourceString,'decimatedData',projectName,'SF_ORI');

labelNumAllCDR = []; sexAllCDR = [];
goodProtDem = []; badProtDem = []; 
subjectCount = 0; anSubNum = 1;
analyzedGoodSubs = {}; noisySubs = {};

for iSub = 1:length(goodSubjects)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subNames = goodSubjects(iSub);
    demName = subNames{1};  
    
    % These subjects had different codes in the demographics file (used to generate goodSubjects list) that was
    % given to us. The codes were different when data was originally saved.
    if strcmpi(demName,'011KH_F1'); subNames{1} = '011KH'; end;
    if strcmpi(demName,'144BR'); subNames{1} = '144RP'; end;
    if strcmpi(demName,'227SN'); subNames{1} = '227MN'; end;
    if strcmpi(demName,'236SD'); subNames{1} = '236S'; end;
    if strcmpi(demName,'295R'); subNames{1} = '295RS'; end;

    getSubNumsAndValsForIndividualSubject;    
    goodProtFlag = allProtocolsBLData_SF_unipolar{2};
    
    goodProtDem = cat(1,goodProtDem,repmat([ageSub sexSub labelNumSub anSubNum],sum(allProtocolsBLData_SF_unipolar{2}),1));
    badProtDem = cat(1,badProtDem,repmat([ageSub sexSub labelNumSub anSubNum],sum(~allProtocolsBLData_SF_unipolar{2}),1));
    labelNumAllCDR = cat(1,labelNumAllCDR,labelNumSub);
    sexAllCDR = cat(1,sexAllCDR,sexSub);
    anSubNum = anSubNum+1;

    if ~any(goodProtFlag)        
        disp([subNames{1} ': no useful protocols']); noisySubs = cat(1,noisySubs,subNames{1}); continue;             
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    protType = protocolTypesForSub{ismember(subNamesForProt,subNames{1})};
    expDate = expDateForSub{ismember(subNamesForProt,subNames{1})};
    protName = protocolNamesForSub{ismember(subNamesForProt,subNames{1})};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numGoodProtPerSubject(subjectCount+1) = sum(allProtocolsBLData_SF_unipolar{2}); %#ok<*SAGROW>
    numTrialsAllSubs(subjectCount+1,:) = (gammaPowerVals_SF{1, 3}); 

    gammaPowerAllSubs{subjectCount+1,nameCol} = subNames{1};
    gammaPowerAllSubs{subjectCount+1,ageCol} = ageSub;
    gammaPowerAllSubs{subjectCount+1,sexCol} = sexSub;
    gammaPowerAllSubs{subjectCount+1,cdrNum} = labelNumSub;        
    gammaPowerAllSubs{subjectCount+1,g1NumAreaWise} = mean(gammaPowerVals_SF{1, 1});
    gammaPowerAllSubs{subjectCount+1,g2NumAreaWise} = mean(gammaPowerVals_SF{1, 2});
    gammaPowerAllSubs{subjectCount+1,alphaNumAreaWise} = mean(alphaPowerVals_SF{1, 1});

    gammaPowerAllSubsNB(subjectCount+1,1) = mean(gammaPowerValsAreaWiseSubNarrowerBand{1, 1});
    gammaPowerAllSubsNB(subjectCount+1,2) = mean(gammaPowerValsAreaWiseSubNarrowerBand{1, 2});

    consensusLabelAllSubs(subjectCount+1) = consensusLabelNumSub; 

    for iClSc = 1:length(clinScoreCols)
        clinicalScoresAllSubs{subjectCount+1,clinScoreCols(iClSc)} = clinicalDetails{subNumSFInClnDetails,clinScoreCols(iClSc)};
    end

    % Get average spectra, TF and scalp maps
    % Changed from Age paper: first mean across electrodes and then ratio of stim to baseline
    [diffPvsFAllSubsAreaWise(subjectCount+1,:),timeValsTF,freqValsTF,tfDataAllSubsAreaWise(subjectCount+1,:,:),...
        SF_TopoDataAllSubs(subjectCount+1,:,:),blPvsFSubAllElecs(subjectCount+1,:,:),freqVals,bandPowerAllElecs(subjectCount+1,:,:),...
        gammaValsFromDiffPower(subjectCount+1,:,:),slopeAllSubsAllElecs(subjectCount+1,:,:)] = ...
        getMTVals(stPvsF_SF,blPvsF_SF,tfPlot_SF,blRange,...
        dPowerSF_Ori_Topo,bipInds31To64,blPvsF_SF_unipolar,alphaCheckRange,gamma1CheckRange,gamma2CheckRange,...
        computeSlopesAtFreqs,freqsToAvoid);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Get trial information
    totalTrials(subjectCount+1) = 0;
    badEyeTrials(subjectCount+1) = 0;
    badTrialscommon(subjectCount+1,:) = 0;
    finalBadTrialscommon(subjectCount+1,:) = 0;
    numBadTrialsAllElecs(subjectCount+1) = 0;
    numBadTrialsVisElecs(subjectCount+1) = 0;
    percNoisyElecs(subjectCount+1) = 0;
    percFlatPSDVisElecs(subjectCount+1) = 0;
    percFlatPSDAllElecs(subjectCount+1) = 0;
    percAllDiscardedElecs(subjectCount+1) = 0;
    clear badTrialsTimeAllElecsSub badTrialsFreqAllElecsSub
    for iProt = 1:length(goodProtFlag)
        if ~goodProtFlag(iProt)
            continue
        end

        clear fileList                     
        fileList = [subNames{1} '-' expDate '-' protName{iProt} '.mat']; 
        trialDataFolder = fullfile(folderSourceString,'trialInfo',projectName,'SF_ORI'); % MD 02-July-2020
        trialDetails = load(fullfile(trialDataFolder,fileList),'badTrials','badTrialsUnique','badElecs','totalTrials');

        totalTrials(subjectCount+1) = totalTrials(subjectCount+1) + trialDetails.totalTrials;            
        badEyeTrials(subjectCount+1) = badEyeTrials(subjectCount+1) + length(trialDetails.badTrialsUnique.badEyeTrials);            

        goodImpedanceElecs = 1:length(trialDetails.badElecs.elecImpedance);
        goodImpedanceElecs(trialDetails.badElecs.badImpedanceElecs)=[];

        if ~exist('badTrialsTimeAllElecsSub','var')
            badTrialsTimeAllElecsSub=zeros(1,length(goodImpedanceElecs));
            badTrialsFreqAllElecsSub=zeros(1,length(goodImpedanceElecs));
        end; 
        badTrialsTimeAllElecsSub = badTrialsTimeAllElecsSub + cellfun(@length,trialDetails.badTrialsUnique.timeThres(goodImpedanceElecs));
        badTrialsFreqAllElecsSub = badTrialsFreqAllElecsSub + cellfun(@length,trialDetails.badTrialsUnique.freqThres(goodImpedanceElecs));

        numNoisyElecs = length(trialDetails.badElecs.noisyElecs); % Bad impedance electrodes have already been discarded while saving this variable.
        percNoisyElecs(subjectCount+1) = percNoisyElecs(subjectCount+1) + (numNoisyElecs/length(goodImpedanceElecs))*100;

        badTrialsAllElecs = trialDetails.badTrialsUnique.commonBadTrialsAllElecs;
        numBadTrialsAllElecs(subjectCount+1) = numBadTrialsAllElecs(subjectCount+1) + length(badTrialsAllElecs);
        numBadTrialsVisElecs(subjectCount+1) = numBadTrialsVisElecs(subjectCount+1) + length(setdiff(trialDetails.badTrialsUnique.commonBadTrialsVisElecs,badTrialsAllElecs));
        badTrialscommon(subjectCount+1,:) = badTrialscommon(subjectCount+1,:) + length(trialDetails.badTrials);            

        finalBadTrialscommon(subjectCount+1,:) = finalBadTrialscommon(subjectCount+1,:) + length(union(trialDetails.badTrialsUnique.badEyeTrials,trialDetails.badTrials));

        percFlatPSDAllElecs(subjectCount+1) = percFlatPSDAllElecs(subjectCount+1) + (length(trialDetails.badElecs.flatPSDElecs)./(length(goodImpedanceElecs)-numNoisyElecs))*100;
        percFlatPSDVisElecs(subjectCount+1) = percFlatPSDVisElecs(subjectCount+1) + (length(intersect(trialDetails.badElecs.flatPSDElecs,electrodeListUnipolar))./length(electrodeListUnipolar))*100;

        percAllDiscardedElecs(subjectCount+1) = percAllDiscardedElecs(subjectCount+1) + ((length(trialDetails.badElecs.flatPSDElecs)+numNoisyElecs)./length(goodImpedanceElecs))*100;
    end

    percBadTrialsTime(subjectCount+1) = mean((badTrialsTimeAllElecsSub./(totalTrials(subjectCount+1)-badEyeTrials(subjectCount+1)))*100);
    percBadTrialsPSD(subjectCount+1) = mean((badTrialsFreqAllElecsSub./(repmat(totalTrials(subjectCount+1)-badEyeTrials(subjectCount+1),1,size(badTrialsTimeAllElecsSub,2))-badTrialsTimeAllElecsSub))*100);

    percNoisyElecs(subjectCount+1) = percNoisyElecs(subjectCount+1)./sum(goodProtFlag); % mean percentage across blocks
    percFlatPSDAllElecs(subjectCount+1) = percFlatPSDAllElecs(subjectCount+1)./sum(goodProtFlag); % mean percentage across blocks
    percFlatPSDVisElecs(subjectCount+1) = percFlatPSDVisElecs(subjectCount+1)./sum(goodProtFlag); % mean percentage across blocks
    percAllDiscardedElecs(subjectCount+1) = percAllDiscardedElecs(subjectCount+1)./sum(goodProtFlag); % mean percentage across blocks

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get electrode impedances
    elecImpedances(subjectCount+1,:) = NaN(1,64);
    if length(dPowerSF_Ori_Topo{1})==50 % actiCap31Posterior
        elecImpedances(subjectCount+1,unipInds31To64) = trialDetails.badElecs.elecImpedance; % Same across all protocols
    elseif length(dPowerSF_Ori_Topo{1})==112 % actiCap64
        elecImpedances(subjectCount+1,:) = trialDetails.badElecs.elecImpedance'; % Same across all protocols
    end
    %}

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get eye data
    if ~strcmpi(subNames{1},'013JM') && ~strcmpi(subNames{1},'014SM') && ~strcmpi(subNames{1},'084VB') % absent eye data

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

        meanEyeXDataAllSubs(subjectCount+1,:) = mean(eyeXDataSubject,2);
        meanEyeYDataAllSubs(subjectCount+1,:) = mean(eyeYDataSubject,2);
        pupilDataSubject = eyeDataSub.eyeDataArbUnitsP(:,eyeTPos)';
        cvPupilSub = std(pupilDataSubject,[],1)./mean(pupilDataSubject,1);
        cvPupilSub(isnan(cvPupilSub))=[]; % Some eye-data is recorded as zeros during the analysis period of -0.5 to 0.75, although there is some data in the repeat outside the analysis window. These trials have mean zero, hence removed.
        meanCVPupilAllSubs(subjectCount+1,:) = mean(cvPupilSub); 
        stdCVPupilSub = std(cvPupilSub); 
        semCVPupilAllSubs(subjectCount+1,:) = stdCVPupilSub./sqrt(length(cvPupilSub));
    else
        stdEyeXDataAllSubs(subjectCount+1) = NaN;
        stdEyeYDataAllSubs(subjectCount+1) = NaN;

        meanEyeXDataAllSubs(subjectCount+1,:) = NaN(1,626);
        meanEyeYDataAllSubs(subjectCount+1,:) = NaN(1,626);
        meanCVPupilAllSubs(subjectCount+1,:) = NaN;
        semCVPupilAllSubs(subjectCount+1,:) = NaN;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get microsaccade info
    if ~strcmpi(subNames{1},'013JM') && ~strcmpi(subNames{1},'014SM') && ~strcmpi(subNames{1},'084VB')            
        analysedEyeDataFolder = fullfile(folderSourceString,'analysedEyeData',projectName);
        analysedEyeDataSub = load(fullfile(analysedEyeDataFolder,'SF_ORI',[subNames{1} '_AnalysedEyeData.mat']),...
            'microsaccades','microsaccadesStats');

        msData = analysedEyeDataSub.microsaccades;
        msStatsData = analysedEyeDataSub.microsaccadesStats;
        MS = msData.MS;
        [psthMSAllSubs(subjectCount+1,:),timeValsMS] = getPSTH(MS,20,timeRangeEye);  
        meanMSFreqAllSubs(subjectCount+1) = msStatsData.meanMSFreq;
        numMSInRangeAllSubs{subjectCount+1} = msData.numMSInRange;            
        nMSAllSubs(subjectCount+1) = msData.nMS;
        peakVelocityAllSubs{subjectCount+1} = msStatsData.peakVelocityAll;
        MSMagAllSubs{subjectCount+1} = msStatsData.MSMagAll;
    else            
        psthMSAllSubs(subjectCount+1,:) = NaN(1,length(timeValsMS));
        meanMSFreqAllSubs(subjectCount+1) = NaN;
        numMSInRangeAllSubs{subjectCount+1} = NaN;            
        nMSAllSubs(subjectCount+1) = NaN;
        peakVelocityAllSubs{subjectCount+1} = NaN;
        MSMagAllSubs{subjectCount+1} = NaN;
    end

    % Calculate gamma power for trials without MS
    if ~strcmpi(subNames{1},'013JM') && ~strcmpi(subNames{1},'014SM') && ~strcmpi(subNames{1},'084VB')
        SGammaNoMS(subjectCount+1) = mean(gammaPowerValsSubAreaWiseNoMS{1});
        FGammaNoMS(subjectCount+1) = mean(gammaPowerValsSubAreaWiseNoMS{2});
        alphaNoMS(subjectCount+1) = mean(alphaPowerValsSubAreaWiseNoMS{1});
        numTrialsNoMS(subjectCount+1) = gammaPowerValsSubAreaWiseNoMS{3};
    else
        SGammaNoMS(subjectCount+1) = NaN;
        FGammaNoMS(subjectCount+1) = NaN;
        alphaNoMS(subjectCount+1) = NaN;
        numTrialsNoMS(subjectCount+1) = NaN;            
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    analyzedGoodSubs = cat(1,analyzedGoodSubs,subNames{1});
    disp([num2str(subjectCount+1) ': ' subNames{1}]);
    subjectCount = subjectCount+1;      
end

blPvsFSubAllElecs = permute(blPvsFSubAllElecs,[2 1 3]);
bandPowerAllElecs = permute(bandPowerAllElecs,[2 1 3]);
slopeAllSubsAllElecs = permute(slopeAllSubsAllElecs,[2 1 3]);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear gammaDetails gammaDetailsUnipolar
save(fullfile(finalPlotsSaveFolder,'gammaAnalysis_GoodSubs.mat'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
