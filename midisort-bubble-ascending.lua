--[[
midisort-bubble-ascending.lua

Algo: Bubble

This is a MIDI sorter. It duplicates the selected 
clip then performs one pass of a bubble sort on the duplicate. 

If you chain this it will eventually create a copy that is fully sorted
whilst leaving a performable breadcrumb trail. 

This one swaps note durations.

Ascending

]]

reaper.ClearConsole();
--reaper.ShowConsoleMsg("Start midiSort1\n");
--reaper.ShowConsoleMsg("#0\n");

reaper.Main_OnCommand(41295, 1);

target = reaper.GetSelectedMediaItem(0, 0);
if target == nil then reaper.ShowConsoleMsg("no item selected\n"); return end

take   = reaper.GetTake(target, 0);
if take == nil then reaper.ShowConsoleMsg("no take selected\n") return end

--retval, notecnt, ccevtcnt, textsyxevtcnt = reaper.MIDI_CountEvts(take);
--if notecnt == 0 then reaper.ShowConsoleMsg("no notes in take\n") return end

reaper.MIDI_SelectAll(take, true);

listNote = 0;
while listNote > -1
  do
    list_retval, list_selected, 
    list_muted, list_startppqpos, 
    list_endppqpos, list_chan, 
    list_pitch, list_vel = reaper.MIDI_GetNote(take,listNote);
    --reaper.ShowConsoleMsg(" " .. list_pitch .. " " .. list_startppqpos .. " ".. list_endppqpos .. "\n");
    listNote = reaper.MIDI_EnumSelNotes(take, listNote);
end

currNote = 0;

--reaper.ShowConsoleMsg("\n#1\n");
while currNote > -1
  do
  
  nextNote = reaper.MIDI_EnumSelNotes(take, currNote);
  
  curr_retval, curr_selected, 
  curr_muted, curr_startppqpos, 
  curr_endppqpos, curr_chan, 
  curr_pitch, curr_vel = reaper.MIDI_GetNote(take,currNote);
  
  --reaper.ShowConsoleMsg("curr_retval");
  
  
  
  if nextNote > -1 then
  
  next_retval, next_selected, 
  next_muted, next_startppqpos, 
  next_endppqpos, next_chan, 
  next_pitch, next_vel = reaper.MIDI_GetNote(take,nextNote);
  
    if curr_pitch > next_pitch then
    
      --reaper.ShowConsoleMsg("\n |" .. curr_pitch .. " > " .. next_pitch.. "|");
      
      
      reaper.MIDI_DeleteNote(take, nextNote);
      reaper.MIDI_DeleteNote(take, currNote);
      
      
      swapB = reaper.MIDI_InsertNote(take, curr_selected, curr_muted, next_startppqpos, next_endppqpos, curr_chan, curr_pitch, curr_vel, true);
      swapA = reaper.MIDI_InsertNote(take, next_selected, next_muted, curr_startppqpos, curr_endppqpos, next_chan, next_pitch, next_vel, true);
      
      --reaper.ShowConsoleMsg(tostring(swapA));
      --reaper.ShowConsoleMsg(tostring(swapB));
      reaper.MIDI_Sort(take);
    
    end
  
  else
  
    --reaper.ShowConsoleMsg("\nno next note\n");
  
  end
  
  currNote = reaper.MIDI_EnumSelNotes(take, currNote);

  

end

listNote = 0;
while listNote > -1
  do
    list_retval, list_selected, 
    list_muted, list_startppqpos, 
    list_endppqpos, list_chan, 
    list_pitch, list_vel = reaper.MIDI_GetNote(take,listNote);
    --reaper.ShowConsoleMsg(" " .. list_pitch .. " " .. list_startppqpos .. " ".. list_endppqpos .. "\n");
    listNote = reaper.MIDI_EnumSelNotes(take, listNote);
end
