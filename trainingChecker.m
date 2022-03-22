function trainingChecker()
    %script to check whether training documentation is complete for monkey
    %staff. This script is expected to run weekly, and will send a reminder
    %to Lee and the script maintainer so they can prod people to update the
    %documents certifying that they have been trained.
    
    testing=0;
    
    try%try/catch to email maintainer if error occurs
        
        [~,contactsFile]=getMonkeyDataLocation();
        %get monkey staff data:
        adminContacts=readtable(contactsFile,'FileType','spreadsheet','sheet','admin','Basic',1);
        xlsData=readtable(contactsFile,'FileType','spreadsheet','sheet','monkeyTeam','Basic',1);
        %convert datetimes into datenums if needed:
        xlsData.TrainingDocumentedDate=datenum(datetime(xlsData.TrainingDocumentedDate,'ConvertFrom','excel'));
        %set contacts for the checker
        if testing
            recipients=adminContacts.maintainer;
        else
            recipients={adminContacts.PI,...
                        adminContacts.maintainer,...
                        adminContacts.trainingCzar};
        end
        %loop through staff checking whether there is an entry for the
        %training:
        for personIdx=1:size(xlsData,1)
            disp(['working on: ',xlsData.shortName{personIdx}])
            if isnan(xlsData.TrainingDocumentedDate(personIdx))
                disp([xlsData.shortName{personIdx} ' has no training date!'])
                %we need to issue a warning
                subject=['REMINDER: ',xlsData.shortName{personIdx},' has no training record'];
                if testing
                    subject=['(testing) ',subject];
                end
                message={['there is no training record date entered for: ',xlsData.fullName{personIdx}],...
                        ['Please contact ',xlsData.shortName{personIdx},' and the lab training czar to update the training record']...
                        ' ',...
                        'This message is automatically generated from the information in:',...
                        contactsFile,...
                        'This system will send repeat warnings every 7 days until the file is updated with a completion date',...
                        ' ',...
                        ['For tech support on this checker, contact: ',adminContacts.maintainer{1}]};
                send_mail_message(recipients,subject,message)
            end
        end
        
    catch ME
        sendCrashEmail(adminContacts.maintainer,ME,'training checker')
    end
end