function DVMaxWaterChecker()

    
    testing=0;
    [~,contactListLocation]=getMonkeyDataLocation();
    adminContacts = readtable(contactListLocation,'FileType','spreadsheet','sheet','admin','Basic',1);
    try
        [peopleList,animalList,todayIsAHoliday,weekendWaterList,~]=getMonkeyInfo();
        waterCodes = {'EP8500','EP9000','EP2000','AC1091'};
        time = clock;
        time = time(4);
        animalsWhoGotWater = {};

        conn=connectToDVMax();
        
        for iMonkey = 1:length(animalList)
            animalList(iMonkey).animalName;
            cagecardID = strtrim(animalList(iMonkey).cageID);
            cagecardID(strfind(cagecardID,'C')) = [];
        
            data=fetchMonkeyRecord(conn,cagecardID);

            if todayIsAHoliday
                ccmInChargeWater = weekendWaterList{find(strcmpi(weekendWaterList(:,1),['CC' cagecardID])),todayIsAHoliday};
                ccmInChargeWater = strcmpi(ccmInChargeWater,'ccm');
            else
                ccmInChargeWater = 0;
            end
            animalList(iMonkey).restricted = 0;

            if ccmInChargeWater 
                animalsWhoGotWater{end+1} = animalList(iMonkey).animalName;
                disp([animalList(iMonkey).animalName ' was bottled by CCM.'])
                animalList(iMonkey).bottled_by = 'CCM';
            else            
                
                animalList(iMonkey).restricted=isWaterRestricted(data);
                if animalList(iMonkey).restricted
                    lastWaterEntry = [];
                    for iWaterCodes = 1:length(waterCodes)
                        temp = find(strcmpi(waterCodes{iWaterCodes},{data{:,3}}),1,'first');
                        if ~isempty(temp)
                            lastWaterEntry(end+1) = temp; %#ok<AGROW>
                        end      
                    end
                    if ~isempty(lastWaterEntry)
                        lastWaterEntry = min(lastWaterEntry);
                    else
                        lastWaterEntry = [];
                    end
                    if ~isempty(lastWaterEntry)
                        lastWaterEntryDate = data{lastWaterEntry,2};
                        flag=floor(datenum(lastWaterEntryDate)) ~= datenum(date);
                    else
                        flag=true;
                    end
                    if flag                    
                        if time < 18
                            if testing
                                recipients = adminContacts.maintainer(1);
                                subject = '(this is a test) Your monkey has not received water';
                            else
                                recipients = animalList(iMonkey).contactEmail;
                                if ~isempty(animalList(iMonkey).secondInCharge)
                                    recipients = {recipients,animalList(iMonkey).secondarycontactEmail};
                                end
                                subject = 'Your monkey has not received water';
                            end
                            
                            message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not received water as of ' datestr(now) '.'],...
                                'Sent from Matlab!'};
                            message_sent = 0;
                            while (~message_sent)
                                try
                                    send_mail_message(recipients,subject,message)                
                                    message_sent = 1;  
                                catch
                                    message_sent
                                    pause(5)
                                end
                            end
                            disp(['Warning: ' animalList(iMonkey).animalName ' has not received water today.'])
                        else %if time < 21

                            for iP = 1:size(peopleList,1)
                                if strcmpi(animalList(iMonkey).personInCharge,peopleList.shortName{iP})
                                    personInCharge = iP;
                                    break;
                                end
                            end
                            secondInCharge = [];
                            for iP = 1:size(peopleList,1)
                                if strcmpi(animalList(iMonkey).secondInCharge,peopleList.shortName{iP})
                                    secondInCharge = iP;
                                    break;
                                end
                            end

                            if testing
                                recipients = adminContacts.maintainer(1);
                                subject = ['(this is a test) Last warning: ' animalList(iMonkey).animalName ' has not received  water!'];
                            else
                                recipients = peopleList.contactEmail;       
                                subject = ['Last warning: ' animalList(iMonkey).animalName ' has not received water!'];
                            end    

                            if ~isempty(secondInCharge)
                                message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not received water as of ' datestr(now) '.'],...
                                    ['Person in charge: ' peopleList.fullName{personInCharge} '(' peopleList.contactNumber{personInCharge} ')'],...
                                    ['Second in charge: ' peopleList.fullName{secondInCharge} '(' peopleList.contactNumber{secondInCharge} ')'],...
                                    'Sent from Matlab!'};
                            else
                                message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not received water as of ' datestr(now) '.'],...
                                    ['Person in charge: ' peopleList.fullName{personInCharge} '(' peopleList.contactNumber{personInCharge} ')'],...                
                                    'Sent from Matlab!'};
                            end    
                            message_sent = 0;
                            while (~message_sent)
                                try
                                    send_mail_message(recipients,subject,message)
                                    message_sent = 1;            
                                catch
                                    pause(5)
                                end
                            end
                            disp(['Last warning: ' animalList(iMonkey).animalName ' has not received water today.'])
                        end
                    else
                        animalsWhoGotWater{end+1} = animalList(iMonkey).animalName;
                        disp([animalList(iMonkey).animalName ' received water today.'])
                        animalList(iMonkey).bottled_by = 'lab';
                    end
                else    %% free water monkey
                    animalsWhoGotWater{end+1} = animalList(iMonkey).animalName;
                    disp([animalList(iMonkey).animalName ' is on free water.'])
                    animalList(iMonkey).bottled_by = 'free water';
                end       
            end

        end %end of main checker loop

        if time >= 18 %&& time < 23
            if length(animalsWhoGotWater)==length(animalList) 
                recipients = {};
                if testing
                    recipients = adminContacts.maintainer(1);
                    subject = ['(this is a test) All monkeys received water'];
                    message = {'The following monkeys received water today:'};
                    for iMonkey = 1:length(animalList)
                        message = {message{:},[animalList(iMonkey).animalName ' -      water: ' animalList(iMonkey).bottled_by ]};
                    end 
                    message = {message{:},'Sent from Matlab! This is a test.'};
                    send_mail_message(recipients,subject,message)
                else
                    for iP = 1:size(peopleList,1)
                        recipients = {recipients{:} peopleList.contactEmail{iP}};
                    end
                    subject = ['All monkeys received water'];
                    message = {'The following monkeys received water today:'};
                    for iMonkey = 1:length(animalList)
                        message = {message{:},[animalList(iMonkey).animalName ' -       water: ' animalList(iMonkey).bottled_by ]};
                    end 
                    message = {message{:},'Sent from Matlab!'};
                        message_sent = 0;
                    while (~message_sent)
%                         try
                            send_mail_message(recipients,subject,message)
                            message_sent = 1;            
%                         catch
%                             pause(5)
%                         end
                    end
                end    
            end
        end
        disp('Finished checking DVMax')
        close(conn)
        pause(10)
    catch ME
        sendCrashEmail(adminContacts.maintainer(1),ME,'DVMaxWaterChecker')
    end

end