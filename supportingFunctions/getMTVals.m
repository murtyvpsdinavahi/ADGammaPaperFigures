function [diffPvsFAllSubsAreaWise,timeValsTF,freqValsTF,tfDataAllSubsAreaWise,SF_TopoDataAllSubs,blPvsFSubAllElecs,freqVals,...
    bandPowerAllElecs,gammaValsFromDiffPower,slopeAllSubsAllElecs] = getMTVals(stPvsF_SF,blPvsF_SF,tfPlot_SF,blRange,...
    dPowerSF_Ori_Topo,bipInds31To64,blPvsF_SF_unipolar,alphaCheckRange,gamma1CheckRange,gamma2CheckRange,...
    computeSlopesAtFreqs,freqsToAvoid)

    diffPvsFAllSubsAreaWise = 10.*log10(mean(stPvsF_SF{1},1)./mean(blPvsF_SF{1},1));

    timeValsTF = tfPlot_SF{1,2};
    freqValsTF = tfPlot_SF{1,3};
    blPosTF = timeValsTF>=blRange(1) & timeValsTF<=blRange(2);
    tfPowerAreaWise = squeeze(mean(tfPlot_SF{1,1},1));
    blAreaWise = repmat(squeeze(mean(tfPowerAreaWise(blPosTF,:),1)),length(timeValsTF),1);
    tfDataAllSubsAreaWise = 10.*log10(tfPowerAreaWise./blAreaWise);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SF_TopoDataAllSubs = NaN(112,3);
    for iG = 1:3 %1=SG, 2=FG, 3=Alpha
        if length(dPowerSF_Ori_Topo{1})==50 % actiCap31Posterior
            SF_TopoDataAllSubs(bipInds31To64,iG) = dPowerSF_Ori_Topo{iG}; % SG
        elseif length(dPowerSF_Ori_Topo{1})==112 % actiCap64
            SF_TopoDataAllSubs(:,iG) = dPowerSF_Ori_Topo{iG};
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    blPvsFSubAllElecs(1,:) = blPvsF_SF_unipolar{1,1};
    blPvsFSubAllElecs(2,:) = mean(blPvsF_SF{1,1});

    freqVals = blPvsF_SF_unipolar{1,2};
    badFreqPos = getBadFreqPos(freqVals); 
    for iRef=1:2
        for iRhythm = 1:4
            switch iRhythm
                case 1; bandFreqRange = alphaCheckRange;
                case 2; bandFreqRange = gamma1CheckRange;
                case 3; bandFreqRange = gamma2CheckRange;
            end
            gammaCheckPos = setdiff(intersect(find(freqVals>=bandFreqRange(1)),find(freqVals<=bandFreqRange(2))),badFreqPos);
            bandPowerAllElecs(iRef,iRhythm) = log10(mean(squeeze(blPvsFSubAllElecs(iRef,gammaCheckPos))));

            if iRef==2 && (iRhythm==2 || iRhythm==3)
                gammaValsFromDiffPower(iRhythm-1,:) = ...
                    mean(10.*log10(mean(stPvsF_SF{1}(:,gammaCheckPos),1)./mean(blPvsF_SF{1}(:,gammaCheckPos),1)),2); % Changed from Age paper: mean across electrodes              
            end
        end

        for iBand = 1:length(computeSlopesAtFreqs)    
            logPVsFSub = squeeze(log10(blPvsFSubAllElecs(iRef,:)));
            clear sOut; [~,~,sOut] = getSlopesPSDBaseline_v2(logPVsFSub,freqVals,computeSlopesAtFreqs(iBand),[],freqsToAvoid);
            slopeAllSubsAllElecs(iRef,iBand) = sOut(1);
        end 
    end
end