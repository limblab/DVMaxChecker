function TB_checker()
    %script to check whether all the people on the monkey team have current
    %TB tests. This script is expected to run daily, and will send a
    %reminder to get re-tested a month ahead of time, followed by warnings
    %1 week ahead of time.  This script relies on accurate information in
    %the contacts.xls file on fsmresfiles foudn here:
    %fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\lab_folder\General-Lab-Stuff\checkerData\contacts.xls
    
    testing=1;
    maintainerEmailAddress='tuckertomlinson@gmail.com';
    TBCzarEmailAddress='briandekleva2017@u.northwestern.edu';
    labPIEmailAddress='lm@northwestern.edu';

    if ispc
        fname = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\lab_folder\General-Lab-Stuff\checkerData\contacts.xls';
    elseif isunix 
        [~,hostname]=unix('hostname');
        if strcmp(strtrim(hostname),'tucker-pc')
            %mount point for fsmresfiles on tucker's computer:
            fname='/media/fsmresfiles/limblab/lab_folder/General-Lab-Stuff/checkerData/contacts.xls';
        end
    else
        error('TB_checker:systemNotRecognized','This script only configured to run on PC workstations or Tuckers linux computer if you are using a mac or other linux pc you will need to modify the script')
    end
    
    %check monkey staff TB dates:
    xlsData=readtable(fname,'FileType','spreadsheet','sheet','monkeyTeam');
    %convert excel datenums into matlab datenums:
    xlsData.TBDate=datenum(datetime(xlsData.TBDate,'ConvertFrom','excel'));
    for personIdx=1:size(xlsData,1)
        if testing
            recipients=maintainerEmailAddress;
        else
            recipients={TBCzarEmailAddress,...
                        labPIEmailAddress,...
                        xlsData.contactEmail(personIdx)};
        end
        
        if xlsData.TBDate(personIdx)+365==datenum(date)+7
            %we need to issue a warning
            subject=['WARNING! ',xlsData.shortName{personIdx},' TB test expiration'];
            message={['the TB test for: ',xlsData.fullName{personIdx},' will expire in 7 days'],...
                    'Please schedule your renewal test now',...
                    'This message is automatically generated from the information in:',...
                    fname,...
                    'This system will send no further warnings'};
            send_mail_message(recipients,subject,message)
        elseif xlsData.TBDate(personIdx)+365==datenum(date)+30 
            %we need to issue a reminder
            subject=[xlsData.shortName{personIdx},' TB test expiration reminder'];
            message={['the TB test for: ',xlsData.fullName{personIdx},' will expire in 30 days'],...
                    'Please schedule your renewal test now',...
                    'This message is automatically generated from the information in:',...
                    fname,...
                    'This system will send no further reminders'};
            send_mail_message(recipients,subject,message)
        end
    end
    %check monkey collaborator TB dates:
    xlsData=readtable(fname,'FileType','spreadsheet','sheet','monkeyCollaborators');
    %convert excel datenums into matlab datenums:
    xlsData.TBDate=datenum(datetime(xlsData.TBDate,'ConvertFrom','excel'));
    for personIdx=1:size(xlsData,1)
        if testing
            recipients=maintainerEmailAddress;
        else
            recipients={TBCzarEmailAddress,...
                        labPIEmailAddress};
        end
        if xlsData.TBDate(personIdx)+365==datenum(date)+7
            %we need to issue a warning
            subject=['WARNING! ',xlsData.fullName{personIdx},' TB test expiration'];
            message={['the TB test for: ',xlsData.fullName{personIdx},' will expire in 7 days'],...
                    [xlsData.fullName(personIdx),' is listed as a collaborator on monkey projects and should have a current TB test'],...
                    'Please contact them for updated TB test information now',...
                    'This message is automatically generated from the information in:',...
                    fname,...
                    'This system will send no further warnings'};
            send_mail_message(recipients,subject,message)
        elseif xlsData.TBDate(personIdx)+365==datenum(date)+30
            %we need to issue a reminder
            subject=[xlsData.fullName{personIdx},' TB test expiration reminder'];
            message={['the TB test for: ',xlsData.fullName{personIdx},' will expire in 30 days'],...
                    [xlsData.fullName(personIdx),' is listed as a collaborator on monkey projects and should have a current TB test'],...
                    'Please contact them for updated TB test information now',...
                    'This message is automatically generated from the information in:',...
                    fname,...
                    'This system will send no further reminders'};
            send_mail_message(recipients,subject,message)
        end
    end
end