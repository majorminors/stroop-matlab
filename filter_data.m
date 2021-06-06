function filtered_data = filter_data(data,sizing,colour,congruency,trialtype,font)
% filters data from stroop

if ~isempty(sizing)
    switch sizing
        case 'short'
            idx = find(data(4,:) == 1);
        case 'medium'
            idx = find(data(4,:) == 2);
        case 'tall'
            idx = find(data(4,:) == 3);
    end
    data = data(:,idx);
end
if ~isempty(colour)
    switch colour
        case 'red'
            idx = find(data(5,:) == 1);
        case 'blue'
            idx = find(data(5,:) == 2);
        case 'green'
            idx = find(data(5,:) == 3);
    end
    data = data(:,idx);
end
if ~isempty(congruency)
    switch congruency
        case 'congruent'
            idx = find(data(6,:) == 1); % congruent
        case 'incongruent'
            idx = find(data(6,:) == 2); % incongruent
    end
    data = data(:,idx);
end
if ~isempty(trialtype)
    switch trialtype
        case 'sizes'
            idx = find(data(7,:) == 1); % size info
        case 'colour'
            idx = find(data(7,:) == 2); % colour info
    end
    data = data(:,idx);
end
if ~isempty(font)
    switch font
        case 'falsefont'
            idx = find(data(8,:) == 1); % print info
        case 'font'
            idx = find(data(8,:) == 2); % print info
    end
    data = data(:,idx);
end

% filtered_data = data(1,:); % rt
filtered_data = data(3,:); % accuracy

end