
clear controlSubsAll disSubsAll; controlSubsAll = []; disSubsAll = [];

clear iSubX
noDataSubs = find(isnan(allAlphaPower)); % Important only for no MS trials

disp('Calculating Wilcoxon signed-rank test');
disp(['after randomly chosing one control for each of ' num2str(sum(dvSubAges~=92))]); % Removing 92 year old male AD as he has no control subject
disp('cases, over 10,000 iterations...');
for iG=1:3
    switch iG
        case 1; allGP = allAlphaPower; ttlStr = 'Alpha';
        case 2; allGP = allSGPower; ttlStr = 'Slow gamma';
        case 3; allGP = allFGPower; ttlStr = 'Fast gamma';
    end
    
    for iD=1:10000
        clear sgDis sgCon
        sgDis = []; sgCon = [];
        for iSubX = 1:length(dvSubAges)
            disSubsAll = subNums(iSubX);
            if ismember(disSubsAll,noDataSubs); continue; end; % Important only for no MS trials
            
            controlSubs = ismember(allAge,unique([dvSubAges(iSubX)-ageLim dvSubAges(iSubX) dvSubAges(iSubX)+ageLim])) & ismember(allSex,dvSubGenders(iSubX)) & allCDR==0;
            controlSubsAll = setdiff(find(controlSubs),noDataSubs);
            
            if isempty(controlSubsAll); continue; end;
            medGDis = median(allGP(disSubsAll));            
            
            controlSubsResampled = datasample(controlSubsAll,1);
            medGCon = median(allGP(controlSubsResampled));            
            
            sgDis(end+1) = medGDis;
            sgCon(end+1) = medGCon;
        end
        
        medDiff(iD,iG) = median(sgDis-sgCon);       
        
        % signrank test
        pSR_singCon(iD,iG) = signrank(sgDis',sgCon','tail','left','method','approximate'); %#ok<*SAGROW>
    end
    
    xpm(iG) = median(squeeze(pSR_singCon(:,iG)));
    xps(iG) = std(squeeze(pSR_singCon(:,iG)));
    
    disp(ttlStr);
    disp(['median difference of power between cases and controls over 10,000 iterations: ' num2str(median(medDiff(:,iG)))]);
    disp(['p-values over 10,000 iterations: p=' num2str(xpm(iG)) ' +/- ' num2str(xps(iG))]);

end

