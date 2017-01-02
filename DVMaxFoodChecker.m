function DVMaxFoodChecker()

    testing=1;
    maintainerEmailAddress= 'tucker.tomlinson1@northwestern.edu';
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
                        lastFoodEntry = 1000000;
                    end  

                    lastFoodEntryDate = data{lastFoodEntry,2};
                    if floor(datenum(lastFoodEntryDate)) ~= datenum(date)                    
                        if time < 18
                            monkey_warning(animalList(iMonkey),'NoFood',testing,maintainerEmailAddress)
                            disp(['Warning: ' animalList(iMonkey).animalName ' has not received food today.'])
                        else %if time < 21
                            monkey_last_warning(animalList(iMonkey),peopleList,'NoFood',testing,maintainerEmailAddress)
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
        
        if time >= 18 %&& time < 23
            recipients = {};
            if testing
                recipients = maintainerEmailAddress;
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
                subject = ['All monkeys received food'];
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
        sendCrashEmail(maintainerEmailAddress,ME,'DVMaxFoodChecker')
    end

end