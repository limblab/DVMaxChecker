function foodRestricted=isFoodRestricted(data)
    %utility function to return whether or not a monkey is on food
    %restriction. data will be the structure pulled from DVMax, and passed
    %to isFoodRestricted by DVMaxFoodChecker or DVMaxWeightChecker
    
    free_food_codes = {'EP9400'};
    food_restriction_start_code = 'EP9300';
    last_free_food_entry = [];
    for iFreeFoodCodes = 1:length(free_food_codes)
        temp = find(strcmpi(free_food_codes{iFreeFoodCodes},{data{:,3}}),1,'first');
        if ~isempty(temp)
            last_free_food_entry(end+1) = temp; %#ok<AGROW>
        end
    end
    if ~isempty(last_free_food_entry)
        last_free_food_entry = min(last_free_food_entry);     % Find first food entry in list
    else
        last_free_food_entry = 1000000;
    end
    last_food_restriction_start = find(strcmpi(food_restriction_start_code,{data{:,3}}),1,'first');
    if isempty(last_food_restriction_start)
        last_food_restriction_start = 1000000;
    end

    if last_food_restriction_start < last_free_food_entry                 %% food restricted monkey
        foodRestricted = true;
    else
        foodRestricted = false;
    end  


end