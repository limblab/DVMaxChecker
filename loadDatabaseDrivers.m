function loadDatabaseDrivers()
    %utiltity function to load oracle database drivers. This is intended
    %for use with the DVMax checker scripts, and relies on the working
    %directory being in the checker folder, and certain files existing in
    %that folder
    path_file = fopen('classpath.txt');
    path_file_text = fread(path_file)';
    fclose(path_file);
    driver_idx = strfind(char(path_file_text),'ojdbc6.jar')-2;
    [current_folder,~,~] = fileparts(mfilename('fullpath'));
    if ~isempty(driver_idx)
        driver_path_start = find(path_file_text(1:driver_idx)==10,1,'last')+1;
        driver_path = char(path_file_text(driver_path_start:driver_idx));        
        if ~strcmp(current_folder,driver_path)
            %path_file_text(driver_path_start:driver_idx+11) = [];
            %path_file_text = [path_file_text 10 uint8([current_folder filesep 'ojdbc6.jar'])];
            javarmpath([driver_path filesep 'ojdbc6.jar'])
            javaaddpath([current_folder filesep 'ojdbc6.jar'],'-end')
        end
    else
        %path_file_text = [path_file_text 10 uint8([current_folder filesep 'ojdbc6.jar'])];
        javaaddpath([current_folder filesep 'ojdbc6.jar'],'-end')
    end
end