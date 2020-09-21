clear subNumSFAreaWise subNumAlphaAreaWise subNumTF_SFAreaWise subNumST_SFAreaWise...
    subNumBL_SFAreaWise subNumSFNoMSAreaWise subNumSFAlphaNoMSAreaWise subNumGPNarBand...
    subNumGamma_TFCP subNumAlpha_TFCP subNumGamma_TFCP_stPvsF subNumGamma_TFCP_blPvsF
subNumSFAreaWise = strcmpi(gammaPowerValsAreaWise(:,1),subNames{1});
subNumAlphaAreaWise = strcmpi(alphaPowerValsAreaWise(:,1),subNames{1});
subNumTF_SFAreaWise = strcmpi(tfPower_sfAreaWise(:,1),subNames{1});
subNumST_SFAreaWise = strcmpi(stPowerVsFreq_SFAreaWise(:,1),subNames{1});
subNumBL_SFAreaWise = strcmpi(blPowerVsFreq_SFAreaWise(:,1),subNames{1});
subNumTopo = strcmpi(diffPowerSF_Ori_Topo(:,1),subNames{1});
subNumSFNoMSAreaWise = strcmpi(gammaPowerValsAreaWiseNoMS(:,1),subNames{1});
subNumSFAlphaNoMSAreaWise = strcmpi(alphaPowerValsAreaWiseNoMS(:,1),subNames{1});
subNumGPNarBand = strcmpi(gammaPowerValsAreaWiseNarrowerBand(:,1),subNames{1});

subNumGamma_TFCP = strcmpi(gammaPowerValsAreaWise_TFCP(:,1),subNames{1});
subNumAlpha_TFCP = strcmpi(alphaPowerValsAreaWise_TFCP(:,1),subNames{1});
subNumGamma_TFCP_stPvsF = strcmpi(stPowerVsFreq_TFCPGamma_AreaWise(:,1),subNames{1});
subNumGamma_TFCP_blPvsF = strcmpi(blPowerVsFreq_TFCPGamma_AreaWise(:,1),subNames{1});
        

clear gammaPowerVals_SF alphaPowerVals_SF tfPlot_SF stPvsF_SF blPvsF_SF dPowerSF_Ori_Topo...
    gammaPowerValsSubAreaWiseNoMS alphaPowerValsSubAreaWiseNoMS gammaPowerValsAreaWiseSubNarrowerBand...
    gammaPowerVals_TFCP alphaPowerVals_TFCP stPvsF_TFCP blPvsF_TFCP
gammaPowerVals_SF = gammaPowerValsAreaWise{subNumSFAreaWise, 2};
alphaPowerVals_SF = alphaPowerValsAreaWise{subNumAlphaAreaWise, 2};
tfPlot_SF = tfPower_sfAreaWise{subNumTF_SFAreaWise, 2};
stPvsF_SF = stPowerVsFreq_SFAreaWise{subNumST_SFAreaWise, 2};
blPvsF_SF = blPowerVsFreq_SFAreaWise{subNumBL_SFAreaWise, 2};
dPowerSF_Ori_Topo = diffPowerSF_Ori_Topo{subNumTopo, 2};
gammaPowerValsSubAreaWiseNoMS = gammaPowerValsAreaWiseNoMS{subNumSFNoMSAreaWise, 2};
alphaPowerValsSubAreaWiseNoMS = alphaPowerValsAreaWiseNoMS{subNumSFAlphaNoMSAreaWise, 2};
gammaPowerValsAreaWiseSubNarrowerBand = gammaPowerValsAreaWiseNarrowerBand{subNumGPNarBand, 2};

gammaPowerVals_TFCP = gammaPowerValsAreaWise_TFCP{subNumGamma_TFCP, 2};
alphaPowerVals_TFCP = alphaPowerValsAreaWise_TFCP{subNumAlpha_TFCP, 2};
stPvsF_TFCP = stPowerVsFreq_TFCPGamma_AreaWise{subNumGamma_TFCP_stPvsF, 2};
blPvsF_TFCP = blPowerVsFreq_TFCPGamma_AreaWise{subNumGamma_TFCP_blPvsF, 2};


%%{
% For unipolar scheme
clear subNumBL_SFAreaWise_unipolar subNumAllProtocolsBLData_SF_unipolar 
subNumBL_SFAreaWise_unipolar = strcmpi(blPowerVsFreq_SFAreaWiseUnipolar(:,1),subNames{1});
subNumAllProtocolsBLData_SF_unipolar = strcmpi(allProtocolsBLData(:,1),subNames{1});

clear blPvsF_SF_unipolar allProtocolsBLData_SF_unipolar
blPvsF_SF_unipolar = blPowerVsFreq_SFAreaWiseUnipolar{subNumBL_SFAreaWise_unipolar, 2};
allProtocolsBLData_SF_unipolar = allProtocolsBLData{subNumAllProtocolsBLData_SF_unipolar, 2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get demographics and diagnlsis
subNumSFInDemDetails = strcmpi(demographicDetails(:,nameCol),demName); 
subNumSFInClnDetails = strcmpi(clinicalDetails(:,nameClinicalDetailsCol),demName); 

% Age and gender
ageSub = str2num(demographicDetails{subNumSFInDemDetails,ageCol}(1:end-1)); %#ok<ST2NM>
if strcmpi(demographicDetails{subNumSFInDemDetails,sexCol},'M'); sexSub = 1; 
elseif strcmpi(demographicDetails{subNumSFInDemDetails,sexCol},'F'); sexSub = 2; 
end;        

% Original diagnosis
labelSub = demographicDetails{subNumSFInDemDetails,labelCol};
switch labelSub
    case 'HV'; labelNumSub = 0;
    case 'MCI'; labelNumSub = 0.5;
    case 'AD'; labelNumSub = 1;
end

% Consensus diagnosis
consensusLabelSub = demographicDetails{subNumSFInDemDetails,consensusLabelCol};
switch consensusLabelSub
    case 'HV'; consensusLabelNumSub = 0;
    case 'MCI'; consensusLabelNumSub = 0.5;
    case 'AD'; consensusLabelNumSub = 1;
end
