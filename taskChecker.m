function taskChecker()
    %script to check whether regular tasks like lab cleaning are completed
    %and logged. This script runs daily, to allow for tasks with due-dates
    %on different days of the week. clidox can be checked on Tu, and lab
    %cleanings on Mon for instance. This checker is intended to run in the
    %morning so that people have a chance to tackle the tasks on the same
    %day that they receive the email. Reminders will be issued in advance
    %based on how often the task is to be completed: weekly tasks will get
    %a reminder the day before. bi-weekly tasks will get a reminder 5 days
    %before, and monthly tasks will get a reminder a week before. All tasks
    %will receive a final warning the morning of the day they are due.
    %
    %For monthly tasks:
    %checker will check against the day of the month: for instance setting
    %the starting data on June5th will cause the checker to check against
    %the 5th of the month every month
    %For yearly tasks:
    %the checker will check against the day of the year, e.g. may 3rd every
    %year
    
    testing=1;
    alphabet=char(65:90);
    boilerplate={' ',...
                'this message was generated automatically by the taskChecker script',...
                ['for tech support, contact: ',adminContacts.maintainer{1}]};
    try
        %get the filenames for the current host system:
        if ispc
            taskFile='\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\lab_folder\General-Lab-Stuff\checkerData\JobChecker.xls';
            contacts = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\lab_folder\General-Lab-Stuff\checkerData\contacts.xls';
        elseif isunix 
            [~,hostname]=unix('hostname');
            if strcmp(strtrim(hostname),'tucker-pc')
                %mount point for fsmresfiles on tucker's computer:
                taskFile='/media/fsmresfiles/limblab/lab_folder/General-Lab-Stuff/checkerData/JobChecker.xls';
                contacts='/media/fsmresfiles/limblab/lab_folder/General-Lab-Stuff/checkerData/contacts.xls';
            end
            %get the java xls write utility files loaded into the matlab path:
            javaaddpath('xlwrite/poi_library/poi-3.8-20120326.jar');
            javaaddpath('xlwrite/poi_library/poi-ooxml-3.8-20120326.jar');
            javaaddpath('xlwrite/poi_library/poi-ooxml-schemas-3.8-20120326.jar');
            javaaddpath('xlwrite/poi_library/xmlbeans-2.3.0.jar');
            javaaddpath('xlwrite/poi_library/dom4j-1.6.1.jar');
            javaaddpath('xlwrite/poi_library/stax-api-1.0.1.jar');
        else
            error('TB_checker:systemNotRecognized','This script only configured to run on PC workstations or Tuckers linux computer if you are using a mac or other linux pc you will need to modify the script')
        end
        
        
        
        %load up our contact info:
        adminContacts=readtable(contactsFile,'FileType','spreadsheet','sheet','admin');
        taskContacts=readtable(contactsFile,'FileType','spreadsheet','sheet','monkeyTeam');
        %load up our task data:
        taskSheet=readtable(taskFile,'FileType','spreadsheet','sheet','Jobs');
        %convert excel dates to matlab dates:
        taskSheet.dateDue=datenum(datetime(taskSheet.dateDue,'ConvertFrom','excel'));
        
        %now loop through the tasks
        updatedJobsSheet=false;
        for i=1:size(taskSheet,1)
            %find the contact for this task in the taskContacts table:
            primaryContact='';
            for j=1:size(taskContacts,1)
                if strcmp(taskSheet.responsiblePerson,taskContacts.shortName(j))
                    primaryContact=taskContacts.contactEmail{j};
                elseif strcmp(taskSheet.backupPerson,taskContacts.shortName(j))
                    secondaryContact=taskContacts.contactEmail{j};
                end
            end 
            if isempty(primaryContact) || ismepty(secondaryContact)
                %we have incomplete responsibility listing for the task:
                %send a warning to the admin recipients:
                subject=['task checker: ',taskSheet.Task{i}, ' does not have 2 responsible people'];
                message=[{[taskSheet.Task(i),' does not have 2 people assigned responsibility'],...
                            'all tasks mus have 2 responsible people assigned',...
                            'please update the JobChecker.xls file to have 2 names',...
                            ' ',...
                            'note that this error can occur if one or more of the names does not match valid contact info in the contacts.xls file'},...
                            boilerplate];
                send_mail_message([adminContacts.maintainer{1},',',adminContacts.PI{1}],subject,message,[]);
            end
            % get the interval for this task and set the minimum completion
            % time, the warning lead-time, and the offset for updating to
            % a new due-date
            dueDayNum=datenum(datetime(taskSheet.dateDue(i),'ConvertFrom','excel'));
            dueDay=datevec(dueDayNum);
            switch taskSheet.frequency{i}
                case 'daily'
                    earliestTime=0;
                    leadTime=0;
                    offset=1;
                case 'weekly'
                    earliestTime=3;
                    leadTime=2;
                    offset=7;
                case 'bi-weekly'
                    earliestTime=6;
                    leadTime=5;
                    offset=14;
                case 'monthly'
                    earliestTime=10;
                    leadTime=7;
                    tmp=dueDay;
                    tmp(2)=mod(tmp(2)+1,12);
                    offset=datenum(tmp)-datenum(dueDay);
                case 'yearly'
                    earliestTime=60;
                    leadTime=30;
                    tmp=dueDay;
                    tmp(1)=tmp(1)+1;
                    offset=datenum(tmp)-datenum(dueDay);
                otherwise
                    error('taskChecker:badFrequency',['frequency must be one of: daily, weekly, bi-weekly, monthly, or yearly. The spec: ', taskSheet.frequency{i},' is not recognized'])
            end
            %add leadTime if the due date happens to be on a weekend:
            if weekday(dueDay)==1
                %this due day is sunday, shift our leadtime by 2 to
                %compensate:
                leadTime=leadTime+2;
            elseif weekday(dueDay)==7
                %this due day is saturday, shift our leadtime by 1 to
                %compensate:
                leadTime=leadTime+1;
            end
            
           %now see if we have anything to do today:
            if ~isnan(taskSheet.dateCompleted(i))%we have a date entered for this task
                completionDate=datenum(datetime(taskSheet.dateCompleted,'ConvertFrom','excel'));
                % check that the entered date is before today:
                if date<completionDate;
                        %remove the entry and email a warning
                        subject=['task checker: bad completion date!',taskSheet.Task{i},'has a future date'];
                        message=[{['there is an entry for ',taskSheet.Task(i),' showing the task was completed on: ',num2str( completionDate)],...
                                    'since this day has not heppened yet this is impossible',...
                                    'please re-edit the sheet with the correct date of completion'},...
                                    boileerplate];
                        if testing    
                            send_mail_message(adminContacts.maintainer{1},subject,message,[]);
                        else
                            send_mail_message([primaryContact,secondaryContact],subject,message,[]);
                        end
                        %now clear the early entry
                        taskSheet.dateDue(i)=nan;
                        taskSheet.personCompleting(i)=nan;
                        updatedJobsSheet=true;
                elseif date<dueDayNum%its not the completion date, check for early completions:
                    if date<(dueDayNum-earliestTime)
                        %remove the entry and email a warning
                        subject=['task checker:',taskSheet.Task{i},'early task completion'];
                        message=[{'Tasks should be completed at regular intervals',...
                                    'completing a task too early can effectively generate a gap in completions',...
                                    ['the ',taskSheet.Task(i),' task was completed: ',num2str(dueDayNum-date),' days early'],...
                                    'If you want to reset the interval of checking you should alter the dueDay and due day in the JobChecker.xls file',...
                                    ['so that today falls within ',num2str(earliestTime),' of the due date']},...
                                    boilerplate];
                        if testing    
                            send_mail_message(adminContacts.maintainer{1},subject,message,[]);
                        else
                            send_mail_message([primaryContact,secondaryContact],subject,message,[]);
                        end
                        %now clear the early entry
                        taskSheet.dateDue(i)=nan;
                        taskSheet.personCompleting(i)='';
                        updatedJobsSheet=true;
                        
                    end
                else %if its the completion date
                    %move the completion info to the log tab, and reset the
                    %due date:
                    
                    %load the logging tab for this task:
                    jobName=taskSheet.Task{i};
                    jobName(jobName==' ')=[];
                    jobHistory=readtable(taskFile,'FileType','spreadsheet','sheet',jobName,'ReadVariableNames',false);
                    %write a line at the end of the tab with the data
                    %currently in the Jobs page
                    if isunix
                        xlwrite(taskFile,taskSheet,jobName,['A',num2str(size(jobHistory,1)+1)])%add 1 to line number to append a row below existing data, starting in column A
                    else
                        xlswrite(taskFile,taskSheet,jobName,['A',num2str(size(jobHistory,1)+1)])%add 1 to line number to append a row below existing data, starting in column A
                    end
                    %clear the data from the Jobs page:
                    taskSheet.dateCompleted(i)=nan;
                    taskSheet.personCompleting(i)=nan;
                    %update the due date:
                    taskSheet.dateDue(i)=m2xdate(dueDayNum+offset);
                    
                    updatedJobsSheet=true;
                    
                end
            %if we don't have data see about warnings etc:
            elseif date==dueDayNum%if this is the due date issue a warning
                subject=['WARNING: ', taskSheet.Task{i},' is due TODAY'];
                message=[{['this is an automated warning that the recurring task: ',taskSheet.Task(i)],...
                            'is due today, and has not been completed.',...
                            'Please complete this task before the end of the day'},...
                            boilerplate];
                send_mail_message([adminContacts.maintainer{1},adminContacts.PI{1},primaryContact,secondaryContact],subject,message,[]);
            elseif date>dueDayNum%if the task is overdue
                subject=['TASK OVERDUE!!!: ', taskSheet.Task{i},' was due on: ',datestr(dueDayNum)];
                message=[{['this is an automated reminder that the recurring task: ',taskSheet.Task{i}],...
                            'is overdue. Please complete this task ASAP'},...
                            boilerplate];
                send_mail_message([primaryContact,',',secondaryContact],subject,message,[]);
            elseif date==dueDayNum-leadTime%check to see if we need to issue a reminder
                subject=['REMINDER: ', taskSheet.Task{i},' is due in: ',num2str(leadTime),'days'];
                message=[{['this is an automated reminder that the recurring task: ',taskSheet.Task{i}],...
                            ['will be due on ',datestr(dueDayNum)],...
                            'please make plans to complete this task before the due date'},...
                            boilerplate];
                send_mail_message([primaryContact,',',secondaryContact],subject,message,[]);
            end
            
        end
        
        if updatedJobsSheet
            %write updated jobs to excel file (just overwrite the whole tab):
            if isunix
                xlwrite(taskFile,taskSheet,'Jobs','A2')%RANGE=A2 starts writing the table at cell A2 and fills as needed
            else
                xlswrite(taskFile,taskSheet,'Jobs','A2')%RANGE=A2 starts writing the table at cell A2 and fills as needed
            end
        end
        
    catch ME
        sendCrashEmail(maintainerEmailAddress,ME,'task checker')
    end
        
    
    
end