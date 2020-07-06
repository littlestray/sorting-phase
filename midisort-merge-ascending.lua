--[[
midisort-merge-ascending.lua

Algo: Merge Sort

This is a MIDI sorter. It duplicates the selected 
clip then performs one pass of a bubble sort on the duplicate. 

If you chain this it will eventually create a copy that is fully sorted
whilst leaving a performable breadcrumb trail. 

This one swaps note durations.

Ascending

]]

   -- list_retval, list_selected, 
    -- list_muted, list_startppqpos, 
    -- list_endppqpos, list_chan, 
    -- list_pitch, list_vel = reaper.MIDI_GetNote(take,listNote)
    -- reaper.ShowConsoleMsg(" " .. list_pitch .. " " .. list_startppqpos .. " ".. list_endppqpos .. "\n");
    
    --[[
    makes a array of notes

    notes are tables of 8 values accessed by dot syntax 1-8 inclusive

    .1 = retval (bool) .2 = selected (bool) .3 = muted (bool) .4 startppqpos (float) 
    .5 endppqpos (float) .6 chan (int) .7 pitch (int) .8 vel (int)
    ]]


-- function getLower(a,b)
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


-----------------------------------------------------------------------FUNCTIONS

function printNotesArray(notes)
  
  for i,note in ipairs(notes) do
  
    reaper.ShowConsoleMsg("\n  " .. i .. ": ")

    for j, val in ipairs(note) do
      
      reaper.ShowConsoleMsg( "" .. tostring(val) .. ", ")
      
    end
    
    reaper.ShowConsoleMsg("\n")
  end

end

function table.slice(table, start, stop)

  if start == nil then start = 1 end
  if stop  == nil then stop = #table end
  local output = {};
  local outputIdx = 1;

  for i = 1, #table, 1 do

    if i >= start and i < stop + 1 then
      output[outputIdx] = table[i]
      outputIdx = 1 + outputIdx
    end

  end

  return output

end

function table.combine(a, b)

  local output = {}
  local outputIdx = 1;

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


--------------------------------------------------------------------------------

reaper.ClearConsole();
reaper.ShowConsoleMsg("sorting-phase-merge\n");
--reaper.ShowConsoleMsg("#0\n");

-- copies the midiItem
-- reaper.Main_OnCommand(41295, 1);

target = reaper.GetSelectedMediaItem(0, 0);
if target == nil then reaper.ShowConsoleMsg("no item selected\n"); return end

take   = reaper.GetTake(target, 0);
if take == nil then reaper.ShowConsoleMsg("no take selected\n") return end

reaper.MIDI_SelectAll(take, true);



--making an array of the notes to sort and paste into the midi item
notes = {}
listNoteIdx = 0

while listNoteIdx > -1 do
    --Adds Current Index to Array (Index starts at 1)
    notes[listNoteIdx + 1] = {reaper.MIDI_GetNote(take,listNoteIdx)}
    --Advances the iterator (listNoteIdx)
    listNoteIdx = reaper.MIDI_EnumSelNotes(take, listNoteIdx)
    
end

reaper.ShowConsoleMsg("\n")

--printNotesArray(table.slice(notes, 0, 8))

function mergesort(list)
  
  local s=math.floor(#list/2)
  reaper.ShowConsoleMsg("mergesort -- size: " .. #list .. " s: " .. s .. " ")

  if #list == 1 then  return list end
  
  return merge(mergesort(table.slice(list,1,s)), mergesort(table.slice(list,s+1)))
end

function merge(a,b)

  
  reaper.ShowConsoleMsg("\nA: ")
  printNotesArray(a)
  reaper.ShowConsoleMsg("\nB: ")
  printNotesArray(b)
  
  return table.combine(a,b)
end

mergesort(notes)
