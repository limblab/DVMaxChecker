function MonkeyStatusChecker()

    
    testing=0;
    [~,contactListLocation]=getMonkeyDataLocation();
    adminContacts = readtable(contactListLocation,'FileType','spreadsheet','sheet','admin','Basic',1);
    taskContacts=readtable(contactListLocation,'FileType','spreadsheet','sheet','monkeyTeam','Basic',1);

    
    time = clock;
    time = time(4);
    
    %set up boilerplate for emails:
    boilerplate={' ',...
        'this message was generated automatically by the MonkeyStatus script',...
        ['for tech support, contact: ',adminContacts.maintainer{1}]};
    
    try
        [peopleList,animalList,todayIsAHoliday,weekendWaterList,~]=getMonkeyInfo();
        time = clock;
        time = time(4);
        animalsWhoGotWater = {};

        if ispc
            taskFile='\\fsmresfiles\limblab\lab_folder\General-Lab-Stuff\checkerData\monkeyStatus.xlsx';
        elseif isunix
            [~,hostname]=unix('hostname');
            if strcmp(strtrim(hostname),'tucker-pc')
                taskFile='/media/fsmresfiles/limblab/lab_folder/General-Lab-Stuff/checkerData/monkeyStatus.xlsx';
            elseif strcmp(strtrim(hostname),'Rhea')
                taskFile='/media/fsmresfiles/limblab/lab_folder/General-Lab-Stuff/checkerData/monkeyStatus.xlsx';
            else
                error('taskChecker:unrecognizedSystem',['Did not recognize the system: ', hostname,' and do not know where to find the taskFile path'])
            end
        end
        
        if  isunix 
            %get the java xls write utility files loaded into the matlab path:
            javaaddpath('xlwrite/poi_library/poi-3.8-20120326.jar');
            javaaddpath('xlwrite/poi_library/poi-ooxml-3.8-20120326.jar');
            javaaddpath('xlwrite/poi_library/poi-ooxml-schemas-3.8-20120326.jar');
            javaaddpath('xlwrite/poi_library/xmlbeans-2.3.0.jar');
            javaaddpath('xlwrite/poi_library/dom4j-1.6.1.jar');
            javaaddpath('xlwrite/poi_library/stax-api-1.0.1.jar');
            addpath([pwd,filesep,'xlwrite'])
        end
        
        for iMonkey = 1:length(animalList)
            updated_sheet = 0;
            sent_email = 0;
            disp(['working on monkey: ',animalList(iMonkey).animalName])
            %load up our monkey status data:
            statusSheet=readtable(taskFile,'FileType','spreadsheet','sheet',animalList(iMonkey).animalName,'ReadVariableNames',true,'Basic',1);

            statusSheet.DueDate=datenum(datetime(statusSheet.DueDate,'ConvertFrom','excel'));
            statusSheet.DateCompleted=datenum(datetime(statusSheet.DateCompleted,'ConvertFrom','excel'));

            
            % get primary and secondary person
            
            %find the contact for this task in the taskContacts table:
            primaryContact='';
            secondaryContact='';
            for j=1:size(taskContacts,1)
                if strcmp(animalList(iMonkey).personInCharge,taskContacts.shortName{j})
                    primaryContact=taskContacts.contactEmail(j);
                elseif strcmp(animalList(iMonkey).secondInCharge,taskContacts.shortName{j})
                    secondaryContact=taskContacts.contactEmail(j);
                end
            end 
            if isempty(primaryContact) || isempty(secondaryContact)
                %we have incomplete responsibility listing for the task:
                %send a warning to the admin recipients:
                subject=['monkey status checker: ',animalList(iMonkey).animalName, ' does not have 2 responsible people'];
                message=[{[animalList(iMonkey).animalName,' does not have 2 people assigned responsibility'],...
                            'all monkeys must have 2 responsible people assigned',...
                            'please update the MonkeyWaterData.xls file to have 2 names',...
                            ' ',...
                            'note that this error can occur if one or more of the names does not match valid contact info in the contacts.xls file'},...
                            boilerplate];
                
                if testing
                    send_mail_message(adminContacts.maintainer(1),['(testing) ',subject],message,[]);
                else
                    send_mail_message([adminContacts.maintainer(1),adminContacts.PI(1)],subject,message,[]);
                end
            end
            
            
            % check if the next due date exists
            day_of_week = weekday(today);
            friday_number = 6; % fridays are the 6th day of the week apparently, this is a constant
            
            next_due_date = today + (friday_number - day_of_week);
            
            % find next_due_date in statusSheet (make it otherwise)
            date_row = find(next_due_date == statusSheet.DueDate);
            if(isempty(date_row))
                % make a new row
                statusSheet.DueDate(end+1) = next_due_date;
                date_row = size(statusSheet,1);
            end
            
            % check if filled out columns contains entries          
            if(((iscell(statusSheet.FilledOutBy(date_row)) && numel(statusSheet.FilledOutBy{date_row}) > 0) || ...
                    (~iscell(statusSheet.FilledOutBy(date_row)) && statusSheet.FilledOutBy(date_row) > 0) || ...
                    (~iscell(statusSheet.FilledOutBy(date_row)) && ~isnan(statusSheet.FilledOutBy(date_row)))) && ...
                   ((iscell(statusSheet.DateCompleted(date_row)) && numel(statusSheet.DateCompleted{date_row}) > 0) || ...
                   (~iscell(statusSheet.DateCompleted(date_row)) && ~isnan(statusSheet.DateCompleted(date_row))) || ...
                   (~iscell(statusSheet.DateCompleted(date_row)) && statusSheet.DateCompleted(date_row) > 0)))
               
                % if either column is nan or 0 or an empty string, then
                % has_entry is false, otherwise there is an entry
                has_entry = 1;
                
                % check that entry is before today, otherwise send bad
                % entry date email and delete the FilledOutBy and
                % DateCompleted entries
                if today<statusSheet.DateCompleted(date_row)
                    subject=['monkey status checker: bad completion date!',animalList(iMonkey).animalName,' has a future date'];
                    message=[{['there is an entry for ',animalList(iMonkey).animalName,' showing the monkey status was completed on: ',datestr(statusShee.DateCompleted(date_row))],...
                                'since this day has not heppened yet this is impossible',...
                                'please re-edit the sheet with the correct date of completion'},...
                                boilerplate];

                    if testing    
                        send_mail_message(adminContacts.maintainer{1},['(testing) ',subject],message,[]);
                    else
                        send_mail_message([primaryContact,secondaryContact],subject,message,[]);
                    end
                    %now clear the early entry
                    statusSheet.DateCompleted(date_row)=nan;
                    statusSheet.FilledOutBy(date_row)=nan;
                    updated_sheet=1;
                    sent_email = 1;
                    
                end
            else
                has_entry = 0;
                
            
            end
            
            % if it is Wed. or Thurs. and there is no entry, send warning email
            if((weekday(today) == 4 || weekday(today) == 5) && ~has_entry && ~sent_email)
                subject=['WARNING: Monkey status for ', animalList(iMonkey).animalName,' is due on FRIDAY'];
                message=[{['this is an automated warning to update ', animalList(iMonkey).animalName,'''s monkey status.',...
                            'This is due on Friday, and has not been completed. ',...
                            'Please complete this task before 4pm on Friday']},...
                            {'person responsible:'},...
                            animalList(iMonkey).personInCharge,...
                            {'secondary person:'},...
                            animalList(iMonkey).secondInCharge,...
                            boilerplate];
                if testing
                    send_mail_message(adminContacts.maintainer{1},['(testing) ',subject],message,[]);
                else
                    send_mail_message([{'MillerLabWarnings@northwestern.edu'},primaryContact,secondaryContact],subject,message,[]);
                end
            
            % if it is Friday afternoon, send angry email with Lee
            elseif(weekday(today) == 6 && time > 12 && ~has_entry)
                subject=['WARNING: Monkey status for ', animalList(iMonkey).animalName,' is OVERDUE'];
                message=[{['this is an automated warning to update ', animalList(iMonkey).animalName,'''s monkey status.',...
                            'This IS OVERDUE. ',...
                            'Please complete this task ASAP']},...
                            {'person responsible:'},...
                            animalList(iMonkey).personInCharge,...
                            {'secondary person:'},...
                            animalList(iMonkey).secondInCharge,...
                            boilerplate];
                if testing
                    send_mail_message(adminContacts.maintainer{1},['(testing) ',subject],message,[]);
                else
                    send_mail_message([{'MillerLabWarnings@northwestern.edu'},adminContacts.PI(1),primaryContact,secondaryContact],subject,message,[]);
                end
                
            end
            
            
            if(updated_sheet==1)
                %write updated jobs to excel file (just overwrite the whole tab):
                statusSheet.DueDate=m2xdate(statusSheet.DueDate);
                statusSheet.DateCompleted=m2xdate(statusSheet.DateCompleted);
                %the following line was necessary in mautlab 2015a, but is not
                %necessary in 2016a
                %taskSheet.dateCompleted=m2xdate(taskSheet.dateCompleted);
                if isunix
                    xlwrite(taskFile,table2cell(statusSheet),animalList(iMonkey).animalName,'A2');%RANGE=A2 starts writing the table at cell A2 and fills as needed
                else
                    xlswrite(taskFile,table2cell(statusSheet),animalList(iMonkey).animalName,'A2');%RANGE=A2 starts writing the table at cell A2 and fills as needed
                end
                
            end
            
        end
        
        
        
        disp('Finished checking MonkeyStatus')
        pause(1)
    catch ME
        sendCrashEmail(adminContacts.maintainer(1),ME,'MonkeyStatusChecker')
    end

end