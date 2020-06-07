--[[
################################################################################
# 
# Copyright (c) 2014-2020 Ultraschall (http://ultraschall.fm)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
################################################################################
]] 


if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Functions-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string2 = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "API-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  if string=="" then string=10000 
  else 
    string=tonumber(string) 
    string=string+1
  end
  if string2=="" then string2=10000 
  else 
    string2=tonumber(string2)
    string2=string2+1
  end
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "Functions-Build", string, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "API-Build", string2, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")  
  ultraschall={} 
  dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
end
    
function ultraschall.ApiBetaFunctionsTest()
    -- tell the api, that the beta-functions are activated
    ultraschall.functions_beta_works="on"
end

  


--ultraschall.ShowErrorMessagesInReascriptConsole(true)

--ultraschall.WriteValueToFile()

--ultraschall.AddErrorMessage("func","parm","desc",2)




function ultraschall.GetProject_RenderOutputPath(projectfilename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_RenderOutputPath</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string render_output_directory = ultraschall.GetProject_RenderOutputPath(string projectfilename_with_path)</functioncall>
  <description>
    returns the output-directory for rendered files of a project.

    Doesn't return the correct output-directory for queued-projects!
    
    returns nil in case of an error
  </description>
  <parameters>
    string projectfilename_with_path - the projectfilename with path, whose renderoutput-directories you want to know
  </parameters>
  <retvals>
    string render_output_directory - the output-directory for projects
  </retvals>
  <chapter_context>
    Project-Files
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>render management, get, project, render, outputpath</tags>
</US_DocBloc>
]]
  if type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_RenderOutputPath", "projectfilename_with_path", "must be a string", -1) return nil end
  if reaper.file_exists(projectfilename_with_path)==false then ultraschall.AddErrorMessage("GetProject_RenderOutputPath", "projectfilename_with_path", "file does not exist", -2) return nil end
  local ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path)
  local QueueRendername=ProjectStateChunk:match("(QUEUED_RENDER_OUTFILE.-)\n")
  local QueueRenderProjectName=ProjectStateChunk:match("(QUEUED_RENDER_ORIGINAL_FILENAME.-)\n")
  local OutputRender, RenderPattern, RenderFile
  
  if QueueRendername~=nil then
    QueueRendername=QueueRendername:match(" \"(.-)\" ")
    QueueRendername=ultraschall.GetPath(QueueRendername)
  end
  
  if QueueRenderProjectName~=nil then
    QueueRenderProjectName=QueueRenderProjectName:match(" (.*)")
    QueueRenderProjectName=ultraschall.GetPath(QueueRenderProjectName)
  end


  RenderFile=ProjectStateChunk:match("(RENDER_FILE.-)\n")
  if RenderFile~=nil then
    RenderFile=RenderFile:match("RENDER_FILE (.*)")
    RenderFile=string.gsub(RenderFile,"\"","")
  end
  
  RenderPattern=ProjectStateChunk:match("(RENDER_PATTERN.-)\n")
  if RenderPattern~=nil then
    RenderPattern=RenderPattern:match("RENDER_PATTERN (.*)")
    if RenderPattern~=nil then
      RenderPattern=string.gsub(RenderPattern,"\"","")
    end
  end

  -- get the normal render-output-directory
  if RenderPattern~=nil and RenderFile~=nil then
    if ultraschall.DirectoryExists2(RenderFile)==true then
      OutputRender=RenderFile
    else
      OutputRender=ultraschall.GetPath(projectfilename_with_path)..ultraschall.Separator..RenderFile
    end
  elseif RenderFile~=nil then
    OutputRender=ultraschall.GetPath(RenderFile)    
  else
    OutputRender=ultraschall.GetPath(projectfilename_with_path)
  end


  -- get the potential RenderQueue-renderoutput-path
  -- not done yet...todo
  -- that way, I may be able to add the currently opened projects as well...
--[[
  if RenderPattern==nil and (RenderFile==nil or RenderFile=="") and
     QueueRenderProjectName==nil and QueueRendername==nil then
    QueueOutputRender=ultraschall.GetPath(projectfilename_with_path)
  elseif RenderPattern~=nil and RenderFile~=nil then
    if ultraschall.DirectoryExists2(RenderFile)==true then
      QueueOutputRender=RenderFile
    end
  end
  --]]
  
  OutputRender=string.gsub(OutputRender,"\\\\", "\\")
  
  return OutputRender, QueueOutputRender
end

--A="c:\\Users\\meo\\Desktop\\trss\\20Januar2019\\rec\\rec3.RPP"

--B,C=ultraschall.GetProject_RenderOutputPath()


function ultraschall.ResolveRenderPattern(renderpattern)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ResolveRenderPattern</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string resolved_renderpattern = ultraschall.ResolveRenderPattern(string render_pattern)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    resolves a render-pattern into its render-filename(without extension).

    returns nil in case of an error    
  </description>
  <parameters>
    string render_pattern - the render-pattern, that you want to resolve into its render-filename
  </parameters>
  <retvals>
    string resolved_renderpattern - the resolved renderpattern, that is used for a render-filename.
                                  - just add extension and path to it.
                                  - Stems will be rendered to path/resolved_renderpattern-XXX.ext
                                  -    where XXX is a number between 001(usually for master-track) and 999
  </retvals>
  <chapter_context>
    Rendering Projects
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>rendermanagement, resolve, renderpattern, filename</tags>
</US_DocBloc>
]]
  if type(renderpattern)~="string" then ultraschall.AddErrorMessage("ResolveRenderPattern", "renderpattern", "must be a string", -1) return nil end
  if renderpattern=="" then return "" end
  local TempProject=ultraschall.Api_Path.."misc/tempproject.RPP"
  local TempFolder=ultraschall.Api_Path.."misc/"
  TempFolder=string.gsub(TempFolder, "\\", ultraschall.Separator)
  TempFolder=string.gsub(TempFolder, "/", ultraschall.Separator)
  
  ultraschall.SetProject_RenderFilename(TempProject, "")
  ultraschall.SetProject_RenderPattern(TempProject, renderpattern)
  ultraschall.SetProject_RenderStems(TempProject, 0)
  
  reaper.Main_OnCommand(41929,0)
  reaper.Main_openProject(TempProject)
  
  A,B=ultraschall.GetProjectStateChunk()
  reaper.Main_SaveProject(0,false)
  reaper.Main_OnCommand(40860,0)
  if B==nil then B="" end
  
  count, split_string = ultraschall.SplitStringAtLineFeedToArray(B)

  for i=1, count do
    split_string[i]=split_string[i]:match("\"(.-)\"")
  end
  if split_string[1]==nil then split_string[1]="" end
  return string.gsub(split_string[1], TempFolder, ""):match("(.-)%.")
end

--for i=1, 10 do
--  O=ultraschall.ResolveRenderPattern("I would find a way $day")
--end

ultraschall.ShowLastErrorMessage()


function ultraschall.InsertMediaItemArray2(position, MediaItemArray, trackstring)
  
--ToDo: Die Möglichkeit die Items in andere Tracks einzufügen. Wenn trackstring 1,3,5 ist, die Items im MediaItemArray
--      in 1,2,3 sind, dann landen die Items aus track 1 in track 1, track 2 in track 3, track 3 in track 5
--
-- Beta 3 Material
  
  if type(position)~="number" then return -1 end
  local trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 then return -1 end
  local count=1
  local i
  if type(MediaItemArray)~="table" then return -1 end
  local NewMediaItemArray={}
  local _count, individual_values = ultraschall.CSV2IndividualLinesAsArray(trackstring) 
  local ItemStart=reaper.GetProjectLength()+1
  while MediaItemArray[count]~=nil do
    local ItemStart_temp=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    if ItemStart>ItemStart_temp then ItemStart=ItemStart_temp end
    count=count+1
  end
  count=1
  while MediaItemArray[count]~=nil do
    local ItemStart_temp=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    local MediaTrack=reaper.GetMediaItem_Track(MediaItemArray[count])
    --nur einfügen, wenn mediaitem aus nem Track stammt, der in trackstring vorkommt
    i=1
    while individual_values[i]~=nil do
--    reaper.MB("Yup"..i,individual_values[i],0)
    if reaper.GetTrack(0,individual_values[i]-1)==reaper.GetMediaItem_Track(MediaItemArray[count]) then 
    NewMediaItemArray[count]=ultraschall.InsertMediaItem_MediaItem(position+(ItemStart_temp-ItemStart),MediaItemArray[count],MediaTrack)
    end
    i=i+1
    end
    count=count+1
  end  
--  TrackArray[count]=reaper.GetMediaItem_Track(MediaItem)
--  MediaItem reaper.AddMediaItemToTrack(MediaTrack tr)
end

--C,CC=ultraschall.GetAllMediaItemsBetween(1,60,"1,3",false)
--A,B=reaper.GetItemStateChunk(CC[1], "", true)
--reaper.ShowConsoleMsg(B)
--ultraschall.InsertMediaItemArray(82, CC, "4,5")

--tr = reaper.GetTrack(0, 1)
--MediaItem=reaper.AddMediaItemToTrack(tr)
--Aboolean=reaper.SetItemStateChunk(CC[1], PUH, true)
--PCM_source=reaper.PCM_Source_CreateFromFile("C:\\Recordings\\01-te.flac")
--boolean=reaper.SetMediaItemTake_Source(MediaItem_Take, PCM_source)
--reaper.SetMediaItemInfo_Value(MediaItem, "D_POSITION", "1")
--ultraschall.InsertMediaItemArray(0,CC)


function ultraschall.RippleDrag_Start(position, trackstring, deltalength)
  A,MediaItemArray = ultraschall.GetMediaItemsAtPosition(position, trackstring)
  ultraschall.ChangeDeltaLengthOfMediaItems_FromArray(MediaItemArray, deltalength)
  C,CC=ultraschall.GetAllMediaItemsBetween(position, reaper.GetProjectLength(), trackstring, false)
  for i=C, 1, -1 do
    for j=A, 1, -1 do
--      reaper.MB(j,"",0)
      if MediaItemArray[j]==CC[i] then  table.remove(CC, i) end 
    end
  end
  ultraschall.ChangePositionOfMediaItems_FromArray(CC, deltalength)
end

--ultraschall.RippleDrag_Start(13,"1,2,3",-1)

function ultraschall.RippleDragSection_Start(startposition, endposition, trackstring, newoffset)
end

function ultraschall.RippleDrag_StartOffset(position, trackstring, newoffset)
--unfertig und buggy
  A,MediaItemArray = ultraschall.GetMediaItemsAtPosition(position, trackstring)
  ultraschall.ChangeOffsetOfMediaItems_FromArray(MediaItemArray, newoffset)
  ultraschall.ChangeDeltaLengthOfMediaItems_FromArray(MediaItemArray, -newoffset)
  C,CC=ultraschall.GetAllMediaItemsBetween(position, reaper.GetProjectLength(), trackstring, false)
  for i=C, 1, -1 do
    for j=A, 1, -1 do
--      reaper.MB(j,"",0)
      if MediaItemArray[j]==CC[i] then  table.remove(CC, i) end 
    end
  end
  ultraschall.ChangePositionOfMediaItems_FromArray(CC, newoffset)
end

--ultraschall.RippleDrag_StartOffset(13,"2",10)

--A=ultraschall.CreateRenderCFG_MP3CBR(1, 4, 10)
--B=ultraschall.CreateRenderCFG_MP3CBR(1, 10, 10)
--L,L2,L3,L4=ultraschall.RenderProject_RenderCFG(nil, "c:\\Reaper-Internal-Docs.mp3", 0, 10, false, true, true,A)
--L,L1,L2,L3,L4=ultraschall.RenderProjectRegions_RenderCFG(nil, "c:\\Reaper-Internal-Docs.mp3", 1, false, false, true, true,A)
--L=reaper.IsProjectDirty(0)

--outputchannel, post_pre_fader, volume, pan, mute, phase, source, unknown, automationmode = ultraschall.GetTrackHWOut(0, 1)

--count, MediaItemArray_selected = ultraschall.GetAllSelectedMediaItems() -- get old selection
--A=ultraschall.PutMediaItemsToClipboard_MediaItemArray(MediaItemArray_selected)

---------------------------
---- Routing Snapshots ----
---------------------------

function ultraschall.SetRoutingSnapshot(snapshot_nr)
end

function ultraschall.RecallRoutingSnapshot(snapshot_nr)
end

function ultraschall.ClearRoutingSnapshot(snapshot_nr)
end




function ultraschall.RippleDragSection_StartOffset(position,trackstring)
end

function ultraschall.RippleDrag_End(position,trackstring)

end

function ultraschall.RippleDragSection_End(position,trackstring)
end



--ultraschall.ShowLastErrorMessage()

function ultraschall.GetProjectReWireSlave(projectfilename_with_path)
--To Do
-- ProjectSettings->Advanced->Rewire Slave Settings
end

function ultraschall.GetLastEnvelopePoint(Envelopeobject)
end

function ultraschall.GetAllTrackEnvelopes_EnvelopePointArray(tracknumber)
--returns all track-envelopes from tracknumber as EnvelopePointArray
end

function ultraschall.GetAllTrackEnvelopes_EnvelopePointArray2(MediaTrack)
--returns all track-envelopes from MediaTrack as EnvelopePointArray
end



function ultraschall.OnlyMediaItemsInBothMediaItemArrays()
end

function ultraschall.OnlyMediaItemsInOneMediaItemArray()
end

function ultraschall.GetMediaItemTake_StateChunk(MediaItem, idx)
--returns an rppxml-statechunk for a MediaItemTake (not existing yet in Reaper!), for the idx'th take of MediaItem

--number reaper.GetMediaItemTakeInfo_Value(MediaItem_Take take, string parmname)
--MediaItem reaper.GetMediaItemTake_Item(MediaItem_Take take)

--[[Get parent item of media item take

integer reaper.GetMediaItemTake_Peaks(MediaItem_Take take, number peakrate, number starttime, integer numchannels, integer numsamplesperchannel, integer want_extra_type, reaper.array buf)
Gets block of peak samples to buf. Note that the peak samples are interleaved, but in two or three blocks (maximums, then minimums, then extra). Return value has 20 bits of returned sample count, then 4 bits of output_mode (0xf00000), then a bit to signify whether extra_type was available (0x1000000). extra_type can be 115 ('s') for spectral information, which will return peak samples as integers with the low 15 bits frequency, next 14 bits tonality.

PCM_source reaper.GetMediaItemTake_Source(MediaItem_Take take)
Get media source of media item take

MediaTrack reaper.GetMediaItemTake_Track(MediaItem_Take take)
Get parent track of media item take


MediaItem_Take reaper.GetMediaItemTakeByGUID(ReaProject project, string guidGUID)
--]]
end

function ultraschall.GetAllMediaItemTake_StateChunks(MediaItem)
--returns an array with all rppxml-statechunk for all MediaItemTakes of a MediaItem.
end


function ultraschall.SetReaScriptConsole_FontStyle(style)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SetReaScriptConsole_FontStyle</slug>
    <requires>
      Ultraschall=4.1
      Reaper=5.965
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.SetReaScriptConsole_FontStyle(integer style)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      If the ReaScript-console is opened, you can change the font-style of it.
      You can choose between 19 different styles, with 3 being of fixed character length. It will change the next time you output text to the ReaScriptConsole.
      
      If you close and reopen the Console, you need to set the font-style again!
      
      You can only have one style active in the console!
      
      Returns false in case of an error
    </description>
    <retvals>
      boolean retval - true, displaying was successful; false, displaying wasn't successful
    </retvals>
    <parameters>
      integer length - the font-style used. There are 19 different ones.
                      - fixed-character-length:
                      -     1,  fixed, console
                      -     2,  fixed, console alt
                      -     3,  thin, fixed
                      - 
                      - normal from large to small:
                      -     4-8
                      -     
                      - bold from largest to smallest:
                      -     9-14
                      - 
                      - thin:
                      -     15, thin
                      - 
                      - underlined:
                      -     16, underlined, thin
                      -     17, underlined
                      -     18, underlined
                      - 
                      - symbol:
                      -     19, symbol
    </parameters>
    <chapter_context>
      User Interface
      Miscellaneous
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>ultraschall_functions_engine.lua</source_document>
    <tags>user interface, reascript, console, font, style</tags>
  </US_DocBloc>
  ]]
  if math.type(style)~="integer" then ultraschall.AddErrorMessage("SetReaScriptConsole_FontStyle", "style", "must be an integer", -1) return false end
  if style>19 or style<1 then ultraschall.AddErrorMessage("SetReaScriptConsole_FontStyle", "style", "must be between 1 and 17", -2) return false end
  local reascript_console_hwnd = ultraschall.GetReaScriptConsoleWindow()
  if reascript_console_hwnd==nil then return false end
  local styles={32,33,36,31,214,37,218,1606,4373,3297,220,3492,3733,3594,35,1890,2878,3265,4392}
  local Textfield=reaper.JS_Window_FindChildByID(reascript_console_hwnd, 1177)
  reaper.JS_WindowMessage_Send(Textfield, "WM_SETFONT", styles[style] ,0,0,0)
  return true
end
--reaper.ClearConsole()
--ultraschall.SetReaScriptConsole_FontStyle(1)
--reaper.ShowConsoleMsg("ABCDEFGhijklmnop\n123456789.-,!\"§$%&/()=\n----------\nOOOOOOOOOO")




--a,b=reaper.EnumProjects(-1,"")
--A=ultraschall.ReadFullFile(b)

--Mespotine



--[[
hwnd = ultraschall.GetPreferencesHWND()
hwnd2 = reaper.JS_Window_FindChildByID(hwnd, 1110)

--reaper.JS_Window_Move(hwnd2, 110,11)


for i=-1000, 10 do
  A,B,C,D=reaper.JS_WindowMessage_Post(hwnd2, "TVHT_ONITEM", i,i,i,i)
end
--]]


function ultraschall.get_action_context_MediaItemDiff(exlude_mousecursorsize, x, y)
-- TODO:: nice to have feature: when mouse is above crossfades between two adjacent items, return this state as well as a boolean
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>get_action_context_MediaItemDiff</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>MediaItem MediaItem, MediaItem_Take MediaItem_Take, MediaItem MediaItem_unlocked, boolean Item_moved, number StartDiffTime, number EndDiffTime, number LengthDiffTime, number OffsetDiffTime = ultraschall.get_action_context_MediaItemDiff(optional boolean exlude_mousecursorsize, optional integer x, optional integer y)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the currently clicked MediaItem, Take as well as the difference of position, end, length and startoffset since last time calling this function.
    Good for implementing ripple-drag/editing-functions, whose position depends on changes in the currently clicked MediaItem.
    Repeatedly call this (e.g. in a defer-cycle) to get all changes made, during dragging position, length or offset of the MediaItem underneath mousecursor.
    
    This function takes into account the size of the start/end-drag-mousecursor, that means: if mouse-position is within 3 pixels before start/after end of the item, it will get the correct MediaItem. 
    This is a workaround, as the mouse-cursor changes to dragging and can still affect the MediaItem, even though the mouse at this position isn't above a MediaItem anymore.
    To be more strict, set exlude_mousecursorsize to true. That means, it will only detect MediaItems directly beneath the mousecursor. If the mouse isn't above a MediaItem, this function will ignore it, even if the mouse could still affect the MediaItem.
    If you don't understand, what that means: simply omit exlude_mousecursorsize, which should work in almost all use-cases. If it doesn't work as you want, try setting it to true and see, whether it works now.    
    
    returns nil in case of an error
  </description>
  <retvals>
    MediaItem MediaItem - the MediaItem at the current mouse-position; nil if not found
    MediaItem_Take MediaItem_Take - the MediaItem_Take underneath the mouse-cursor
    MediaItem MediaItem_unlocked - if the MediaItem isn't locked, you'll get a MediaItem here. If it is locked, this retval is nil
    boolean Item_moved - true, the item was moved; false, only a part(either start or end or offset) of the item was moved
    number StartDiffTime - if the start of the item changed, this is the difference;
                         -   positive, the start of the item has been changed towards the end of the project
                         -   negative, the start of the item has been changed towards the start of the project
                         -   0, no changes to the itemstart-position at all
    number EndDiffTime - if the end of the item changed, this is the difference;
                         -   positive, the end of the item has been changed towards the end of the project
                         -   negative, the end of the item has been changed towards the start of the project
                         -   0, no changes to the itemend-position at all
    number LengthDiffTime - if the length of the item changed, this is the difference;
                         -   positive, the length is longer
                         -   negative, the length is shorter
                         -   0, no changes to the length of the item
    number OffsetDiffTime - if the offset of the item-take has changed, this is the difference;
                         -   positive, the offset has been changed towards the start of the project
                         -   negative, the offset has been changed towards the end of the project
                         -   0, no changes to the offset of the item-take
                         - Note: this is the offset of the take underneath the mousecursor, which might not be the same size, as the MediaItem itself!
                         - So changes to the offset maybe changes within the MediaItem or the start of the MediaItem!
                         - This could be important, if you want to affect other items with rippling.
  </retvals>
  <parameters>
    optional boolean exlude_mousecursorsize - false or nil, get the item underneath, when it can be affected by the mouse-cursor(dragging etc): when in doubt, use this
                                            - true, get the item underneath the mousecursor only, when mouse is strictly above the item,
                                            -       which means: this ignores the item when mouse is not above it, even if the mouse could affect the item
    optional integer x - nil, use the current x-mouseposition; otherwise the x-position in pixels
    optional integer y - nil, use the current y-mouseposition; otherwise the y-position in pixels
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, get, action, context, difftime, item, mediaitem, offset, length, end, start, locked, unlocked</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "x", "must be either nil or an integer", -1) return nil end
  if y~=nil and math.type(y)~="integer" then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "y", "must be either nil or an integer", -2) return nil end
  if (x~=nil and y==nil) or (y~=nil and x==nil) then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "x or y", "must be either both nil or both an integer!", -3) return nil end
  local MediaItem, MediaItem_Take, MediaItem_unlocked
  local StartDiffTime, EndDiffTime, Item_moved, LengthDiffTime, OffsetDiffTime
  if x==nil and y==nil then x,y=reaper.GetMousePosition() end
  MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x, y, true)
  MediaItem_unlocked = reaper.GetItemFromPoint(x, y, false)
  if MediaItem==nil and exlude_mousecursorsize~=true then
    MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x+3, y, true)
    MediaItem_unlocked = reaper.GetItemFromPoint(x+3, y, false)
  end
  if MediaItem==nil and exlude_mousecursorsize~=true then
    MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x-3, y, true)
    MediaItem_unlocked = reaper.GetItemFromPoint(x-3, y, false)
  end
  
  -- crossfade-stuff
  -- example-values for crossfade-parts
  -- Item left: 811 -> 817 , Item right: 818 -> 825
  --               6           7
  -- first:  get, if the next and previous items are at each other/crossing; if nothing -> no crossfade
  -- second: get, if within the aforementioned pixel-ranges, there's another item
  --              6 pixels for the one before the current item
  --              7 pixels for the next item
  -- third: if yes: crossfade-area, else: no crossfade area
  --[[
  -- buggy: need to know the length of the crossfade, as the aforementioned attempt would work only
  --        if the items are adjacent but not if they overlap
  --        also need to take into account, what if zoomed out heavily, where items might be only
  --        a few pixels wide
  
  if MediaItem~=nil then
    ItemNumber = reaper.GetMediaItemInfo_Value(MediaItem, "IP_ITEMNUMBER")
    ItemTrack  = reaper.GetMediaItemInfo_Value(MediaItem, "P_TRACK")
    ItemBefore = reaper.GetTrackMediaItem(ItemTrack, ItemNumber-1)
    ItemAfter = reaper.GetTrackMediaItem(ItemTrack, ItemNumber+1)
    if ItemBefore~=nil then
      ItemBefore_crossfade=reaper.GetMediaItemInfo_Value(ItemBefore, "D_POSITION")+reaper.GetMediaItemInfo_Value(ItemBefore, "D_LENGTH")>=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
    end
  end
  --]]
  
  if ultraschall.get_action_context_MediaItem_old~=MediaItem then
    StartDiffTime=0
    EndDiffTime=0
    LengthDiffTime=0
    OffsetDiffTime=0
    if MediaItem~=nil then
      ultraschall.get_action_context_MediaItem_Start=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_End=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")+reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_Length=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
      ultraschall.get_action_context_MediaItem_Offset=reaper.GetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS")
    end
  else
    if MediaItem~=nil then      
      StartDiffTime=ultraschall.get_action_context_MediaItem_Start
      EndDiffTime=ultraschall.get_action_context_MediaItem_End
      LengthDiffTime=ultraschall.get_action_context_MediaItem_Length
      OffsetDiffTime=ultraschall.get_action_context_MediaItem_Offset
      
      ultraschall.get_action_context_MediaItem_Start=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_End=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")+reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_Length=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
      ultraschall.get_action_context_MediaItem_Offset=reaper.GetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS")
      
      Item_moved=(ultraschall.get_action_context_MediaItem_Start~=StartDiffTime
              and ultraschall.get_action_context_MediaItem_End~=EndDiffTime)
              
      StartDiffTime=ultraschall.get_action_context_MediaItem_Start-StartDiffTime
      EndDiffTime=ultraschall.get_action_context_MediaItem_End-EndDiffTime
      LengthDiffTime=ultraschall.get_action_context_MediaItem_Length-LengthDiffTime
      OffsetDiffTime=ultraschall.get_action_context_MediaItem_Offset-OffsetDiffTime
      
    end    
  end
  ultraschall.get_action_context_MediaItem_old=MediaItem

  return MediaItem, MediaItem_Take, MediaItem_unlocked, Item_moved, StartDiffTime, EndDiffTime, LengthDiffTime, OffsetDiffTime
end

--a,b,c,d,e,f,g,h,i=ultraschall.get_action_context_MediaItemDiff(exlude_mousecursorsize, x, y)



function ultraschall.TracksToColorPattern(colorpattern, startingcolor, direction)
end


function ultraschall.GetTrackPositions()
  -- only possible, when tracks can be seen...
  -- no windows above them are allowed :/
  local Arrange_view, timeline, TrackControlPanel = ultraschall.GetHWND_ArrangeViewAndTimeLine()
  local retval, left, top, right, bottom = reaper.JS_Window_GetClientRect(Arrange_view)
  local Tracks={}
  local x=left+2
  local OldItem=nil
  local Counter=0
  local B
  for y=top, bottom do
    A,B=reaper.GetTrackFromPoint(x,y)
    if OldItem~=A and A~=nil then
      Counter=Counter+1
      Tracks[Counter]={}
      Tracks[Counter][tostring(A)]=A
      Tracks[Counter]["Track_Top"]=y
      Tracks[Counter]["Track_Bottom"]=y
      OldItem=A
    elseif A==OldItem and A~=nil and B==0 then
      Tracks[Counter]["Track_Bottom"]=y
    elseif A==OldItem and A~=nil and B==1 then
      if Tracks[Counter]["Env_Top"]==nil then
        Tracks[Counter]["Env_Top"]=y
      end
      Tracks[Counter]["Env_Bottom"]=y
    elseif A==OldItem and A~=nil and B==2 then
      if Tracks[Counter]["TrackFX_Top"]==nil then
        Tracks[Counter]["TrackFX_Top"]=y
      end
      Tracks[Counter]["TrackFX_Bottom"]=y
    end
  end
  return Counter, Tracks
end

--A,B=ultraschall.GetTrackPositions()

function ultraschall.GetAllTrackHeights()
  -- can't calculate the dependency between zoom and trackheight... :/
  HH=reaper.SNM_GetIntConfigVar("defvzoom", -999)
  Heights={}
  for i=0, reaper.CountTracks(0) do
    Heights[i+1], heightstate2, unknown = ultraschall.GetTrackHeightState(i)
   -- if Heights[i+1]==0 then Heights[i+1]=HH end
  end

end

--ultraschall.GetAllTrackHeights()



--[[
A=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--print2(22)
B=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--print2(22)
C=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
D=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
E=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
F=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
G=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
H=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--]]


function ultraschall.GetTrackEnvelope_ClickState()
-- how to get the connection to clicked envelopepoint, when mouse moves away from the item while retaining click(moving underneath the item for dragging)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackEnvelope_ClickState</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.981
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean clickstate, number position, MediaTrack track, TrackEnvelope envelope, integer EnvelopePointIDX = ultraschall.GetTrackEnvelope_ClickState()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the currently clicked Envelopepoint and TrackEnvelope, as well as the current timeposition.
    
    Works only, if the mouse is above the EnvelopePoint while having it clicked!
    
    Returns false, if no envelope is clicked at
  </description>
  <retvals>
    boolean clickstate - true, an envelopepoint has been clicked; false, no envelopepoint has been clicked
    number position - the position, at which the mouse has clicked
    MediaTrack track - the track, from which the envelope and it's corresponding point is taken from
    TrackEnvelope envelope - the TrackEnvelope, in which the clicked envelope-point lies
    integer EnvelopePointIDX - the id of the clicked EnvelopePoint
  </retvals>
  <chapter_context>
    Envelope Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope management, get, clicked, envelope, envelopepoint</tags>
</US_DocBloc>
--]]
  -- TODO: Has an issue, if the mousecursor drags the item, but moves above or underneath the item(if item is in first or last track).
  --       Even though the item is still clicked, it isn't returned as such.
  --       The ConfigVar uiscale supports dragging information, but the information which item has been clicked gets lost somehow
  --local B, Track, Info, TrackEnvelope, TakeEnvelope, X, Y
  
  B=reaper.SNM_GetDoubleConfigVar("uiscale", -999)
  if tostring(B)=="-1.#QNAN" then
    ultraschall.EnvelopeClickState_OldTrack=nil
    ultraschall.EnvelopeClickState_OldInfo=nil
    ultraschall.EnvelopeClickState_OldTrackEnvelope=nil
    ultraschall.EnvelopeClickState_OldTakeEnvelope=nil
    return 1
  else
    Track=ultraschall.EnvelopeClickState_OldTrack
    Info=ultraschall.EnvelopeClickState_OldInfo
    TrackEnvelope=ultraschall.EnvelopeClickState_OldTrackEnvelope
    TakeEnvelope=ultraschall.EnvelopeClickState_OldTakeEnvelope
  end
  
  if Track==nil then
    X,Y=reaper.GetMousePosition()
    Track, Info = reaper.GetTrackFromPoint(X,Y)
    ultraschall.EnvelopeClickState_OldTrack=Track
    ultraschall.EnvelopeClickState_OldInfo=Info
  end
  
  -- BUggy, til the end
  -- Ich will hier mir den alten Take auch noch merken, und danach herausfinden, welcher EnvPoint im Envelope existiert, der
  --   a) an der Zeit existiert und
  --   b) selektiert ist
  -- damit könnte ich eventuell es schaffen, die Info zurückzugeben, welcher Envelopepoint gerade beklickt wird.
  if TrackEnvelope==nil then
    reaper.BR_GetMouseCursorContext()
    TrackEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
    ultraschall.EnvelopeClickState_OldTrackEnvelope=TrackEnvelope
  end
  
  if TakeEnvelope==nil then
    reaper.BR_GetMouseCursorContext()
    TakeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
    ultraschall.EnvelopeClickState_OldTakeEnvelope=TakeEnvelope
  end
  --[[
  
  
  
  reaper.BR_GetMouseCursorContext()
  local TrackEnvelope, TakeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
  
  if Track==nil then Track=ultraschall.EnvelopeClickState_OldTrack end
  if Track~=nil then ultraschall.EnvelopeClickState_OldTrack=Track end
  if TrackEnvelope~=nil then ultraschall.EnvelopeClickState_OldTrackEnvelope=TrackEnvelope end
  if TrackEnvelope==nil then TrackEnvelope=ultraschall.EnvelopeClickState_OldTrackEnvelope end
  if TakeEnvelope~=nil then ultraschall.EnvelopeClickState_OldTakeEnvelope=TakeEnvelope end
  if TakeEnvelope==nil then TakeEnvelope=ultraschall.EnvelopeClickState_OldTakeEnvelope end
  
  --]]
  --[[
  if TakeEnvelope==true or TrackEnvelope==nil then return false end
  local TimePosition=ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition())
  local EnvelopePoint=
  return true, TimePosition, Track, TrackEnvelope, EnvelopePoint
  --]]
  if TrackEnvelope==nil then TrackEnvelope=TakeEnvelope end
  return true, ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition()), Track, TrackEnvelope--, reaper.GetEnvelopePointByTime(TrackEnvelope, TimePosition)
end


function ultraschall.SetLiceCapExe(PathToLiceCapExecutable)
-- works on Mac too?
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetLiceCapExe</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetLiceCapExe(string PathToLiceCapExecutable)</functioncall>
  <description>
    Sets the path and filename of the LiceCap-executable

    Note: Doesn't work on Linux, as there isn't a Linux-port of LiceCap yet.
    
    Returns false in case of error.
  </description>
  <parameters>
    string SetLiceCapExe - the LiceCap-executable with path
  </parameters>
  <retvals>
    boolean retval - false in case of error; true in case of success
  </retvals>
  <chapter_context>
    API-Helper functions
    LiceCap
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, set, licecap, executable</tags>
</US_DocBloc>
]]  
  if type(PathToLiceCapExecutable)~="string" then ultraschall.AddErrorMessage("SetLiceCapExe", "PathToLiceCapExecutable", "Must be a string", -1) return false end
  if reaper.file_exists(PathToLiceCapExecutable)==false then ultraschall.AddErrorMessage("SetLiceCapExe", "PathToLiceCapExecutable", "file not found", -2) return false end
  local A,B=reaper.BR_Win32_WritePrivateProfileString("REAPER", "licecap_path", PathToLiceCapExecutable, reaper.get_ini_file())
  return A
end

--O=ultraschall.SetLiceCapExe("c:\\Program Files (x86)\\LICEcap\\LiceCap.exe")

function ultraschall.SetupLiceCap(output_filename, title, titlems, x, y, right, bottom, fps, gifloopcount, stopafter, prefs)
-- works on Mac too?
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetupLiceCap</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetupLiceCap(string output_filename, string title, integer titlems, integer x, integer y, integer right, integer bottom, integer fps, integer gifloopcount, integer stopafter, integer prefs)</functioncall>
  <description>
    Sets up an installed LiceCap-instance.
    
    To choose the right LiceCap-version, run the action 41298 - Run LICEcap (animated screen capture utility)
    
    Note: Doesn't work on Linux, as there isn't a Linux-port of LiceCap yet.
    
    Returns false in case of error.
  </description>
  <parameters>
    string output_filename - the output-file; you can choose whether it shall be a gif or an lcf by giving it the accompanying extension "mylice.gif" or "milice.lcf"; nil, keep the current outputfile
    string title - the title, which shall be shown at the beginning of the licecap; newlines will be exchanged by spaces, as LiceCap doesn't really support newlines; nil, keep the current title
    integer titlems - how long shall the title be shown, in milliseconds; nil, keep the current setting
    integer x - the x-position of the LiceCap-window in pixels; nil, keep the current setting
    integer y - the y-position of the LiceCap-window in pixels; nil, keep the current setting
    integer right - the right side-position of the LiceCap-window in pixels; nil, keep the current setting
    integer bottom - the bottom-position of the LiceCap-window in pixels; nil, keep the current setting
    integer fps - the maximum frames per seconds, the LiceCap shall have; nil, keep the current setting
    integer gifloopcount - how often shall the gif be looped?; 0, infinite looping; nil, keep the current setting
    integer stopafter - stop recording after xxx milliseconds; nil, keep the current setting
    integer prefs - the preferences-settings of LiceCap, which is a bitfield; nil, keep the current settings
                  - &1 - display in animation: title frame - checkbox
                  - &2 - Big font - checkbox
                  - &4 - display in animation: mouse button press - checkbox
                  - &8 - display in animation: elapsed time - checkbox
                  - &16 - Ctrl+Alt+P pauses recording - checkbox
                  - &32 - Use .GIF transparency for smaller files - checkbox
                  - &64 - Automatically stop after xx seconds - checkbox           
  </parameters>
  <retvals>
    boolean retval - false in case of error; true in case of success
  </retvals>
  <chapter_context>
    API-Helper functions
    LiceCap
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, licecap, setup</tags>
</US_DocBloc>
]]  
  if output_filename~=nil and type(output_filename)~="string" then ultraschall.AddErrorMessage("SetupLiceCap", "output_filename", "Must be a string", -2) return false end
  if title~=nil and type(title)~="string" then ultraschall.AddErrorMessage("SetupLiceCap", "title", "Must be a string", -3) return false end
  if titlems~=nil and math.type(titlems)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "titlems", "Must be an integer", -4) return false end
  if x~=nil and math.type(x)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "x", "Must be an integer", -5) return false end
  if y~=nil and math.type(y)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "y", "Must be an integer", -6) return false end
  if right~=nil and math.type(right)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "right", "Must be an integer", -7) return false end
  if bottom~=nil and math.type(bottom)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "bottom", "Must be an integer", -8) return false end
  if fps~=nil and math.type(fps)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "fps", "Must be an integer", -9) return false end
  if gifloopcount~=nil and math.type(gifloopcount)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "gifloopcount", "Must be an integer", -10) return false end
  if stopafter~=nil and math.type(stopafter)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "stopafter", "Must be an integer", -11) return false end
  if prefs~=nil and math.type(prefs)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "prefs", "Must be an integer", -12) return false end
  
  local CC
  local A,B=reaper.BR_Win32_GetPrivateProfileString("REAPER", "licecap_path", -1, reaper.get_ini_file())
  if B=="-1" or reaper.file_exists(B)==false then ultraschall.AddErrorMessage("SetupLiceCap", "", "LiceCap not installed, please run action \"Run LICEcap (animated screen capture utility)\" to set up LiceCap", -1) return false end
  local Path, File=ultraschall.GetPath(B)
  if reaper.file_exists(Path.."/".."licecap.ini")==false then ultraschall.AddErrorMessage("SetupLiceCap", "", "Couldn't find licecap.ini in LiceCap-path. Is LiceCap really installed?", -13) return false end
  if output_filename~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "lastfn", output_filename, Path.."/".."licecap.ini") end
  if title~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "title", string.gsub(title,"\n"," "), Path.."/".."licecap.ini") end
  if titlems~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "titlems", titlems, Path.."/".."licecap.ini") end
  
  local retval, oldwnd_r=reaper.BR_Win32_GetPrivateProfileString("licecap", "wnd_r", -1, Path.."/".."licecap.ini")  
  if x==nil then x=oldwnd_r:match("(.-) ") end
  if y==nil then y=oldwnd_r:match(".- (.-) ") end
  if right==nil then right=oldwnd_r:match(".- .- (.-) ") end
  if bottom==nil then bottom=oldwnd_r:match(".- .- .- (.*)") end
  
  CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "wnd_r", x.." "..y.." "..right.." "..bottom, Path.."/".."licecap.ini")
  if fps~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "maxfps", fps, Path.."/".."licecap.ini") end
  if gifloopcount~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "gifloopcnt", gifloopcount, Path.."/".."licecap.ini") end
  if stopafter~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "stopafter", stopafter, Path.."/".."licecap.ini") end
  if prefs~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "prefs", prefs, Path.."/".."licecap.ini") end
  
  return true
end


function ultraschall.StartLiceCap(autorun)
-- doesn't work, as I can't click the run and save-buttons
-- maybe I need to add that to the LiceCap-codebase myself...somehow
  reaper.Main_OnCommand(41298, 0)  
  O=0
  while reaper.JS_Window_Find("LICEcap v", false)==nil do
    O=O+1
    if O==1000000 then break end
  end
  local HWND=reaper.JS_Window_Find("LICEcap v", false)
  reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWND, 1001), "WM_LBUTTONDOWN", 1,0,0,0)
  reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWND, 1001), "WM_LBUTTONUP", 1,0,0,0)

  HWNDA0=reaper.JS_Window_Find("Choose file for recording", false)

--[[    
  O=0
  while reaper.JS_Window_Find("Choose file for recording", false)==nil do
    O=O+1
    if O==100 then break end
  end

  HWNDA=reaper.JS_Window_Find("Choose file for recording", false)
  TIT=reaper.JS_Window_GetTitle(HWNDA)
  
  for i=-1000, 10000 do
    if reaper.JS_Window_FindChildByID(HWNDA, i)~=nil then
      print_alt(i, reaper.JS_Window_GetTitle(reaper.JS_Window_FindChildByID(HWNDA, i)))
    end
  end

  print(reaper.JS_Window_GetTitle(reaper.JS_Window_FindChildByID(HWNDA, 1)))

  for i=0, 100000 do
    AA=reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWNDA, 1), "WM_LBUTTONDOWN", 1,0,0,0)
    BB=reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWNDA, 1), "WM_LBUTTONUP", 1,0,0,0)
  end
  
  return HWND
  --]]
  
  ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/LiceCapSave.lua", [[
    dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
    P=0
    
    function main3()
      LiceCapWinPreRoll=reaper.JS_Window_Find(" [stopped]", false)
      LiceCapWinPreRoll2=reaper.JS_Window_Find("LICEcap", false)
      
      if LiceCapWinPreRoll~=nil and LiceCapWinPreRoll2~=nil and LiceCapWinPreRoll2==LiceCapWinPreRoll then
        reaper.JS_Window_Destroy(LiceCapWinPreRoll)
        print("HuiTja", reaper.JS_Window_GetTitle(LiceCapWinPreRoll))
      else
        reaper.defer(main3)
      end
    end
    
    function main2()
      print("HUI:", P)
      A=reaper.JS_Window_Find("Choose file for recording", false)
      if A~=nil and P<20 then  
        P=P+1
        print_alt(reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONDOWN", 1,1,1,1))
        print_alt(reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONUP", 1,1,1,1))
        reaper.defer(main2)
      elseif P~=0 and A==nil then
        reaper.defer(main3)
      else
        reaper.defer(main2)
      end
    end
    
    
    main2()
    ]])
    local retval, script_identifier = ultraschall.Main_OnCommandByFilename(ultraschall.API_TempPath.."/LiceCapSave.lua")
end

--ultraschall.StartLiceCap(autorun)

--ultraschall.SetupLiceCap("Hula", "Hachgotterl\nahh", 20, 1, 2, 3, 4, 123, 1, 987, 64)
--ultraschall.SetupLiceCap("Hurtz.lcf")



function ultraschall.SaveProjectAs(filename_with_path, fileformat, overwrite, create_subdirectory, copy_all_media, copy_rather_than_move)
  -- TODO:  - if a file exists already, fileformats like edl and txt may lead to showing of a overwrite-prompt of the savedialog
  --                this is mostly due Reaper adding the accompanying extension to the filename
  --                must be treated somehow or the other formats must be removed
  --        - convert mediafiles into another format(possible at all?)
  --        - check on Linux and Mac
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SaveProjectAs</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    SWS=2.10.0.1
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string newfilename_with_path = ultraschall.SaveProjectAs(string filename_with_path, integer fileformat, boolean overwrite, boolean create_subdirectory, integer copy_all_media, boolean copy_rather_than_move)</functioncall>
  <description>
    Saves the current project under a new filename.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, saving was successful; false, saving wasn't succesful
    string newfilename_with_path - the new projectfilename with path, helpful if you only gave the filename
  </retvals>
  <parameters>
    string filename_with_path - the new projectfile; omitting the path saves the project in the last used folder
    integer fileformat - the fileformat, in which you want to save the project
                       - 0, REAPER Project files (*.RPP)
                       - 1, EDL TXT (Vegas) files (*.TXT)
                       - 2, EDL (Samplitude) files (*.EDL)
    boolean overwrite - true, overwrites the projectfile, if it exists; false, keep an already existing projectfile
    boolean create_subdirectory - true, create a subdirectory for the project; false, save it into the given folder
    integer copy_all_media - shall the project's mediafiles be copied or moved or left as they are?
                           - 0, don't copy/move media
                           - 1, copy the project's mediafiles into projectdirectory
                           - 2, move the project's mediafiles into projectdirectory
    boolean copy_rather_than_move - true, copy rather than move source media if not in old project media path; false, leave the files as they are
  </parameters>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>project management, save, project as, edl, rpp, vegas, samplitude</tags>
</US_DocBloc>
--]]
  -- check parameters
  local A=ultraschall.GetSaveProjectAsHWND()
  if A~=nil then ultraschall.AddErrorMessage("SaveProjectAs", "", "SaveAs-dialog already open", -1) return false end
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "must be a string", -2) return false end
  local A,B=reaper.BR_Win32_GetPrivateProfileString("REAPER", "lastprojuiref", "", reaper.get_ini_file())
  local C,D=ultraschall.GetPath(B)
  local E,F=ultraschall.GetPath(filename_with_path)
  
  if E=="" then filename_with_path=C..filename_with_path end
  if E~="" and ultraschall.DirectoryExists2(E)==false then 
    reaper.RecursiveCreateDirectory(E,1)
    if ultraschall.DirectoryExists2(E)==false then 
      ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "invalid path", -3)
      return false
    end
  end
  if type(overwrite)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "overwrite", "must be a boolean", -4) return false end
  if type(create_subdirectory)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "create_subdirectory", "must be a boolean", -5) return false end
  if math.type(copy_all_media)~="integer" then ultraschall.AddErrorMessage("SaveProjectAs", "copy_all_media", "must be an integer", -6) return false end
  if type(copy_rather_than_move)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "copy_rather_than_move", "must be a boolean", -7) return false end
  if math.type(fileformat)~="integer" then ultraschall.AddErrorMessage("SaveProjectAs", "fileformat", "must be an integer", -8) return false end
  if fileformat<0 or fileformat>2 then ultraschall.AddErrorMessage("SaveProjectAs", "fileformat", "must be between 0 and 2", -9) return false end
  if copy_all_media<0 or copy_all_media>2 then ultraschall.AddErrorMessage("SaveProjectAs", "copy_all_media", "must be between 0 and 2", -10) return false end
  
  -- management of, if file already exists
  if overwrite==false and reaper.file_exists(filename_with_path)==true then ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "file already exists", -11) return false end
  if overwrite==true and reaper.file_exists(filename_with_path)==true then os.remove(filename_with_path) end

  
  -- create the background-script, which will manage the saveas-dialog and run it
      ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/saveprojectas.lua", [[
      dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
      num_params, params, caller_script_identifier = ultraschall.GetScriptParameters()

      filename_with_path=params[1]
      fileformat=tonumber(params[2])
      create_subdirectory=toboolean(params[3])
      copy_all_media=params[4]
      copy_rather_than_move=toboolean(params[5])
      
      function main2()
        --if A~=nil then print2("Hooray") end
        translation=reaper.JS_Localize("Create subdirectory for project", "DLG_185")
        PP=reaper.JS_Window_Find("Create subdirectory", false)
        A2=reaper.JS_Window_GetParent(PP)
        ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1042), create_subdirectory)
        if copy_all_media==1 then 
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), true)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), false)
        elseif copy_all_media==2 then 
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), false)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), true)
        else
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), false)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), false)
        end
        ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1045), copy_rather_than_move)
        A3=reaper.JS_Window_FindChildByID(A, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        reaper.JS_Window_SetTitle(A3, filename_with_path)
        reaper.JS_WindowMessage_Send(A3, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(A3, "WM_LBUTTONUP", 1,1,1,1)
        
        XX=reaper.JS_Window_FindChild(A, "REAPER Project files (*.RPP)", true)

        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONUP", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "CB_SETCURSEL", fileformat,0,0,0)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONUP", 1,1,1,1)
        
        reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONUP", 1,1,1,1)
      end

      function main1()
        A=ultraschall.GetSaveProjectAsHWND()
        if A==nil then reaper.defer(main1) else main2() end
      end
      
      --print("alive")
      
      main1()
      ]])
      local retval, script_identifier = ultraschall.Main_OnCommandByFilename(ultraschall.API_TempPath.."/saveprojectas.lua", filename_with_path, fileformat, create_subdirectory, copy_all_media, copy_rather_than_move)
    
  -- open SaveAs-dialog
  reaper.Main_SaveProject(0, true)
  -- remove background-script
  os.remove(ultraschall.API_TempPath.."/saveprojectas.lua")
  return true, filename_with_path
end

--reaper.Main_SaveProject(0, true)
--ultraschall.SaveProjectAs("Fix it all of that HUUUIII", true, 0, true)


function ultraschall.TransientDetection_Set(Sensitivity, Threshold, ZeroCrossings)
  -- needs to take care of faulty parametervalues AND of correct value-entering into an already opened
  -- 41208 - Transient detection sensitivity/threshold: Adjust... - dialog
  reaper.SNM_SetDoubleConfigVar("transientsensitivity", Sensitivity) -- 0.0 to 1.0
  reaper.SNM_SetDoubleConfigVar("transientthreshold", Threshold) -- -60 to 0
  local val=reaper.SNM_GetIntConfigVar("tabtotransflag", -999)
  if val&2==2 and ZeroCrossings==false then
    reaper.SNM_SetIntConfigVar("tabtotransflag", val-2)
  elseif val&2==0 and ZeroCrossings==true then
    reaper.SNM_SetIntConfigVar("tabtotransflag", val+2)
  end
end

--ultraschall.TransientDetection_Set(0.1, -9, false)



function ultraschall.ReadSubtitles_VTT(filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReadSubtitles_VTT</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string Kind, string Language, integer Captions_Counter, table Captions = ultraschall.ReadSubtitles_VTT(string filename_with_path)</functioncall>
  <description>
    parses a webvtt-subtitle-file and returns its contents as table
    
    returns nil in case of an error
  </description>
  <retvals>
    string Kind - the type of the webvtt-file, like: captions
    string Language - the language of the webvtt-file
    integer Captions_Counter - the number of captions in the file
    table Captions - the Captions as a table of the format:
                   -    Captions[index]["start"]= the starttime of this caption in seconds
                   -    Captions[index]["end"]= the endtime of this caption in seconds
                   -    Captions[index]["caption"]= the caption itself
  </retvals>
  <parameters>
    string filename_with_path - the filename with path of the webvtt-file
  </parameters>
  <chapter_context>
    File Management
    Read Files
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, read, file, webvtt, subtitle, import</tags>
</US_DocBloc>
--]]
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "must be a string", -1) return end
  if reaper.file_exists(filename_with_path)=="false" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "must be a string", -2) return end
  local A, Type, Offset, Kind, Language, Subs, Subs_Counter, i
  Subs={}
  Subs_Counter=0
  A=ultraschall.ReadFullFile(filename_with_path)
  Type, Offset=A:match("(.-)\n()")
  if Type~="WEBVTT" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "not a webvtt-file", -3) return end
  A=A:sub(Offset,-1)
  Kind, Offset=A:match(".-: (.-)\n()")
  A=A:sub(Offset,-1)
  Language, Offset=A:match(".-: (.-)\n()")
  A=A:sub(Offset,-1)
  
  i=0
  for k in string.gmatch(A, "(.-)\n") do
    i=i+1
    if i==2 then 
      Subs_Counter=Subs_Counter+1
      Subs[Subs_Counter]={} 
      Subs[Subs_Counter]["start"], Subs[Subs_Counter]["end"] = k:match("(.-) --> (.*)")
      if Subs[Subs_Counter]["start"]==nil or Subs[Subs_Counter]["end"]==nil then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "can't parse the file; probably invalid", -3) return end
      Subs[Subs_Counter]["start"]=reaper.parse_timestr(Subs[Subs_Counter]["start"])
      Subs[Subs_Counter]["end"]=reaper.parse_timestr(Subs[Subs_Counter]["end"])
    elseif i==3 then 
      Subs[Subs_Counter]["caption"]=k
      if Subs[Subs_Counter]["caption"]==nil then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "can't parse the file; probably invalid", -4) return end
    end
    if i==3 then i=0 end
  end
  
  
  return Kind, Language, Subs_Counter, Subs
end


--A,B,C,D,E=ultraschall.ReadSubtitles_VTT("c:\\test.vtt")

function ultraschall.BatchConvertFiles(filelist, RenderTable, BWFStart, PadStart, PadEnd, FXChain)
-- Todo:
-- Check on Mac and Linux
--    Linux saves outfile into wrong directory -> lastcwd not OUTPATH for some reason
-- Check all parameters for correct typings
-- Test FXChain-capability
  local BatchConvertData=""
  --local ExeFile, filename, path
  if FXChain==nil then FXChain="" end
  if BWFStart==true then BWFStart="    USERCSTART 1\n" else BWFStart="" end
  if PadStart~=nil  then PadStart="    PAD_START "..PadStart.."\n" else PadStart="" end
  if PadEnd~=nil  then PadEnd="    PAD_END "..PadEnd.."\n" else PadEnd="" end
  local i=1
  while filelist[i]~=nil do
    path, filename = ultraschall.GetPath(filelist[i])
    filename2=filename:match("(.-)%.")
    if filename2==nil then filename2=filename end
    BatchConvertData=BatchConvertData..filelist[i].."\t"..filename2.."\n"
    i=i+1
  end
  BatchConvertData=BatchConvertData..[[
<CONFIG
]]..FXChain..[[
  <OUTFMT 
    ]]      ..RenderTable["RenderString"]..[[
    
    SRATE ]]..RenderTable["SampleRate"]..[[
    
    NCH ]]..RenderTable["Channels"]..[[
    
    RSMODE ]]..RenderTable["RenderResample"]..[[
    
    DITHER ]]..RenderTable["Dither"]..[[
    
]]..BWFStart..[[
]]..PadStart..[[
]]..PadEnd..[[
    OUTPATH ]]..RenderTable["RenderFile"]..[[
    
    OUTPATTERN ']]..RenderTable["RenderPattern"]..[['
  >
>
]]

  ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/filelist.txt", BatchConvertData)
print2(BatchConvertData)
  if ultraschall.IsOS_Windows()==true then
    ExeFile=reaper.GetExePath().."\\reaper.exe"
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "/", "\\").."\\filelist.txt", -1)
    print3(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "/", "\\").."\\filelist.txt")

  elseif ultraschall.IsOS_Mac()==true then
    print2("Must be checked on Mac!!!!")
    ExeFile=reaper.GetExePath().."\\reaper"
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt", -1)
  else
    print2("Must be checked on Linux!!!!")
    ExeFile=reaper.GetExePath().."/reaper"
--print3(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt")
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt", -1)
  end
end


-- These seem to work working:

function ultraschall.GetTake_ReverseState(MediaItem, takenumber)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTake_ReverseState</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.GetTake_ReverseState(MediaItem item, integer takenumber)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns, if the chosen take of the MediaItem is reversed
  
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, take is reversed; false, take is not reversed
  </retvals>
  <parameters>
    MediaItem item - the MediaItem, of whose take you want to get the reverse-state
    integer takenumber - the take, whose reverse-state you want to know; 1, for the first take, etc
  </parameters>
  <chapter_context>
    MediaItem Management
    Get MediaItem-Takes
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>take management, get, reverse, state</tags>
</US_DocBloc>
--]]
  if ultraschall.type(MediaItem)~="MediaItem" then ultraschall.AddErrorMessage("GetTake_ReverseState", "MediaItem", "must be a MediaItem", -1) return false end
  if math.type(takenumber)~="integer" then ultraschall.AddErrorMessage("GetTake_ReverseState", "takenumber", "must be an integer", -2) return false end
  if takenumber<1 then ultraschall.AddErrorMessage("GetTake_ReverseState", "takenumber", "must be bigger than 0", -3) return false end
  local Count=reaper.CountTakes(Item)
  
  local retval, StateChunk = reaper.GetItemStateChunk(Item, "", false)
  local StateChunk = ultraschall.StateChunkLayouter(StateChunk)
  local i=0
  for k in string.gmatch(StateChunk, "\n(  <SOURCE.-\n  >)") do
    i=i+1
    if i==takenumber then
      local Mode=k:match("MODE (%d*).")
      if Mode==nil then Mode=false else Mode=tonumber(Mode)&2==2 end
      return Mode
    end
  end
end

function ultraschall.SetItemButtonsVisible(Volume, Locked, Mute, Notes, PooledMidi, GroupedItems, PerTakeFX, Properties, AutomationEnvelopes)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetItemButtonsVisible</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.10
	SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetItemButtonsVisible(optional boolean Volume, optional integer Locked, optional integer Mute, optional integer Notes, optional boolean PooledMidi, optional boolean GroupedItems, optional integer PerTakeFX, optional integer Properties, optional integer AutomationEnvelopes)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    allows setting, which item-buttons shall be shown
  
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting button was successful; false, buttons couldn't be set
  </retvals>
  <parameters>
    optional boolean Volume - true, show the volume knob; false, don't show the volume knob; nil, keep current setting
	optional integer Locked - sets state of locked/unlocked button
							- nil, keep current state
						    - 0, don't show lockstate button
							- 1, show locked button only
							- 2, show unlocked button only
							- 3, show locked and unlocked button
	optional integer Mute - sets state of mute/unmuted button
							- nil, keep current state
						    - 0, don't show mute button
							- 1, show mute button only
							- 2, show unmuted button only
							- 3, show muted and unmuted button
	optional integer Notes - sets state of itemnotes-button
							- nil, keep current state
						    - 0, don't show item-note button
							- 1, show itemnote existing-button only
							- 2, show no itemnote existing-button only
							- 3, show itemnote existing and no itemnote existing-button
	optional boolean PooledMidi - true, show the pooled midi-button; false, don't show the pooled midi-button; nil, keep current setting
	optional boolean GroupedItems - true, show the grouped item-button; false, don't show the grouped item-button; nil, keep current setting
	optional integer PerTakeFX - sets state of take fx-button
							- nil, keep current state
						    - 0, don't show take-fx button
							- 1, show active take fx-button only
							- 2, show non active take fx-button only
							- 3, show active and nonactive take fx-button
	optional integer Properties - show properties-button
								- nil, keep current state
								- 0, don't show item properties-button
								- 1, show item properties-button
								- 2, show item properties-button only if resampled media
	optional integer AutomationEnvelopes - sets state of envelope-button
										- nil, keep current state
										- 0, don't show envelope-button
										- 1, show active envelope-button only
										- 2, show non active envelope-button only
										- 3, show active and nonactive envelope-button
  </parameters>
  <chapter_context>
    User Interface
    MediaItems
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, set, media items, show, buttons</tags>
</US_DocBloc>
--]]
  if type(Volume)~="boolean" then ultraschall.AddErrorMessage("SetItemButtonsVisible", "Volume", "must be a boolean" , -1) return false end
  if math.type(Locked)~="integer" then ultraschall.AddErrorMessage("SetItemButtonsVisible", "Locked", "must be an integer" , -2) return false end
  if math.type(Mute)~="integer" then ultraschall.AddErrorMessage("SetItemButtonsVisible", "Mute", "must be an integer" , -3) return false end
  if math.type(Notes)~="integer" then ultraschall.AddErrorMessage("SetItemButtonsVisible", "Notes", "must be an integer" , -4) return false end
  
  if type(PooledMidi)~="boolean" then ultraschall.AddErrorMessage("SetItemButtonsVisible", "PooledMidi", "must be a boolean" , -5) return false end
  if type(GroupedItems)~="boolean" then ultraschall.AddErrorMessage("SetItemButtonsVisible", "GroupedItems", "must be a boolean" , -6) return false end
  if math.type(PerTakeFX)~="integer" then ultraschall.AddErrorMessage("SetItemButtonsVisible", "PerTakeFX", "must be an integer" , -7) return false end
  if math.type(Properties)~="integer" then ultraschall.AddErrorMessage("SetItemButtonsVisible", "Properties", "must be an integer" , -8) return false end
  if math.type(AutomationEnvelopes)~="integer" then ultraschall.AddErrorMessage("SetItemButtonsVisible", "AutomationEnvelopes", "must be an integer" , -9) return false end

  local State = reaper.SNM_GetIntConfigVar("itemicons", -99)
  if Locked~=nil then
    if Locked&1==0 and State&1~=0 then State=State-1 elseif Locked&1~=0 and State&1==0 then State=State+1 end
    if Locked&2==0 and State&2~=0 then State=State-2 elseif Locked&2~=0 and State&2==0 then State=State+2 end
  end

  if PerTakeFX~=nil then
    if PerTakeFX&1==0 and State&4~=0 then State=State-4 elseif PerTakeFX&1~=0 and State&4==0 then State=State+4 end
    if PerTakeFX&2==0 and State&8~=0 then State=State-8 elseif PerTakeFX&2~=0 and State&8==0 then State=State+8 end
  end

  if Mute~=nil then
    if Mute&1==0 and State&16~=0 then State=State-16 elseif Mute&1~=0 and State&16==0 then State=State+16 end
    if Mute&2==0 and State&32~=0 then State=State-32 elseif Mute&2~=0 and State&32==0 then State=State+32 end
  end
  
  if Notes~=nil then
    if Notes&1==0 and State&64~=0 then  State=State-64  elseif Notes&1~=0 and State&64 ==0 then State=State+64  end
    if Notes&2==0 and State&128~=0 then State=State-128 elseif Notes&2~=0 and State&128==0 then State=State+128 end
  end  
  
  if GroupedItems~=nil then
    if GroupedItems==false and State&256~=0 then  State=State-256  elseif GroupedItems==true and State&256==0 then State=State+256  end
  end  

  if Properties~=nil then
    if State&2048 == 2048 then State=State-2048 end
    if State&4096 == 4096 then State=State-4096 end
    if Properties==1 then State=State+2048
    elseif Properties==0 then State=State+4096
    end
  end
  
  if PooledMidi~=nil then
    if PooledMidi==true and State&8192~=0 then  State=State-8192  elseif PooledMidi==false and State&8192==0 then State=State+8192 end
  end  

  if Volume~=nil then
    if Volume==false and State&16384~=0 then  State=State-16384  elseif Volume==true and State&16384==0 then State=State+16384 end
  end  

  if AutomationEnvelopes~=nil then
    if AutomationEnvelopes&1==1 and State&262144~=0 then State=State-262144 elseif AutomationEnvelopes&1~=1 and State&262144==0 then State=State+262144 end
    if AutomationEnvelopes&2==0 and State&524288~=0 then State=State+524288 elseif AutomationEnvelopes&2~=0 and State&524288==0 then State=State-524288 end
  end  
  
  reaper.SNM_SetIntConfigVar("itemicons", State)
  reaper.UpdateArrange()
  return true
end

function ultraschall.GetItemButtonsVisible()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetItemButtonsVisible</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.10
	SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean Volume, integer Locked, integer Mute, integer Notes, boolean PooledMidi, boolean GroupedItems, integer PerTakeFX, integer Properties, integer AutomationEnvelopes = ultraschall.GetItemButtonsVisible()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    gets, which item-buttons are be shown
  </description>
  <retvals>
    boolean Volume - true, shows the volume knob; false, doesn't show the volume knob
	integer Locked - gets visibility-state of locked/unlocked button
						    - 0, doesn't show lockstate button
							- 1, shows locked button only
							- 2, shows unlocked button only
							- 3, shows locked and unlocked button
	integer Mute - gets visibility-state of mute/unmuted button
						    - 0, doesn't show mute button
							- 1, shows mute button only
							- 2, shows unmuted button only
							- 3, shows muted and unmuted button
	integer Notes - gets visibility-state of itemnotes-button
						    - 0, doesn't show item-note button
							- 1, shows itemnote existing-button only
							- 2, shows no itemnote existing-button only
							- 3, shows itemnote existing and no itemnote existing-button
	boolean PooledMidi - true, shows the pooled midi-button; false, don't show the pooled midi-button
	boolean GroupedItems - true, shows the grouped item-button; false, don't show the grouped item-button
	integer PerTakeFX - gets visibility-state of take fx-button
						    - 0, doesn't show take-fx button
							- 1, shows active take fx-button only
							- 2, shows non active take fx-button only
							- 3, shows active and nonactive take fx-button
	integer Properties - gets visibility-state of properties-button
								- 0, doesn't show item properties-button
								- 1, shows item properties-button
								- 2, shows item properties-button only if resampled media
	integer AutomationEnvelopes - gets visibility-state of envelope-button
										- 0, doesn't show envelope-button
										- 1, shows active envelope-button only
										- 2, shows non active envelope-button only
										- 3, shows active and nonactive envelope-button
  </retvals>
  <chapter_context>
    User Interface
    MediaItems
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>user interface, media items, get, show, buttons</tags>
</US_DocBloc>
--]]
  local State = reaper.SNM_GetIntConfigVar("itemicons", -99)
  local Volume, Locked, Mute, Notes, PooledMidi, GroupedItems, PerTakeFX, Properties, AutomationEnvelopes=false,0,0,0,false,false,0,0,0
  if State&1~=0 then Locked=Locked+1 end
  if State&2~=0 then Locked=Locked+2 end
  
  if State&4~=0 then PerTakeFX=PerTakeFX+1 end
  if State&8~=0 then PerTakeFX=PerTakeFX+2 end
  
  if State&16~=0 then Mute=Mute+1 end
  if State&32~=0 then Mute=Mute+2 end
  
  if State&64 ~=0 then Notes=Notes+1 end
  if State&128~=0 then Notes=Notes+2 end
  
  GroupedItems=State&256~=0
  
  if State&2048~=0 then Properties=Properties+1 
  elseif State&4096==0 then Properties=Properties+2 end
  
  PooledMidi=State&8192==0
  
  Volume=State&16384==0
  
  if State&262144==0 then AutomationEnvelopes=AutomationEnvelopes+1 end
  if State&524288~=0 then AutomationEnvelopes=AutomationEnvelopes+2 end  
  
  return Volume, Locked, Mute, Notes, PooledMidi, GroupedItems, PerTakeFX, Properties, AutomationEnvelopes
end

function ultraschall.PreventUIRefresh()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>PreventUIRefresh</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer current_preventcount = ultraschall.PreventUIRefresh()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    like Reaper's own PreventUIRefresh, it allows you to prevent redrawing of the userinterface.
    
    Unlike Reaper's own PreventUIRefresh, this will manage the preventcount itself.
    
    this will not take into account usage of Reaper's own PreventUIRefresh, so you should use either
    
    To reallow refreshing of the UI, use [RestoreUIRefresh](#RestoreUIRefresh).
  </description>
  <retvals>
    integer current_preventcount - the number of times PreventUIRefresh has been called since scriptstart
  </retvals>
  <chapter_context>
    User Interface
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
  <tags>user interface, prevent, ui, refresh</tags>
</US_DocBloc>
--]]
  if ultraschall.PreventUIRefresh_Value==nil then ultraschall.PreventUIRefresh_Value=0 end
  ultraschall.PreventUIRefresh_Value=ultraschall.PreventUIRefresh_Value+1
  reaper.PreventUIRefresh(1)
  return ultraschall.PreventUIRefresh_Value
end

function ultraschall.RestoreUIRefresh(full)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>RestoreUIRefresh</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer current_preventcount = ultraschall.RestoreUIRefresh(optional boolean full)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    This reallows UI-refresh, after you've prevented it using [PreventUIRefresh](#PreventUIRefresh).
    
    If you set parameter full=true, it will reset all PreventUIRefresh-calls since scriptstart at once, otherwise you need to call this
    as often until the returnvalue current_preventcount equals 0.
    
    To get the remaining UI-refreshes to be restored, use [GetPreventUIRefreshCount](#GetPreventUIRefreshCount)
    
    If no UIRefreshes are available anymore, calling this function has no effect.
  </description>
  <retvals>
    integer current_preventcount - the remaining number of times PreventUIRefresh has been called since scriptstart
  </retvals>
  <parameters>
    optional boolean full - true, restores UIRefresh fully, no matter, how often PreventUIRefresh has been called before; false or nil, just reset one single call to PreventUIRefresh
  </parameters>
  <chapter_context>
    User Interface
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
  <tags>user interface, restore, ui, refresh</tags>
</US_DocBloc>
--]]
  if full==true then 
    reaper.PreventUIRefresh(-ultraschall.PreventUIRefresh_Value)   
    ultraschall.PreventUIRefresh_Value=0
  else
    if ultraschall.PreventUIRefresh_Value>0 then 
      reaper.PreventUIRefresh(-1)
      ultraschall.PreventUIRefresh_Value=ultraschall.PreventUIRefresh_Value-1
    end
  end
  return ultraschall.PreventUIRefresh_Value
end

--A=ultraschall.PreventUIRefresh()
--B=ultraschall.RestoreUIRefresh(full)

function ultraschall.GetPreventUIRefreshCount()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetPreventUIRefreshCount</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>integer current_preventcount = ultraschall.GetPreventUIRefreshCount()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    This returns the number of times [PreventUIRefresh](#PreventUIRefresh) has been called since scriptstart, minus possible restored UI refreshes.
    
    Use [RestoreUIRefresh](#RestoreUIRefresh) to restore UI-refresh 
  </description>
  <retvals>
    integer current_preventcount - the remaining number of times PreventUIRefresh has been called since scriptstart
  </retvals>
  <chapter_context>
    User Interface
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
  <tags>user interface, get, remaining, ui, refresh</tags>
</US_DocBloc>
--]]
  if ultraschall.PreventUIRefresh_Value==nil then ultraschall.PreventUIRefresh_Value=0 end
  return ultraschall.PreventUIRefresh_Value
end


function ultraschall.SetEnvelopeState_Vis(TrackEnvelope, visibility, lane, unknown, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetEnvelopeState_Vis</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.10
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string EnvelopeStateChunk = ultraschall.SetEnvelopeState_Vis(TrackEnvelope env, integer visibility, integer lane, integer unknown, optional string EnvelopeStateChunk)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
      sets the current visibility-state of a TrackEnvelope-object or EnvelopeStateChunk.
      
      It is the state entry VIS
      
      returns false in case of error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
	string EnvelopeStateChunk - the altered EnvelopeStateChunk
  </retvals>
  <parameters>
    TrackEnvelope env - the envelope, in whose envelope you want set the visibility states; nil, to us parameter EnvelopeStateChunk instead
    integer visibility - the visibility of the envelope; 0, invisible; 1, visible
    integer lane - the position of the envelope in the lane; 0, envelope is in media-lane; 1, envelope is in it's own lane
    integer unknown - unknown; default=1 
	optional string EnvelopeStateChunk - an EnvelopeStateChunk, in which you want to set these settings
  </parameters>
  <chapter_context>
    Envelope Management
    Set Envelope States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
  <tags>envelope management, set, envelope, envelope statechunk, lane, visibility</tags>
</US_DocBloc>
--]]
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("SetEnvelopeState_Vis", "TrackEnvelope", "must be a TrackEnvelope", -1) return false end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("SetEnvelopeState_Vis", "EnvelopeStateChunk", "must be a valid EnvelopeStateChunk", -2) return false end
  if math.type(visibility)~="integer" then ultraschall.AddErrorMessage("SetEnvelopeState_Vis", "visibility", "must be an integer", -3) return false end
  if math.type(lane)~="integer" then ultraschall.AddErrorMessage("SetEnvelopeState_Vis", "lane", "must be an integer", -4) return false end
  if math.type(unknown)~="integer" then ultraschall.AddErrorMessage("SetEnvelopeState_Vis", "unknown", "must be an integer", -5) return false end
  local A
  if TrackEnvelope~=nil then
    A,EnvelopeStateChunk=reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
  end
  EnvelopeStateChunk=string.gsub(EnvelopeStateChunk, "VIS .-\n", "VIS "..visibility.." "..lane.." "..unknown.."\n")
  if TrackEnvelope~=nil then
    reaper.SetEnvelopeStateChunk(TrackEnvelope, EnvelopeStateChunk, false)
  end
  return true, EnvelopeStateChunk
end


function ultraschall.SetEnvelopeState_Act(TrackEnvelope, act, automation_settings, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetEnvelopeState_Act</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.10
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetEnvelopeState_Act(TrackEnvelope env, integer act, integer automation_settings, optional string EnvelopeStateChunk)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
      sets the current bypass and automation-items-settings-state of a TrackEnvelope-object or EnvelopeStateChunk.
      
      It is the state entry ACT
      
      returns false in case of error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
	string EnvelopeStateChunk - the altered EnvelopeStateChunk
  </retvals>
  <parameters>
    TrackEnvelope env - the envelope, in whose envelope you want set the bypass and automation-item-states; nil, to use parameter EnvelopeStateChunk instead
    integer act - bypass-setting; 
				-   0, bypass on
				-   1, no bypass 
    integer automation_settings - automation item-options for this envelope
								- -1, project default behavior, outside of automation items
								- 0, automation items do not attach underlying envelope
								- 1, automation items attach to the underlying envelope on the right side
								- 2, automation items attach to the underlying envelope on both sides
								- 3, no automation item-options for this envelope
								- 4, bypass underlying envelope outside of automation items 
	optional string EnvelopeStateChunk - an EnvelopeStateChunk, in which you want to set these settings
  </parameters>
  <chapter_context>
    Envelope Management
    Set Envelope States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
  <tags>envelope management, set, envelope, envelope statechunk, automation options, automation items, bypass, visibility</tags>
</US_DocBloc>
--]]
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("SetEnvelopeState_Act", "TrackEnvelope", "must be a TrackEnvelope", -1) return false end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("SetEnvelopeState_Act", "EnvelopeStateChunk", "must be a valid EnvelopeStateChunk", -2) return false end
  if math.type(act)~="integer" then ultraschall.AddErrorMessage("SetEnvelopeState_Act", "act", "must be an integer", -3) return false end
  if math.type(automation_settings)~="integer" then ultraschall.AddErrorMessage("SetEnvelopeState_Act", "automation_settings", "must be an integer", -4) return false end
  local A
  if TrackEnvelope~=nil then
    A,EnvelopeStateChunk=reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
  end
  
  EnvelopeStateChunk=string.gsub(EnvelopeStateChunk, "ACT .-\n", "ACT "..act.." "..automation_settings.."\n")
  if TrackEnvelope~=nil then
    reaper.SetEnvelopeStateChunk(TrackEnvelope, EnvelopeStateChunk, false)
  end
  return true, EnvelopeStateChunk
end

function ultraschall.SetEnvelopeState_DefShape(TrackEnvelope, shape, pitch_custom_envelope_range_takes, pitch_snap_values, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetEnvelopeState_DefShape</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.10
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string EnvelopeStateChunk = ultraschall.SetEnvelopeState_DefShape(TrackEnvelope env, integer shape, integer pitch_custom_envelope_range, integer pitch_snap_values, optional string EnvelopeStateChunk)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
      sets the current default-shape-states and pitch-snap-settings of a TrackEnvelope-object or EnvelopeStateChunk.
      
      It is the state entry DEFSHAPE
      
      returns false in case of error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
	string EnvelopeStateChunk - the altered EnvelopeStateChunk
  </retvals>
  <parameters>
    TrackEnvelope env - the envelope, in whose envelope you want set the default shape and pitch-snap states; nil, to use parameter EnvelopeStateChunk instead
    integer shape - the default shape of envelope-points
					- 0, linear
					- 1, square
					- 2, slow start/end
					- 3, fast start
					- 4, fast end
					- 5, bezier 
	integer pitch_custom_envelope_range_takes - the custom envelope range as set in the Pitch Envelope Settings; only available in take-fx-envelope "Pitch"
											  - -1, if unset or for non pitch-envelopes
											  - 0, Custom envelope range-checkbox unchecked
											  - 1-2147483647, the actual semitones
	integer pitch_snap_values - the snap values-dropdownlist as set in the Pitch Envelope Settings-dialog; only available in take-fx-envelope "Pitch"
					 -  -1, unset/Follow global default
					 -  0, Off
					 -  1, 1 Semitone
					 -  2, 50 cent
					 -  3, 25 cent
					 -  4, 10 cent
					 -  5, 5 cent
					 -  6, 1 cent
	optional string EnvelopeStateChunk - an EnvelopeStateChunk, in which you want to set these settings
  </parameters>
  <chapter_context>
    Envelope Management
    Set Envelope States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
  <tags>envelope management, set, envelope, envelope statechunk, shape, pitch snap, visibility</tags>
</US_DocBloc>
--]]
  if TrackEnvelope~=nil and ultraschall.type(TrackEnvelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("SetEnvelopeState_DefShape", "TrackEnvelope", "must be a TrackEnvelope", -1) return false end
  if TrackEnvelope==nil and ultraschall.IsValidEnvStateChunk(EnvelopeStateChunk)==false then ultraschall.AddErrorMessage("SetEnvelopeState_DefShape", "EnvelopeStateChunk", "must be a valid EnvelopeStateChunk", -2) return false end
  if math.type(shape)~="integer" then ultraschall.AddErrorMessage("SetEnvelopeState_DefShape", "shape", "must be an integer", -3) return false end
  if math.type(pitch_custom_envelope_range_takes)~="integer" then ultraschall.AddErrorMessage("SetEnvelopeState_DefShape", "pitch_custom_envelope_range_takes", "must be an integer", -4) return false end
  if math.type(pitch_snap_values)~="integer" then ultraschall.AddErrorMessage("SetEnvelopeState_DefShape", "pitch_snap_values", "must be an integer", -5) return false end
  local A
  if TrackEnvelope~=nil then
    A,EnvelopeStateChunk=reaper.GetEnvelopeStateChunk(TrackEnvelope, "", false)
  end
  EnvelopeStateChunk=string.gsub(EnvelopeStateChunk, "DEFSHAPE .-\n", "DEFSHAPE "..shape.." "..pitch_custom_envelope_range_takes.." "..pitch_snap_values.."\n")
  if TrackEnvelope~=nil then
    reaper.SetEnvelopeStateChunk(TrackEnvelope, EnvelopeStateChunk, false)
  end
  return true, EnvelopeStateChunk
end

function ultraschall.SetEnvelopeState_LaneHeight(TrackEnvelope, height, compacted, EnvelopeStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetEnvelopeState_LaneHeight</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.10
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string EnvelopeStateChunk = ultraschall.SetEnvelopeState_LaneHeight(TrackEnvelope env, integer height, integer compacted, optional string EnvelopeStateChunk)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
      sets the current height-states and compacted-settings of a TrackEnvelope-object or EnvelopeStateChunk.
      
      It is the state entry LANEHEIGHT
      
      returns false in case of error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
	string EnvelopeStateChunk - the altered EnvelopeStateChunk
  </retvals>
  <parameters>
    TrackEnvelope env - the envelope, whose envelope you want set the height and compacted-states; nil, to us parameter EnvelopeStateChunk instead
    integer height - the height of the laneheight; the height of this envelope in pixels; 24 - 263 pixels
	integer compacted - 1, envelope-lane is compacted("normal" height is not shown but still stored in height);
					  - 0, envelope-lane is "normal" height 
	optional string EnvelopeStateChunk - an EnvelopeStateChunk, in which you want to set these settings
	</parameters>
  <chapter_context>
    Envelope Management
    Set Envelope States
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
  <tags>envelope management, set, envelope, envelope statechunk, height, compacted, visibility</tags>
</US_DocBloc>
--]]
	return ultraschall.SetEnvelopeHeight(height, compacted==1, TrackEnvelope, EnvelopeStateChunk)
end


function ultraschall.ActivateMute(track, visible)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateMute</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateMute(integer track, optional boolean visible)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a mute-envelope of a track
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      integer track - the track, whose mute-envelope you want to activate; 1, for the first track
      optional boolean visible - true, show the activated mute-envelope; false, don't show the activated mute-envelope
    </parameters>
    <chapter_context>
      Mute Management
      Mute Lane
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
    <tags>envelope management, mute, activate</tags>
  </US_DocBloc>
  --]]
  if math.type(track)~="integer" then ultraschall.AddErrorMessage("ActivateMute", "mute", "must be an integer", -1) return false end
  if track<1 or track>reaper.CountTracks(0) then ultraschall.AddErrorMessage("ActivateMute", "mute", "no such track", -2) return false end
  local env=reaper.GetTrackEnvelopeByName(reaper.GetTrack(0,track-1), "Mute")
  local retval
  if env==nil then
    ultraschall.PreventUIRefresh()
    retval = ultraschall.ApplyActionToTrack(tostring(track), 40866)
    if visible~=true then
      local env=reaper.GetTrackEnvelopeByName(reaper.GetTrack(0,track-1), "Mute")
      local A,B,C=ultraschall.GetEnvelopeState_Vis(env)
      ultraschall.SetEnvelopeState_Vis(env, 0,B,C)
    end
    ultraschall.RestoreUIRefresh()
  else 
    retval=false ultraschall.AddErrorMessage("ActivateMute", "", "already activated", -3)
  end
  return retval
end

function ultraschall.DeactivateMute(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>DeactivateMute</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.DeactivateMute(integer track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      deactivates a mute-envelope of a track
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, deactivating was successful; false, deactivating was unsuccessful
    </retvals>
    <parameters>
      integer track - the track, whose mute-envelope you want to deactivate; 1, for the first track
    </parameters>
    <chapter_context>
      Mute Management
      Mute Lane
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
    <tags>envelope management, mute, deactivate</tags>
  </US_DocBloc>
  --]]
  if math.type(track)~="integer" then ultraschall.AddErrorMessage("DeactivateMute", "mute", "must be an integer", -1) return false end
  if track<1 or track>reaper.CountTracks(0) then ultraschall.AddErrorMessage("DeactivateMute", "mute", "no such track", -2) return false end
  local env=reaper.GetTrackEnvelopeByName(reaper.GetTrack(0,track-1), "Mute")
  local retval
  if env~=nil then
    retval = ultraschall.ApplyActionToTrack(tostring(track), 40866)
  else 
    retval=false ultraschall.AddErrorMessage("DeactivateMute", "", "already deactivated", -3)
  end
  return retval
end

function ultraschall.ActivateMute_TrackObject(track, visible)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateMute_TrackObject</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateMute_TrackObject(MediaTrack track, optional boolean visible)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a mute-envelope of a MediaTrack-object
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      MediaTrack track - the track, whose mute-envelope you want to activate
      optional boolean visible - true, show the activated mute-envelope; false, don't show the activated mute-envelope
    </parameters>
    <chapter_context>
      Mute Management
      Mute Lane
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
    <tags>envelope management, mute, activate</tags>
  </US_DocBloc>
  --]]
  if ultraschall.type(track)~="MediaTrack" then ultraschall.AddErrorMessage("ActivateMute_TrackObject", "track", "must be a MediaTrack", -1) return false end
  local env=reaper.GetTrackEnvelopeByName(track, "Mute")
  local retval
  if env==nil then
    ultraschall.PreventUIRefresh()
    local tracknumber=reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    retval = ultraschall.ApplyActionToTrack(tostring(tracknumber), 40866)
    if visible~=true then
      local env=reaper.GetTrackEnvelopeByName(track, "Mute")
      local A,B,C=ultraschall.GetEnvelopeState_Vis(env)
      ultraschall.SetEnvelopeState_Vis(env, 0,B,C)
    end
    ultraschall.RestoreUIRefresh()
  else 
    retval=false ultraschall.AddErrorMessage("ActivateMute_TrackObject", "", "already activated", -3)
  end
  return retval
end

SLEM()

function ultraschall.DeactivateMute_TrackObject(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>DeactivateMute_TrackObject</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.DeactivateMute_TrackObject(integer track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      deactivates a mute-envelope of a MediaTrack-object
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, deactivating was successful; false, deactivating was unsuccessful
    </retvals>
    <parameters>
      integer track - the track, whose mute-envelope you want to deactivate
    </parameters>
    <chapter_context>
      Mute Management
      Mute Lane
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
    <tags>envelope management, mute, deactivate</tags>
  </US_DocBloc>
  --]]
  if ultraschall.type(track)~="MediaTrack" then ultraschall.AddErrorMessage("DeactivateMute_TrackObject", "track", "must be a MediaTrack", -1) return false end
  local env=reaper.GetTrackEnvelopeByName(track, "Mute")
  local retval
  if env~=nil then
    local tracknumber=reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    retval = ultraschall.ApplyActionToTrack(tostring(tracknumber), 40866)
  else 
    retval=false ultraschall.AddErrorMessage("DeactivateMute_TrackObject", "", "already deactivated", -2)
  end
  return retval
end


function ultraschall.VideoWindow_FullScreenToggle(toggle)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>VideoWindow_FullScreenToggle</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.05
      Lua=5.3
    </requires>
    <functioncall>boolean fullscreenstate = ultraschall.VideoWindow_FullScreenToggle(optional boolean toggle)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      toggles fullscree-state of Reaper's video-processor-window 
        
      returns nil in case of error
    </description>
    <retvals>
      boolean fullscreenstate - true, video-window is now fullscreen; false, video-window is NOT fullscreen
    </retvals>
    <parameters>
      optional boolean toggle - true, sets video-window to fullscreen; false, sets video-window to windowed; nil, toggle between fullscreen and nonfullscreen states
    </parameters>
    <chapter_context>
      User Interface
      Window Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Muting_Module.lua</source_document>
    <tags>user interface, set, video window, fullscreen, windowed</tags>
  </US_DocBloc>
  --]]
  local Hwnd = ultraschall.GetVideoHWND()
  if Hwnd==nil then ultraschall.AddErrorMessage("VideoWindow_FullScreenToggle", "", "Video window not opened", -1) return end
  if toggle~=nil and type(toggle)~="boolean" then ultraschall.AddErrorMessage("VideoWindow_FullScreenToggle", "toggle", "must be a boolean or nil", -2) return end
  local CurState=ultraschall.GetUSExternalState("reaper_video", "fullscreen", "reaper.ini")=="1"
  if toggle==nil or toggle~=CurState then
    reaper.JS_WindowMessage_Send(Hwnd, "WM_LBUTTONDBLCLK", 1,1,0,0)
  end
  if toggle==nil then toggle=CurState==false end
  return toggle
end

ultraschall.ShowLastErrorMessage()
