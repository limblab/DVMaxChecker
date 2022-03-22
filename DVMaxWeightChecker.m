function DVMaxWeightChecker()

    testing=0;
    [~,contactListLocation]=getMonkeyDataLocation();
    adminContacts = readtable(contactListLocation,'FileType','spreadsheet','sheet','admin','Basic',1);
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
            animalList(iMonkey).restricted=isFoodRestricted(data) || isWaterRestricted(data);
            if animalList(iMonkey).restricted
                bodyWeightEntries = find(~cellfun(@isempty,strfind(data(:,3),'EX1050')));
                bodyWeightIdx = cellfun(@strfind,data(bodyWeightEntries,5),repmat({'Weight: '},length(bodyWeightEntries),1),'UniformOutput',false);
                unitsIdx = cellfun(@strfind,data(bodyWeightEntries,5),repmat({'Units: '},length(bodyWeightEntries),1),'UniformOutput',false);
                unitsIdx2 = cellfun(@strfind,data(bodyWeightEntries,5),repmat({'(kg)'},length(bodyWeightEntries),1),'UniformOutput',false);
                unitsIdx3 = cellfun(@strfind,data(bodyWeightEntries,5),repmat({'kg'},length(bodyWeightEntries),1),'UniformOutput',false);
                unitsIdx(cellfun(@isempty,unitsIdx)) = {inf};
                unitsIdx2(cellfun(@isempty,unitsIdx2)) = {inf};
                unitsIdx3(cellfun(@isempty,unitsIdx3)) = {inf};
                unitsIdx3 = cellfun(@min,unitsIdx3);
                unitsIdx = cellfun(@min,unitsIdx,unitsIdx2);
                unitsIdx = min(unitsIdx,unitsIdx3);
                animalList(iMonkey).bodyWeight = [];
                animalList(iMonkey).bodyWeightDate = [];
                for iEntry = 1:length(bodyWeightEntries)
                    if ~isempty(bodyWeightIdx{iEntry})
                        try
                            if ~isempty(str2num(data{bodyWeightEntries(iEntry),5}(unitsIdx(iEntry)-2)))
                                unitsIdx(iEntry) = unitsIdx(iEntry)+1;
                            end
                            animalList(iMonkey).bodyWeight(end+1) = str2num(data{bodyWeightEntries(iEntry),5}(bodyWeightIdx{iEntry}+8 : unitsIdx(iEntry)-2));
                            animalList(iMonkey).bodyWeightDate(end+1) = floor(datenum(data{bodyWeightEntries(iEntry),2}));
                        end
                    end
                end
                %get our contact people:
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
            % Monkey weight warning
                if isempty(animalList(iMonkey).bodyWeightDate(1))
                    disp(['Warning: ',animalList(iMonkey).animalName ' has never been weighed!'])
                elseif todaysDate-animalList(iMonkey).bodyWeightDate(1) > 6
                    %if 7 or more days have elapsed since weighing, we
                    %issue a last warning:
                    
                    if testing
                        recipients = adminContacts.maintainer(1);
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
                    messageSent = 0;
                    while (~messageSent)
                        try
                            send_mail_message(recipients,subject,message)
                            messageSent = 1;            
                        catch
                            pause(5)
                        end
                    end                 
                              
                elseif todaysDate - animalList(iMonkey).bodyWeightDate(1) > 4 
                    %if it's been 5 days since a weighing, issue a reminder
                    %to weigh the monkey
                    disp(['Warning: ' animalList(iMonkey).animalName ' has not been weighed in ' num2str(datenum(date) - animalList(iMonkey).bodyWeightDate(1)) ' day(s).'])

                    if testing
                        recipients = adminContacts.maintainer(1);        
                        subject = ['(this is a test) ' animalList(iMonkey).animalName ' does not have a weight entry from the past 5 days.'];

                    else
                        recipients = animalList(iMonkey).contactEmail;
                        if ~isempty(animalList(iMonkey).secondInCharge)
                            recipients = {recipients,animalList(iMonkey).secondarycontactEmail};
                        end
                        subject = [animalList(iMonkey).animalName ' does not have a weight entry from the past 5 days.'];
                    end
                    message = {[animalList(iMonkey).animalName ' (' animalList(iMonkey).animalID ') has not been weighed since ' datestr(animalList(iMonkey).bodyWeightDate(1)) '.'],...
                        'Sent from Matlab!'};        
                    messageSent = 0;
                    while (~messageSent)
                        try
                            send_mail_message(recipients,subject,message)                
                            messageSent = 1;  
                        catch
                            messageSent
                            pause(5)
                        end
                    end                  
                end

            end        
        end

        %% Body weight
        if weekday(date) == 2   
            gf = figure;
            numPlots = 3;
            for iPlot = 1:numPlots
                subplot(numPlots,1,iPlot)
                hold on            
                legendText = {};
                monkeyList = [1:floor(length(animalList)/numPlots)]+floor(length(animalList)/numPlots)*(iPlot-1);
                if iPlot == numPlots && mod(length(animalList),numPlots)
                    monkeyList = [monkeyList monkeyList(end)+mod(length(animalList),numPlots)];
                end
                colors = distinguishable_colors_2(length(monkeyList),{'w'});
                colorIdx = 0;
                hp = [];
                for iMonkey = monkeyList
                    if animalList(iMonkey).restricted
                        animalList(iMonkey).days_since_last_weighing = num2str((todaysDate-animalList(iMonkey).bodyWeightDate(1)));
                    else
                        animalList(iMonkey).days_since_last_weighing = 'FW';
                    end
                    colorIdx = colorIdx+1;
                    if ~isempty(animalList(iMonkey).bodyWeightDate)
                        hp(end+1) = plot(animalList(iMonkey).bodyWeightDate,animalList(iMonkey).bodyWeight,'Color',colors(colorIdx,:),'LineWidth',2);   
                        if ~isnan(animalList(iMonkey).idealBodyWeight)
                            plot(animalList(iMonkey).bodyWeightDate([1 end]),[animalList(iMonkey).idealBodyWeight animalList(iMonkey).idealBodyWeight],'LineStyle','--','Color',colors(colorIdx,:));
                        end
                        legendText{end+1} = [animalList(iMonkey).animalName ' ' num2str(round(100*(animalList(iMonkey).bodyWeight(1)/animalList(iMonkey).idealBodyWeight - 1))) '%. (' animalList(iMonkey).days_since_last_weighing ')'];
                    end
                end        
                set(gca,'XTick',[datenum('2013-01-01'):182:datenum(date)])
                datetick('x',26,'keepticks')   
                xlim([datenum('2013-01-01') datenum(date)])                             
                legend(hp,legendText,'Location','West')
            end
            print(gf,'BodyWeights','-dpng')        
            if testing
                recipients = adminContacts.maintainer(1);
                subject = ['(this is a test) Weekly body weights update'];
            else
                recipients = peopleList.contactEmail;       
                subject = ['Weekly body weights update'];
            end    

            message = {'Here''s the weekly monkey body weight update.  Don''t forget to make body weight entries (EX1050) every week!';...
                'The numbers in parentheses are the numbers of days since the last EX1050 entry.'};

            messageSent = 0;
            while (~messageSent)
                try
                    send_mail_message(recipients,subject,message,'BodyWeights.png')
                    messageSent = 1;            
                catch
                    pause(5)
                end
            end                 
        end        

        disp('Finished checking DVMax')
        close(conn)
        pause(10)
    catch ME
        sendCrashEmail(adminContacts.maintainer(1),ME,'DVMaxWeightChecker')
    end

end