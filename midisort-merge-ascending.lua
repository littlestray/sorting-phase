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

function getLower(a,b)
  local i,j=1,1
  return function() 
    if not b[j] or a[i] and a[i]<b[j] then
      i=i+1; return a[i-1]
    else
      j=j+1; return b[j-1]
    end
  end  
end
 
function merge(a,b)
  local res={}
  for v in getLower(a,b) do res[#res+1]=v end
  return res
end
 
function mergesort(list)
  if #list<=1 then return list end
  local s=math.floor(#list/2)
  return merge(mergesort{unpack(list,1,s)}, mergesort{unpack(list,s+1)})
end

reaper.ClearConsole();
reaper.ShowConsoleMsg("Start midiSort1\n");
reaper.ShowConsoleMsg("#0\n");

reaper.Main_OnCommand(41295, 1);

target = reaper.GetSelectedMediaItem(0, 0);
if target == nil then reaper.ShowConsoleMsg("no item selected\n"); return end

take   = reaper.GetTake(target, 0);
if take == nil then reaper.ShowConsoleMsg("no take selected\n") return end

--retval, notecnt, ccevtcnt, textsyxevtcnt = reaper.MIDI_CountEvts(take);
--if notecnt == 0 then reaper.ShowConsoleMsg("no notes in take\n") return end

reaper.MIDI_SelectAll(take, true);

notes = {}
workArray = {}

length = 0
listNote = 0
while listNote >= 0
  do
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

    list_vals = {reaper.MIDI_GetNote(take,listNote)}
    notes[listNote] = list_vals;
    
    --get next note returns -1 if not next note
    listNote = reaper.MIDI_EnumSelNotes(take, listNote)
    
    
end

reaper.ShowConsoleMsg(tostring(notes[0][1]))

reaper.ShowConsoleMsg(tostring(#notes + 1))

temp = mergesort(notes)

reaper.ShowConsoleMsg(temp)

-- params (array, empty-work-array, array-length)
