function trainingChecker()
    %script to check whether training documentation is complete for monkey
    %staff. This script is expected to run weekly, and will send a reminder
    %to Lee and the script maintainer so they can prod people to update the
    %documents certifying that they have been trained.
    
    testing=1;
    %email addresses should be NU emails to comply with FSMIT security
    %policy:
    maintainerEmailAddress='tucker.tomlinson1@northwestern.edu';
    labPIEmailAddress='lm@northwestern.edu';
    labTrainingCzar='stephanienaufel2015@u.northwestern.edu';
    
    if testing
        recipients=maintainerEmailAddress;
    else
        recipients={labPIEmailAddress,...
                    maintainerEmailAddress,...
                    labTrainingCzar};
    end
    
    
    try%try/catch to email maintainer if error occurs
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

        %get monkey staff data:
        xlsData=readtable(fname,'FileType','spreadsheet','sheet','monkeyTeam');
        %loop through staff checking whether there is an entry for the
        %training:
        for personIdx=1:size(xlsData,1)
            disp(['working on: ',xlsData.shortName{personIdx}])
            if isnan(xlsData.TrainingDocumentedDate(1))
                disp('tucker has no training date!')
                %we need to issue a warning
                subject=['REMINDER: ',xlsData.shortName{personIdx},' has no training record'];
                message={['there is no training record date entered for: ',xlsData.fullName{personIdx}],...
                        ['Please contact ',xlsData.shortName{personIdx},' and the lab training czar to update the training record']...
                        ' ',...
                        'This message is automatically generated from the information in:',...
                        fname,...
                        'This system will send repeat warnings every 7 days until the file is updated with a completion date',...
                        ' ',...
                        ['For tech support on this checker, contact: ',maintainerEmailAddress]};
                send_mail_message(recipients,subject,message)
            end
        end
        
    catch ME
        sendCrashEmail(maintainerEmailAddress,ME,'training checker')
    end
end