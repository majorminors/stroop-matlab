% takes a textfile and produces a cell array, each cell is a line from the
% textfile. to display with PTB, need to pull it out of the cell array,
% e.g. `wordStim{index}` (note squiggly brackets)
function wordStim = makeWordList(fileName)

fid = fopen(fileName);
tline = fgetl(fid);
counter=1;
while ischar(tline)
%     disp(tline) % if you'd like to check it works
    wordStim{counter} = tline;
    counter = counter+1;
    tline = fgetl(fid);
end
fclose(fid);

end