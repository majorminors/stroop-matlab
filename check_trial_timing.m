x = cell2mat({d.timestamps(find(contains({d.timestamps.description},'Start of Trial'))).time})/1000
y = cell2mat({d.timestamps(find(contains({d.timestamps.description},'End of Trial'))).time})/1000
z = cell2mat({d.timestamps(find(contains({d.timestamps.description},'Cue Onset'))).time})/1000

for i = 1:numel(x)-1
    a(i) = x(i+1)-x(i);
end

for i = 1:numel(y)
    b(i) = y(i)-x(i);
end


for i = 1:numel(z)-1
    c(i) = y(i)-z(i);
end