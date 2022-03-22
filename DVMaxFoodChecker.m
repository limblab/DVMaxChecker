function DVMaxFoodChecker()

    testing=0;
    [~,contactListLocation]=getMonkeyDataLocation();
    adminContacts = readtable(contactListLocation,'FileType','spreadsheet','sheet','admin','Basic',1);
    try
        [peopleList,animalList,todayIsAHoliday,~,weekendFoodList]=getMonkeyInfo();
        food_codes = {'EP8600','EP8700'};
        time = clock;
        time = time(4);

        animalsWhoGotFood = {};
        
        conn=connectToDVMax();
        
        for iMonkey = 1:length(animalList)
            animalList(iMonkey).animalName;
            cagecardID = animalList(iMonkey).cageID;
            cagecardID(strfind(cagecardID,'C')) = [];
            data=fetchMonkeyRecord(conn,cagecardID);

            if todayIsAHoliday
                ccmInChargeFood = weekendFoodList{find(strcmpi(weekendFoodList(:,1),['CC' cagecardID])),todayIsAHoliday};
                ccmInChargeFood = strcmpi(ccmInChargeFood,'ccm');
            else
                ccmInChargeFood = 0;
            end
            animalList(iMonkey).restricted = 0;

            if ccmInChargeFood
                animalsWhoGotFood{end+1} = animalList(iMonkey).animalName;
                disp([animalList(iMonkey).animalName ' was fed by CCM.'])       
                animalList(iMonkey).fed_by = 'CCM';
            else         
                animalList(iMonkey).restricted=isFoodRestricted(data);
                if animalList(iMonkey).restricted               %% food restricted monkey
                    lastFoodEntry = [];
                    for iFoodCodes = 1:length(food_codes)
                        temp = find(strcmpi(food_codes{iFoodCodes},{data{:,3}}),1,'first');
                        if ~isempty(temp)
                            lastFoodEntry(end+1) = temp; %#ok<AGROW>
                        end      
                    end
                    if ~isempty(lastFoodEntry)
                        lastFoodEntry = min(lastFoodEntry);
                    else
                        lastFoodEntry = [];
                    end  
                    if ~isempty(lastFoodEntry)
                        lastFoodEntry = min(lastFoodEntry);
                    else
                        lastFoodEntry = [];
                    end
                    if ~isempty(lastFoodEntry)
                        lastFoodEntryDate = data{lastFoodEntry,2};
                        flag=floor(datenum(lastWaterEntryDate)) ~= datenum(date);
                    else
                        flag=true;
                    end
                    if flag               
                        if time < 18
                            if testing
                                recipients = adminContacts.maintainer(1);
                                subject = '(this is a test) Your monkey has not received food';
                            else
                                recipients = animalList(iMonkey).contactEmail;
                                if ~isempty(animalList(iMonkey).secondInCharge)
                                    recipients = {recipients,animalList(iMonkey).secondarycontactEmail};
                                end
                                subject = 'Your monkey has not received food';
                            end
                            
                            message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not received food as of ' datestr(now) '.'],...
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
                            disp(['Warning: ' animalList(iMonkey).animalName ' has not received food today.'])
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
                                subject = ['(this is a test) Last warning: ' animalList(iMonkey).animalName ' has not received  food!'];
                            else
                                recipients = peopleList.contactEmail;       
                                subject = ['Last warning: ' animalList(iMonkey).animalName ' has not received water!'];
                            end    

                            if ~isempty(secondInCharge)
                                message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not received food as of ' datestr(now) '.'],...
                                    ['Person in charge: ' peopleList.fullName{personInCharge} '(' peopleList.contactNumber{personInCharge} ')'],...
                                    ['Second in charge: ' peopleList.fullName{secondInCharge} '(' peopleList.contactNumber{secondInCharge} ')'],...
                                    'Sent from Matlab!'};
                            else
                                message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not received food as of ' datestr(now) '.'],...
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
                            disp(['Last warning: ' animalList(iMonkey).animalName ' has not received food today.'])
                        end
                    else
                        animalsWhoGotFood{end+1} = animalList(iMonkey).animalName;
                        disp([animalList(iMonkey).animalName ' received food today.'])
                        animalList(iMonkey).fed_by = 'lab';
                    end
                else      %% free food monkey
                    animalsWhoGotFood{end+1} = animalList(iMonkey).animalName;
                    disp([animalList(iMonkey).animalName ' is not food restricted.'])
                    animalList(iMonkey).fed_by = 'CCM';
                end       
            end   
        end
        
        if time >= 18 && numel(animalList)==numel(animalsWhoGotFood)
            recipients = {};
            if testing
                recipients = adminContacts.maintainer(1);
                subject = ['(this is a test) All monkeys received food'];
                message = {'The following monkeys received food today:'};
                for iMonkey = 1:length(animalList)
                    message = {message{:},[animalList(iMonkey).animalName  '    food: ' animalList(iMonkey).fed_by]};
                end 
                message = {message{:},'Sent from Matlab! This is a test.'};
                send_mail_message(recipients,subject,message)
            else
                for iP = 1:size(peopleList,1)
                    recipients = {recipients{:} peopleList.contactEmail{iP}};
                end
                if(rand() < 10000)
                    subject = ['All monkeys received food'];
                else
                    subject = ['All monkeys are still monkeys'];
                end
                message = {'The following monkeys received food today:'};
                for iMonkey = 1:length(animalList)
                    message = {message{:},[animalList(iMonkey).animalName '    food: ' animalList(iMonkey).fed_by]};
                end 
                message = {message{:},'Sent from Matlab!'};
                    message_sent = 0;
                while (~message_sent)
                    try
                        send_mail_message(recipients,subject,message)
                        message_sent = 1;            
                    catch
                        pause(5)
                    end
                end
            end    
        end

        disp('Finished checking DVMax')
        close(conn)
        pause(10)
    catch ME
        sendCrashEmail(adminContacts.maintainer(1),ME,'DVMaxFoodChecker')
    end

end