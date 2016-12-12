function DVMaxWeightChecker()

    testing=1;
    maintainerEmailAddress= 'tucker.tomlinson1@northwestern.edu';
    try
        [peopleList,animalList,~,~,~]=getMonkeyInfo();
        time = clock;
        time = time(4);
        todaysDate = datenum(date);
        
        conn=connectToDVMax();
        
        for iMonkey = 1:length(animalList)
            animalList(iMonkey).animalName;
            cagecardID = animalList(iMonkey).cageID;
            cagecardID(strfind(cagecardID,'C')) = [];

            data=fetchMonkeyRecord(conn,cagecardID);
            if isFoodRestricted(data) || isWaterRestricted(data)
                body_weight_entries = find(~cellfun(@isempty,strfind(data(:,3),'EX1050')));
                body_weight_idx = cellfun(@strfind,data(body_weight_entries,5),repmat({'Weight: '},length(body_weight_entries),1),'UniformOutput',false);
                units_idx = cellfun(@strfind,data(body_weight_entries,5),repmat({'Units: '},length(body_weight_entries),1),'UniformOutput',false);
                units_idx_2 = cellfun(@strfind,data(body_weight_entries,5),repmat({'(kg)'},length(body_weight_entries),1),'UniformOutput',false);
                units_idx_3 = cellfun(@strfind,data(body_weight_entries,5),repmat({'kg'},length(body_weight_entries),1),'UniformOutput',false);
                units_idx(cellfun(@isempty,units_idx)) = {inf};
                units_idx_2(cellfun(@isempty,units_idx_2)) = {inf};
                units_idx_3(cellfun(@isempty,units_idx_3)) = {inf};
                units_idx_3 = cellfun(@min,units_idx_3);
                units_idx = cellfun(@min,units_idx,units_idx_2);
                units_idx = min(units_idx,units_idx_3);
                animalList(iMonkey).body_weight = [];
                animalList(iMonkey).body_weight_date = [];
                for iEntry = 1:length(body_weight_entries)
                    if ~isempty(body_weight_idx{iEntry})
                        try
                            if ~isempty(str2num(data{body_weight_entries(iEntry),5}(units_idx(iEntry)-2)))
                                units_idx(iEntry) = units_idx(iEntry)+1;
                            end
                            animalList(iMonkey).body_weight(end+1) = str2num(data{body_weight_entries(iEntry),5}(body_weight_idx{iEntry}+8 : units_idx(iEntry)-2));
                            animalList(iMonkey).body_weight_date(end+1) = floor(datenum(data{body_weight_entries(iEntry),2}));
                        end
                    end
                end

            % Monkey weight warning
                if isempty(animalList(iMonkey).body_weight_date)
                    disp(['Warning: ',animalList(iMonkey).animalName ' has never been weighed!'])
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
                        recipients = maintainerEmailAddress;
                        subject = ['(this is a test) Last warning: ' animalList(iMonkey).animalName ' has not received weekly weight check!'];
                    else
                        recipients = peopleList.contactEmail;       
                        subject = ['Last warning: ' animalList(iMonkey).animalName ' has not received weekly weight check!'];
                    end    

                    if ~isempty(secondInCharge)
                        message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not received weekly weight check as of ' datestr(now) '.'],...
                            ['Person in charge: ' peopleList.fullName{personInCharge} '(' peopleList.contactNumber{personInCharge} ')'],...
                            ['Second in charge: ' peopleList.fullName{secondInCharge} '(' peopleList.contactNumber{secondInCharge} ')'],...
                            'Sent from Matlab!'};
                    else
                        message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not received weekly weight check as of ' datestr(now) '.'],...
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
                    lastWeighing=nan;
                else
                    lastWeighing = (animalList(iMonkey).body_weight_date(1));
                    if datenum(date) - lastWeighing > 6 
                        disp(['Warning: ' animalList(iMonkey).animalName ' has not been weighed in ' num2str(datenum(date) - lastWeighing) ' day(s).'])
                        monkey_last_warning(animalList(iMonkey),peopleList,'NoWeight',testing,maintainer_email_address);
                        disp(['Warning: ',animalList(iMonkey).animalName ' has not been weighed in ' num2str(datenum(date) - lastWeighing) ' day(s).'])
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
                            recipients = maintainerEmailAddress;
                            subject = ['(this is a test) Last warning: ' animalList(iMonkey).animalName ' has not received weekly weight check!'];
                        else
                            recipients = peopleList.contactEmail;       
                            subject = ['Last warning: ' animalList(iMonkey).animalName ' has not received weekly weight check!'];
                        end    

                        if ~isempty(secondInCharge)
                            message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not received weekly weight check as of ' datestr(now) '.'],...
                                ['Person in charge: ' peopleList.fullName{personInCharge} '(' peopleList.contactNumber{personInCharge} ')'],...
                                ['Second in charge: ' peopleList.fullName{secondInCharge} '(' peopleList.contactNumber{secondInCharge} ')'],...
                                'Sent from Matlab!'};
                        else
                            message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not received weekly weight check as of ' datestr(now) '.'],...
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
                    elseif datenum(date) - lastWeighing > 4 
                        disp(['Warning: ' animalList(iMonkey).animalName ' has not been weighed in ' num2str(datenum(date) - lastWeighing) ' day(s).'])

                        if testing
                            recepients = maintainerEmailAddress;        
                            subject = ['(this is a test) ' animalList(iMonkey).animalName ' does not have a weight entry from the past 5 days.'];
                            
                        else
                            recepients{1} = animalList(iMonkey).contactEmail;
                            if ~isempty(animalList(iMonkey).secondInCharge)
                                recepients = {recepients{:},animalList(iMonkey).secondarycontactEmail};
                            end
                            subject = [animalList(iMonkey).animalName ' does not have a weight entry from the past 5 days.'];
                        end
                        message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not been weighed since ' datestr(lastWeighing) '.'],...
                            'Sent from Matlab! This is a test.'};        
                        message_sent = 0;
                        while (~message_sent)
                            try
                                send_mail_message(recepients,subject,message)                
                                message_sent = 1;  
                            catch
                                message_sent
                                pause(5)
                            end
                        end                  
                    end
                end

            end        
        end

        %% Body weight
        if time >= 18 && weekday(date) == 2   
            gf = figure;
            num_plots = 3;
            for iPlot = 1:num_plots
                subplot(num_plots,1,iPlot)
                hold on            
                legend_text = {};
                monkey_list = [1:floor(length(animalList)/num_plots)]+floor(length(animalList)/num_plots)*(iPlot-1);
                if iPlot == num_plots && mod(length(animalList),num_plots)
                    monkey_list = [monkey_list monkey_list(end)+mod(length(animalList),num_plots)];
                end
                colors = distinguishable_colors_2(length(monkey_list),{'w'});
                color_idx = 0;
                hp = [];
                for iMonkey = monkey_list
                    if animalList(iMonkey).restricted
                        animalList(iMonkey).days_since_last_weighing = num2str((datenum(date)-animalList(iMonkey).body_weight_date(1)));
                    else
                        animalList(iMonkey).days_since_last_weighing = 'FW';
                    end
                    color_idx = color_idx+1;
                    if ~isempty(animalList(iMonkey).body_weight_date)
                        hp(end+1) = plot(animalList(iMonkey).body_weight_date,animalList(iMonkey).body_weight,'Color',colors(color_idx,:),'LineWidth',2);   
                        if ~isnan(animalList(iMonkey).idealBodyWeight)
                            plot(animalList(iMonkey).body_weight_date([1 end]),[animalList(iMonkey).idealBodyWeight animalList(iMonkey).idealBodyWeight],'LineStyle','--','Color',colors(color_idx,:));
                        end
                        legend_text{end+1} = [animalList(iMonkey).animalName ' ' num2str(round(100*(animalList(iMonkey).body_weight(1)/animalList(iMonkey).idealBodyWeight - 1))) '%. (' animalList(iMonkey).days_since_last_weighing ')'];
                    end
                end        
                set(gca,'XTick',[datenum('2013-01-01'):182:datenum(date)])
                datetick('x',26,'keepticks')   
                xlim([datenum('2013-01-01') datenum(date)])                             
                legend(hp,legend_text,'Location','West')
            end
            print(gf,'BodyWeights','-dpng')        
            if testing
                recepients = maintainerEmailAddress;
                subject = ['(this is a test) Weekly body weights update'];
            else
                recepients = peopleList.contactEmail;       
                subject = ['Weekly body weights update'];
            end    

            message = {'Here''s the weekly monkey body weight update.  Don''t forget to make body weight entries (EX1050) every week!';...
                'The numbers in parentheses are the numbers of days since the last EX1050 entry.'};

            message_sent = 0;
            while (~message_sent)
                try
                    send_mail_message(recepients,subject,message,'BodyWeights.png')
                    message_sent = 1;            
                catch
                    pause(5)
                end
            end                 
        end        

        disp('Finished checking DVMax')
        close(conn)
        pause(10)
    catch ME
        sendCrashEmail(maintainerEmailAddress,ME,'DVMaxWeightChecker')
    end

end