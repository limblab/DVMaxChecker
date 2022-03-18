function TBChecker()
    %script to check whether all the people on the monkey team have current
    %TB tests. This script is expected to run daily, and will send a
    %reminder to get re-tested a month ahead of time, followed by warnings
    %1 week ahead of time.  This script relies on accurate information in
    %the contacts.xls file on fsmresfiles foudn here:
    %fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\lab_folder\General-Lab-Stuff\checkerData\contacts.xls
    
    testing=0;
    [~,contactListLocation]=getMonkeyDataLocation();
    adminContacts = readtable(contactListLocation,'FileType','spreadsheet','sheet','admin');
    
    try%try/catch to email maintainer if error occurs

        %check monkey staff TB dates:
        xlsData=readtable(contactListLocation,'FileType','spreadsheet','sheet','monkeyTeam');
        %convert excel datenums into matlab datenums:
        xlsData.TBDate=datenum(datetime(xlsData.TBDate,'ConvertFrom','excel'));
        for personIdx=1:size(xlsData,1)
            if testing
                recipients=adminContacts.maintainer(1);
            else
                recipients={adminContacts.TBCzar(1),...
                            adminContacts.PI(1),...
                            xlsData.contactEmail(personIdx)};
            end
            if isnan(xlsData.TBDate(personIdx))
                %request a TB date:
                subject=['Warning: no TB test date for: ',xlsData.shortName{personIdx}];
                message={['there is no TB test date for: ',xlsData.fullName{personIdx}],...
                        ['Please go to: ',contactListLocation,'and add a current TB test date'],...
                        'This message is automatically generated from the information in:',...
                        contactListLocation,...
                        ' ',...
                        ['For tech support on this checker, contact: ',adminContacts.maintainer{1}]};
                if testing
                    send_mail_message(d,['(testing)',subject],message)
                else
                    send_mail_message(recipients,subject,message)
                end
            elseif xlsData.TBDate(personIdx)+365<=datenum(date)+7
                %we need to issue a warning
                subject=['WARNING! ',xlsData.shortName{personIdx},' TB test expiration'];
                message={['the TB test for: ',xlsData.fullName{personIdx},' expires on',datestr(xlsData.TBDate(personIdx)+365)],...
                        'Please schedule your renewal test now',...
                        'This message is automatically generated from the information in:',...
                        contactListLocation,...
                        'This system will send no further warnings',...
                        ' ',...
                        ['For tech support on this checker, contact: ',adminContacts.maintainer{1}]};
                if testing
                    send_mail_message(recipients,['(testing)',subject],message)
                else
                    send_mail_message(recipients,subject,message)
                end
            elseif xlsData.TBDate(personIdx)+365==datenum(date)+30 
                %we need to issue a reminder
                subject=[xlsData.shortName{personIdx},' TB test expiration reminder'];
                message={['the TB test for: ',xlsData.fullName{personIdx},' will expire in 30 days'],...
                        'Please schedule your renewal test now',...
                        'This message is automatically generated from the information in:',...
                        contactListLocation,...
                        'This system will send no further reminders',...
                        ' ',...
                        ['For tech support on this checker, contact: ',adminContacts.maintainer{1}]};
                if testing
                    send_mail_message(recipients,['(testing)',subject],message)
                else
                    send_mail_message(recipients,subject,message)
                end
            end
        end
        %check monkey collaborator TB dates:
        xlsData=readtable(contactListLocation,'FileType','spreadsheet','sheet','monkeyCollaborators');
        %convert excel datenums into matlab datenums:
        xlsData.TBDate=datenum(datetime(xlsData.TBDate,'ConvertFrom','excel'));
        for personIdx=1:size(xlsData,1)
            if testing
                recipients=adminContacts.maintainer(1);
            else
                recipients={adminContacts.TBCzar(1),...
                            adminContacts.PI(1)};
            end
            if isnan(xlsData.TBDate(personIdx))
                %request a TB date:
                subject=['Warning: no TB test date for: ',xlsData.shortName{personIdx}];
                message={['there is no TB test date for: ',xlsData.fullName{personIdx}],...
                        ['Please go to: ',contactListLocation,'and add a current TB test date'],...
                        'This message is automatically generated from the information in:',...
                        contactListLocation,...
                        ' ',...
                        ['For tech support on this checker, contact: ',adminContacts.maintainer{1}]};
                if testing
                    send_mail_message(recipients,['(testing)',subject],message)
                else
                    send_mail_message(recipients,subject,message)
                end
            elseif xlsData.TBDate(personIdx)+365==datenum(date)+7
                %we need to issue a warning
                subject=['WARNING! ',xlsData.fullName{personIdx},' TB test expiration'];
                message={['the TB test for: ',xlsData.fullName{personIdx},' will expire in 7 days'],...
                        [xlsData.fullName(personIdx),' is listed as a collaborator on monkey projects and should have a current TB test'],...
                        'Please contact them for updated TB test information now',...
                        'This message is automatically generated from the information in:',...
                        contactListLocation,...
                        'This system will send no further warnings',...
                        ' ',...
                        ['For tech support on this checker, contact: ',adminContacts.maintainer{1}]};
                if testing
                    send_mail_message(recipients,['(testing)',subject],message)
                else
                    send_mail_message(recipients,subject,message)
                end
            elseif xlsData.TBDate(personIdx)+365==datenum(date)+30
                %we need to issue a reminder
                subject=[xlsData.fullName{personIdx},' TB test expiration reminder'];
                message={['the TB test for: ',xlsData.fullName{personIdx},' will expire in 30 days'],...
                        [xlsData.fullName(personIdx),' is listed as a collaborator on monkey projects and should have a current TB test'],...
                        'Please contact them for updated TB test information now',...
                        'This message is automatically generated from the information in:',...
                        contactListLocation,...
                        'This system will send no further reminders',...
                        ' ',...
                        ['For tech support on this checker, contact: ',adminContacts.maintainer{1}]};
                if testing
                    send_mail_message(recipients,['(testing)',subject],message)
                else
                    send_mail_message(recipients,subject,message)
                end
            end
        end
    catch ME
        sendCrashEmail(adminContacts.maintainer(1),ME,'TB checker')
    end
end