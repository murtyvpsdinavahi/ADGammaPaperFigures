
% Function to create and show statistics of all the figures described in
% results section of Murty et al., medRxiv, 2020.
% Inputs:   figureName (described below)
%           saveFigFlag: 0/1: don't save/save figure
%           saveTFFlag: 1: paste TF and scalp plots as images in figures to
%           facilitate saving as .svg. Set this to 0 to adjust caxis.
%
% figureName: enter the following strings to generate the respective figures
% Fig2:             Figure 2
% Fig3:             Figure 3
% Fig4:             Figure 4
% SupFig1-MCI:      Supplementary Figure 1: panel A and MCI section (left column) of panel C (option will be prompted if only SupFig1 is entered as input).
% SupFig1-AD:       Supplementary Figure 1: panel B and AD section (right column) of panel C (option will be prompted if only SupFig1 is entered as input).
% SupFig2-PanelA:   Supplementary Figure 2: panel A (option will be prompted if only SupFig2 is entered as input).
% SupFig2-PanelB:   Supplementary Figure 2: panel B (option will be prompted if only SupFig2 is entered as input).
% SupFig3:          Supplementary Figure 3
% SupFig4:          Supplementary Figure 4
% SupFig5:          Supplementary Figure 5
%
% Some other options can also be entered for supplementary analysis:
% Fig2-remove92yAD:         to redo analysis for Figure 2 after removing A1 (92 year old male AD with no healthy control subject).
% Fig2-NarrowerBand:        to redo analysis taking narrower bands of slow gamma: [24 30] and fast gamma: [40 48] Hz.
% Fig2-NarrowerBand-MCI:    narrower bands for MCI
% Fig2-NarrowerBand-AD:     narrower bands for AD
%
% To get trial and other statistics mentioned in  methods, run
% getTrialStats.m
%
% Murty V P S Dinavahi: 21-07-2020
%

function createFigure(figureName,saveFigFlag,saveTFFlag)

    % Defaults
    if ~exist('saveFigFlag','var') || isempty(saveFigFlag); saveFigFlag = 1; end;
    if ~exist('saveFlag','var') || isempty(saveTFFlag); saveTFFlag = 1; end; saveFlag = saveTFFlag; % To match further codes
    folderSourceString = 'H:'; finalPlotsSaveFolder = fullfile(folderSourceString,'Plots','ADPaper','Analysis','Latest');
    colormapName = 'magma'; %#ok<*NASGU>
    ageLim = 1; % in years
    remove92yAD = 0;
    PSDSigFlag = 1; 
    SSVEPFlag = 0; 
    NarrowerBandFlag = 0; 
    psdFlag = 1; % Plot PSDs
    tfFlag=1; % Plot PSDs
    consistentMCISubsFlag = 0; % include only those subjects who have been MCI in year 0 and 1   

    % Load data
    if strcmpi(figureName,'Fig4') || strcmpi(figureName,'SupFig5')
        load(fullfile(finalPlotsSaveFolder,'ssvepAnalysis_GoodSubs.mat'));
    else
        load(fullfile(finalPlotsSaveFolder,'gammaAnalysis_GoodSubs.mat'));
    end

    % Check inputs
    if strcmpi(figureName,'Fig1'); disp('Figure 1 is a methods figure. It has been made directly in inkscape.'); return; end;
    if strcmpi(figureName,'SupFig1') || strcmpi(figureName,'SupFig2') 
        switch figureName
            case 'SupFig1'; inpStr = 'input figureName; options: SupFig1-MCI | SupFig1-AD : ';
            case 'SupFig2'; inpStr = 'input figureName; options: SupFig2-PanelA | SupFig2-PanelB : ';
        end
        figureName = input(inpStr,'s'); createFigure(figureName,saveFigFlag,saveTFFlag); 
        return;
    end
    
    % Plot    
    if strncmpi(figureName,'Fig2',4)
        subsGroup = 1; % 1: MCI+AD, 2: MCI, 3: AD
        ssvepSubsFlag = 0; % include only those subjects who have SSVEP data        

        switch figureName
            case 'Fig2-remove92yAD'; remove92yAD = 1; 
            case 'Fig2-NarrowerBand'; NarrowerBandFlag = 1; 
            case 'Fig2-NarrowerBand-MCI'; NarrowerBandFlag = 1; subsGroup = 2;
            case 'Fig2-NarrowerBand-AD'; NarrowerBandFlag = 1; subsGroup = 3;
        end
        Gamma_GroupAnalysis_Figure;

    elseif strcmpi(figureName,'Fig3') || strcmpi(figureName,'SupFig2-PanelA') || strcmpi(figureName,'SupFig2-PanelB') ||...
            strcmpi(figureName,'SupFig3') || strcmpi(figureName,'SupFig5')
        switch figureName
            case 'Fig3';           noNegPowFlag = 0; ssvepSubsFlag = 0; newDVListFlag = 0; Gamma_IndividualAnalysis_Figure;
            case 'SupFig2-PanelA'; noNegPowFlag = 1; ssvepSubsFlag = 0; newDVListFlag = 0; Gamma_IndividualAnalysis_Figure; saveStr = 'SupFig2-PanelA'; 
            case 'SupFig2-PanelB'; noNegPowFlag = 0; ssvepSubsFlag = 0; newDVListFlag = 1; Gamma_IndividualAnalysis_Figure; saveStr = 'SupFig2-PanelB'; 
            case 'SupFig3';        noNegPowFlag=0; EyeData_Figure; % ssvepSubsFlag = 0 and newDVListFlag = 0 by default
                [dvSubAges,dvSubGenders,subNums,controlSubsInds] = getDVAndControlSubs_EyeData(allAge,allSex,allCDR,remove92yAD); %#ok<ASGLU>
                saveStr = 'SupFig3'; 
            case 'SupFig5';        noNegPowFlag = 0; ssvepSubsFlag = 1; Gamma_SSVEPSubjects_Figure; % newDVListFlag = 0 by default                
                controlSubsInds = true(size(allCDR)); 
                saveStr = 'SupFig5'; 
        end
        Gamma_IndividualAnalysis_scatter;
        
    elseif strcmpi(figureName,'Fig3-lesserControls'); noNegPowFlag = 0; ssvepSubsFlag = 0; newDVListFlag = 0; Gamma_IndividualAnalysis_Figure;
        close(figR); saveFigFlag = 0;
        Gamma_IndividualAnalysis_scatter_lessControls; saveStr = [saveStr '_lesserControls']; %#ok<NODEF>

    elseif strcmpi(figureName,'Fig4'); SSVEP_Figure; saveStr = 'Figure4'; 
    elseif strcmpi(figureName,'SupFig1-MCI');   clnLbl=0.5; newDVListFlag = 0; Gamma_Individuals_Figure; saveStr = 'SupFig1-MCI'; 
    elseif strcmpi(figureName,'SupFig1-AD');    clnLbl=1; newDVListFlag = 0; Gamma_Individuals_Figure; saveStr = 'SupFig1-AD'; 
    elseif strcmpi(figureName,'SupFig4'); noNegPowFlag = 0; iRef = 2; Slopes_Figure; saveStr = 'SupFig4'; 
    end

    % Save figures
    if saveFigFlag==1 && ~strcmpi(figureName,'Fig1')
        savefig(figR,fullfile(finalPlotsSaveFolder,[saveStr '.fig']));
%         print(figR,fullfile(finalPlotsSaveFolder,saveStr),'-dsvg','-r600');
    end
end

function [dvSubAges,dvSubGenders,subNums,controlSubsInds] = getDVAndControlSubs_EyeData(allAge,allSex,allCDR,remove92yAD)
    dvSubAges = allAge(allCDR>0);
    dvSubGenders = allSex(allCDR>0);
    subNums = find(allCDR>0);
    if remove92yAD
        dvSubGenders(dvSubAges==92)=[];
        dvSubAges(dvSubAges==92)=[];
    end
    controlSubsInds = true(size(allCDR));
end
