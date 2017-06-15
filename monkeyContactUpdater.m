function monkeyContactUpdater()
    %check whether the contact info for a monkey has updated, and send an
    %email to the monkey team listing the revised contact info
    testing=0;
%     maintainerEmailAddress= 'tucker.tomlinson1@northwestern.edu';
    maintainerEmailAddress= 'josephsombeck2022@u.northwestern.edu';
    try
        [MonkeyWaterLocation,contactListLocation]=getMonkeyDataLocation();
       
        keepList={'cageID','personInCharge','secondInCharge'};%cells to keep when comparing prior caretaker data to call send_monkey_person_email

        load('animalList')
        oldAnimalList2=animalList;
        fields=fieldnames(oldAnimalList2(1));           
        for i=1:numel(fields)
            if isempty(cell2mat(strfind(keepList,fields{i})))
                oldAnimalList2=rmfield(oldAnimalList2,fields{i});
            end
        end

        peopleList = readtable(contactListLocation,'FileType','spreadsheet','sheet','monkeyTeam');
        animalList = loadMonkeyContacts(MonkeyWaterLocation,peopleList);
        save('animalList','animalList')    
        animalList2=animalList;
        fields=fieldnames(animalList2(1));
        for i=1:numel(fields)
            if isempty(cell2mat(strfind(keepList,fields{i})))
                animalList2=rmfield(animalList2,fields{i});
            end
        end
        ccmList = readtable(contactListLocation,'FileType','spreadsheet','sheet','CCM'); 

        if ~isequal(animalList2,oldAnimalList2)
            subject = 'NHP caretaker list update';
            messageTable = {};
            for iAnimal = 1:length(animalList)
                temp = length([animalList(iAnimal).animalID ' - ' animalList(iAnimal).animalName ':']);
                messageTable{iAnimal} = [animalList(iAnimal).animalID ' - ' animalList(iAnimal).animalName ':' repmat(' ',1,25-temp) animalList(iAnimal).personInCharge...
                    ' (' animalList(iAnimal).contactEmail '), ' animalList(iAnimal).secondInCharge ' (' animalList(iAnimal).secondarycontactEmail ')'];   
            end
            message = [{'Hi everyone, '} {''} {'This is the current list of monkeys and their caretakers from the Miller lab. You will automatically receive '...
                'a new email whenever this list changes.'} {''} messageTable {''} {['If you don''t want to receive these emails anymore please email ' maintainerEmailAddress '.']}...
                {''} {'Best regards,'} {'Miller Lab'}];
            if ~testing
                recepients = [ccmList.contactEmail; peopleList.contactEmail];
            else
                recepients = maintainerEmailAddress;
            end
            send_mail_message(recepients,subject,message)
        end
    catch ME
        sendCrashEmail(maintainerEmailAddress,ME,'monkeyContactUpdater')
    end


end