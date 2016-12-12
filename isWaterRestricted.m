function waterRestricted=isWaterRestricted(data)
    %utility function to return whether or not a monkey is on water
    %restriction. data will be the structure pulled from DVMax, and passed
    %to isWaterRestricted by DVMaxWaterChecker or DVMaxWeightChecker
    
    free_water_codes = {'EP9200 ','AC1093'};
    water_restriction_start_codes = {'EP9100','AC1092'};
    last_free_water_entry = [];
    for iFreeWaterCodes = 1:length(free_water_codes)
        temp = find(strcmpi(free_water_codes{iFreeWaterCodes},{data{:,3}}),1,'first');
        if ~isempty(temp)
            last_free_water_entry(end+1) = temp; %#ok<AGROW>
        end
    end
    if ~isempty(last_free_water_entry)
        last_free_water_entry = min(last_free_water_entry);     % Find first water entry in list
    else
        last_free_water_entry = 1000000;
    end
    last_water_restriction_start = inf;
    for iCode = 1:length(water_restriction_start_codes)
        temp = find(strcmpi(water_restriction_start_codes{iCode},{data{:,3}}),1,'first');
        if isempty(temp)
            temp = inf;
        end
        last_water_restriction_start = min(last_water_restriction_start,temp);
    end
    if isempty(last_water_restriction_start)
        last_water_restriction_start = 1000000;
    end
    if last_water_restriction_start < last_free_water_entry                 %% water restricted monkey
        waterRestricted = true;
    else
        waterRestricted=false;
    end
    
end