
clear cdrCatAllSubs; 
switch iCl
    case 1; clnLbl = 0.5; clnText = 'MCI';
    case 2; clnLbl = 1; clnText = 'AD';
end

dvSubAges = allAge(allCDR==clnLbl);
dvSubGenders = allSex(allCDR==clnLbl);

clear controlSubsAll disSubsAll; controlSubsAll = []; disSubsAll = [];
for iCA = 1:length(dvSubAges)

    disSubs = ismember(allAge,dvSubAges(iCA)) & ismember(allSex,dvSubGenders(iCA)) & allCDR==clnLbl;
    disSubsAll = cat(2,disSubsAll,find(disSubs));

    controlSubs = ismember(allAge,unique([dvSubAges(iCA)-ageLim dvSubAges(iCA) dvSubAges(iCA)+ageLim])) & ismember(allSex,dvSubGenders(iCA)) & allCDR==0;
    controlSubsAll = cat(2,controlSubsAll,find(controlSubs));

end
disSubsAll = unique(disSubsAll);
controlSubsAll = unique(controlSubsAll);