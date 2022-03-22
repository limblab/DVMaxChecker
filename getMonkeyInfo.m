function [peopleList,animalList,todayIsAHoliday,weekendWaterList,weekendFoodList]=getMonkeyInfo()
    %utility function for checker scripts. Wraps up all the excel file 
    %access to get monkey restriction/contact info in one place for all
    %checker scripts
    [MonkeyWaterLocation,contactListLocation]=getMonkeyDataLocation();
    peopleList = readtable(contactListLocation,'FileType','spreadsheet','sheet','monkeyTeam','Basic',1);
    animalList = loadMonkeyContacts(MonkeyWaterLocation,peopleList); 
    [weekendWaterXlsNum,weekendWaterXls,~] = xlsread(MonkeyWaterLocation,3,'','basic'); 
    weekendDates=x2mdate(weekendWaterXlsNum(1:end)); 
    time = clock;
    time = time(4);
    todaysDate = datenum(date);
    todayIsAHoliday = find(todaysDate == weekendDates)+1;%this index is used on the weekendWaterList and weeekendFoodList structures, which truncate only the first index, whereas, weekendDates truncates the first two, thus we add back a single index
    weekendWaterList = weekendWaterXls(2:end,2:end);
    [~,weekendFoodXls,~] = xlsread(MonkeyWaterLocation,4,'','basic'); 
    weekendFoodList = weekendFoodXls(2:end,2:end);
end