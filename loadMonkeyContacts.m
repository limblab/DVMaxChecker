function monkeyContactList = loadMonkeyContacts(MonkeyWaterLocation,contactData)    
    %[animal_xls_num,animal_xls,~] = xlsread(MonkeyWaterLocation,1,'','basic');
    animalTable=readtable(MonkeyWaterLocation,'FileType','spreadsheet','sheet','Monkeys','Basic',1);
    %clear out garbage entries:
    animalTable=animalTable(:,cellfun(@isempty,strfind(animalTable.Properties.VariableNames,'Var')));
    primaryTable=[];
    secondaryTable=[];
    for i=1:size(animalTable,1)
        primaryTable=[primaryTable;contactData(strcmp(contactData.shortName,animalTable.personInCharge(i)),:)];
        secondaryTable=[secondaryTable;contactData(strcmp(contactData.shortName,animalTable.secondInCharge(i)),:)];
    end
    for i=1:numel(secondaryTable.Properties.VariableNames)
        secondaryTable.Properties.VariableNames(i)={['secondary',secondaryTable.Properties.VariableNames{i}]};
    end
   
    monkeyContactList=table2struct([animalTable,primaryTable,secondaryTable]);
end