--[[
midisort-merge-ascending.lua

Algo: Merge Sort

This is a MIDI sorter. It duplicates the selected 
clip then performs one pass of a bubble sort on the duplicate. 

If you chain this it will eventually create a copy that is fully sorted
whilst leaving a performable breadcrumb trail. 

This one swaps note durations.

Ascending

]] -- list_retval, list_selected, 
-- list_muted, list_startppqpos, 
-- list_endppqpos, list_chan, 
-- list_pitch, list_vel = reaper.MIDI_GetNote(take,listNote)
-- reaper.ShowConsoleMsg(" " .. list_pitch .. " " .. list_startppqpos .. " ".. list_endppqpos .. "\n");
--[[
    makes a array of notes

    notes are tables of 8 values accessed by dot syntax 1-8 inclusive

    .1 = retval (bool) .2 = selected (bool) .3 = muted (bool) .4 startppqpos (float) 
    .5 endppqpos (float) .6 chan (int) .7 pitch (int) .8 vel (int)
    ]] -- function getLower(a,b)
--   local i,j=1,1
--   return function() 
--     if not b[j] or a[i] and a[i]<b[j] then
--       i=i+1; return a[i-1]
--     else
--       j=j+1; return b[j-1]
--     end
--   end  
-- end
-- mergeCounter = 0;
--------------------------------------------------------------------------FIELDS
breadCrumbs = {}
breadCrumbsIdx = 1;

-----------------------------------------------------------------------FUNCTIONS

function printNotesArray(notes)

    for i, note in ipairs(notes) do

        reaper.ShowConsoleMsg("\n  " .. i .. ": ")

        for j, val in ipairs(note) do

            reaper.ShowConsoleMsg("" .. tostring(val) .. ", ")

        end

        reaper.ShowConsoleMsg("\n")
    end

end

function breadCrumbsArray(a, b)

    -- LEFT IN FOR RECURSION TESTING
    for i = 1, #a, 1 do

        breadCrumbs[breadCrumbsIdx] = deepcopy(a[i])
        -- breadCrumbs[breadCrumbsIdx] = a[i]
        breadCrumbsIdx = 1 + breadCrumbsIdx

    end

    for i = 1, #b, 1 do

        breadCrumbs[breadCrumbsIdx] = deepcopy(b[i])
        -- breadCrumbs[breadCrumbsIdx] = b[i]
        breadCrumbsIdx = 1 + breadCrumbsIdx

    end

end

function table.slice(table, start, stop)

    if start == nil then start = 1 end
    if stop == nil then stop = #table end
    output = {};
    local outputIdx = 1;

    for i = 1, #table, 1 do

        if i >= start and i < stop + 1 then
            output[outputIdx] = table[i]
            outputIdx = 1 + outputIdx
        end

    end

    return output

end

function table.concat(a, b)

    local output = {}
    local outputIdx = 1;
    -- LEFT IN FOR RECURSION TESTING
    for i = 1, #a, 1 do

        output[outputIdx] = a[i]
        outputIdx = 1 + outputIdx

    end

    for i = 1, #b, 1 do

        output[outputIdx] = b[i]
        outputIdx = 1 + outputIdx

    end

    return output

end

function table.combine(a, b)

    local output = {}
    local outputIdx = 1;

    --[[                               LEFT IN FOR RECURSION TESTING
  for i = 1, #a, 1 do
  
    output[outputIdx] = a[i]
    outputIdx = 1 + outputIdx
  
  end
  
  for i = 1, #b, 1 do
  
  output[outputIdx] = b[i]
  outputIdx = 1 + outputIdx
  
  end
  ]]

    i = 1;
    j = 1;

    while i <= (#a + 1) and j <= #b + 1 do

        -- reaper.ShowConsoleMsg(a[i][7])
        -- reaper.ShowConsoleMsg(b[j][7]);
        reaper.ShowConsoleMsg(i)
        reaper.ShowConsoleMsg(j)

        if (i < (#a + 1) and j < (#b + 1) and a[i][7] >= b[j][7]) then

            output[outputIdx] = a[i]
            outputIdx = 1 + outputIdx

            i = i + 1
            reaper.ShowConsoleMsg("a")
        elseif (i < (#a + 1) and j < (#b + 1) and a[i][7] <= b[j][7]) then

            output[outputIdx] = b[j]

            outputIdx = 1 + outputIdx

            j = j + 1
            reaper.ShowConsoleMsg("b")
        
        elseif (i == (#a + 1)) and (j < (#b + 1)) then
            output[outputIdx] = b[j]
            outputIdx = 1 + outputIdx

            j = j + 1
            reaper.ShowConsoleMsg("c")
        elseif (j == (#b + 1)) and (i < (#a + 1)) then

            output[outputIdx] = a[i]
            outputIdx = 1 + outputIdx

            i = i + 1
            reaper.ShowConsoleMsg("d")

        else
            i = i + 1
            j = j + 1
        end

        -- printNotesArray(output)

    end

    return output

end

--------------------------------------------------------------------------------

reaper.ClearConsole();
reaper.ShowConsoleMsg("sorting-phase-merge\n");

target = reaper.GetSelectedMediaItem(0, 0);
if target == nil then
    reaper.ShowConsoleMsg("no item selected\n");
    return
end

take = reaper.GetTake(target, 0);
if take == nil then
    reaper.ShowConsoleMsg("no take selected\n")
    return
end

reaper.MIDI_SelectAll(take, true);

-- making an array of the notes to sort and paste into the midi item
notes = {}
listNoteIdx = 0

while listNoteIdx > -1 do
    -- Adds Current Index to Array (Index starts at 1)
    notes[listNoteIdx + 1] = {reaper.MIDI_GetNote(take, listNoteIdx)}
    -- Advances the iterator (listNoteIdx)
    listNoteIdx = reaper.MIDI_EnumSelNotes(take, listNoteIdx)

end

reaper.ShowConsoleMsg("\n")

-- printNotesArray(table.slice(notes, 0, 8))

function mergesort(list, ind)

    local tmp = 0;

    local index = ind or tmp

    local s = math.floor(#list / 2)
    reaper.ShowConsoleMsg("\nmergesort -- index: " .. index .. " size: " ..
                              #list .. " s: " .. s .. " \n")

    if #list == 1 then return list end

    return merge(mergesort(table.slice(list, 1, s), index + 1),
                 mergesort(table.slice(list, s + 1)), index + 1), index
end

function merge(a, b, index)

    reaper.ShowConsoleMsg("\na: " .. #a .. " b: " .. #b)
    reaper.ShowConsoleMsg("\nA: ")
    printNotesArray(a)
    breadCrumbsArray(a, b)
    reaper.ShowConsoleMsg("\nB: ")
    printNotesArray(b)
    -- breadCrumbsArray(b)

    return table.combine(a, b)
end

function table.clone(org) return {table.unpack(org)} end

function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function notePositionCorrection(array)
    local offset = 0

    for i = 1, #array do

        -- reaper.ShowConsoleMsg(offset)
        local startNote = offset
        local endNote = (array[i][5] - array[i][4]) + offset
        offset = (endNote - startNote) + offset

        array[i][4] = startNote
        array[i][5] = endNote

    end

    return array
end

counter = 0

function notePositionCorrectionDebug(array)
    local offset = 0

    reaper.ShowConsoleMsg(debug.traceback())

    for i = 1, #array do

        -- reaper.ShowConsoleMsg(offset)
        local startNote = offset
        local endNote = (array[i][5] - array[i][4]) + offset
        offset = (endNote - startNote) + offset

        array[i][4] = counter
        array[i][5] = counter + 1

        counter = counter + 1
    end

    return array
end

output = mergesort(notes)

reaper.ShowConsoleMsg(tostring(breadCrumbs))
breadCrumbs = deepcopy(breadCrumbs)
output = deepcopy(table.concat(breadCrumbs, output))
output = deepcopy(notePositionCorrection(output))

reaper.ShowConsoleMsg("\n")

reaper.ShowConsoleMsg("\n")
printNotesArray(output)
reaper.Main_OnCommand(41168, 1)
targetTrack = reaper.GetMediaItem_Track( target )
reaper.ShowConsoleMsg(" - " .. output[1][4] .. " - " .. output[#output][5])
outputItem = reaper.CreateNewMIDIItemInProj( targetTrack,  reaper.GetCursorPosition(),  10)

for i = 1, #output do

  -- for each note
  reaper.MIDI_InsertNote( reaper.GetActiveTake(outputItem), false, false, output[i][4], output[i][5], 0, output[i][7], output[i][8], false)

end
