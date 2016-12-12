function [MonkeyWaterLocation,contactListLocation]=getMonkeyDataLocation()
    %this is a helper function that abstracts the hard-coded file paths, so
    %that a file can be moved, and then this script can be updated rather
    %than finding all the files that have a hard-coded path
    if ispc
            MonkeyWaterLocation = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\lab_folder\Lab-Wide Animal Info\WeekendWatering\MonkeyWaterData.xlsx';
            contactListLocation = '\\fsmresfiles.fsm.northwestern.edu\fsmresfiles\Basic_Sciences\Phys\L_MillerLab\limblab\lab_folder\General-Lab-Stuff\checkerData\contacts.xls';
        elseif isunix 
            [~,hostname]=unix('hostname');
            if strcmp(strtrim(hostname),'tucker-pc')
                %mount point for fsmresfiles on tucker's computer:
                MonkeyWaterLocation='/media/fsmresfiles/limblab/lab_folder/Lab-Wide Animal Info/WeekendWatering/MonkeyWaterData.xlsx';
                contactListLocation='/media/fsmresfiles/limblab/lab_folder/General-Lab-Stuff/checkerData/contacts.xls';
            end
        else
            error('getMonkeyDataLocation:systemNotRecognized','This script is only configured to run on PC workstations or Tuckers linux computer if you are using a mac or other linux pc you will need to modify the script')
    end
end