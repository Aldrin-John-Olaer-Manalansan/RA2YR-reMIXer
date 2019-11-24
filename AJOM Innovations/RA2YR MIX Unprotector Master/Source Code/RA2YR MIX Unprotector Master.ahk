; force run as admin
if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)"))
{
    ; if a file is opened/dragged using this dota2 mod master, this code will able to detect them all and restart this script while still dragging this files to this script
	
	VarSetCapacity(draggedfiles,0)
	for n, GivenPath in A_Args  ; For each parameter (or file dropped onto a script):
	{
		Loop Files, %GivenPath%, F  ; Include files and directories.
		{
			if (A_LoopFileExt = "mix")
			{
				draggedfiles="%A_LoopFileLongPath%" %draggedfiles%
			}
		}
	}
	;
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart %draggedfiles% ; restart this script with admin priviledges, also redragg all dragged files to this script that is admin
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %draggedfiles% ; restart this script with admin priviledges, also redragg all dragged files to this script that is admin
    }
    ExitApp
}
;

#SingleInstance Force
#NoEnv
#KeyHistory 0
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
ListLines Off
CoordMode,ToolTip,Screen

global version:="1.0.0.0"

Menu,lvcontextmenu,Add,Remove,removefromlist

Gui Add, ListView, x1 y140 w172 h130 -LV0x10 NoSortHdr NoSort +Checked vignoredattrib_lv,Ignore MIX Files with this Attribute|%A_Space%
LV_Add("Check","CheckSummed","(01 Header Attribute)"),LV_Add("Check","Encrypted","(02 Header Attribute)"),LV_Add("Check","Local","(03 Header Attribute)"),LV_Add("Check","10 00 00 D4 94 04 B8 25 9F 98","(theme.mix)"),LV_Add("Check","0A 00 E0 02 CB 02 BA 1E 9D AB","(thememd.mix)")
LV_ModifyCol()

Gui Add,Button,x25 y280 gshowusagepopup,How to Use the Tool?
Gui Add,Edit,% "+ReadOnly x1 y310 w172 h" A_ScreenHeight-404,
(
RA2YR MIX Unprotected Master is a powerful tool designed to UNPROTECT MIX file headers, these will allow any PROTECTED MIX files to be openable by XCC Mixer Utility.

Trivia:
* What is a .mix File?
- it is a Compressed File like ".zip/.rar" used by RA2/RA2YR to store all of their crucial files in one place. It is the ART of being ORGANIZED!

* What is MIX Protection?
- MIX Protection means CORRUPTING the MIX file's HEADER, so that NOOBS trying to open .mix files in order to STEAL the works of other people will have some trouble over it.
- A smart way of protecting a mix file is deleting its local mix database.dat, so that recovering file names will be much harder to recover(although still possible to be recovered by translating its ID into file name)

* What is MIX Unprotection?
- MIX Unprotection means RECOVERING the MIX file's HEADER, so that "WhiteHat Hackers" can troubleshoot some problems stored on a MIX File.
- File Names(local mix database.dat) can be recovered by properly setting its ID information properly and translating all File IDs into File Names.
)
Gui Add, CheckBox,x1 y35 gshowhideextension vshowhideextension,Use Different Extension
Gui Add, Edit,Disabled x34 y55 w100 h21 +Center vTargetExtension,mix
Gui Add, Button, x34 y83 w101 h23 gbrowsemixfile,Add a Target File
Gui Add, Button, x34 y110 w101 h23 gbrowsemixfolder,Add a Target Folder
Gui Add, Button, x28 y8 w110 h23 gunprotecttargets,&Unprotect All Targets

Gui Add, ListView,% "w" A_ScreenWidth-200 " h" A_ScreenHeight-100 " x175 y6 +LV0x4000 +Checked Grid AltSubmit gunprotectfile_lv vunprotectfile_lv",Original Header|Unprotected Header|L.M.D. Status|FilePath
for n, GivenPath in A_Args  ; For each parameter (or file dropped onto a script):
{
	Loop Files, %GivenPath%, F  ; Include files and directories.
	{
		if (A_LoopFileExt = "mix")
		{
			FilePath:=A_LoopFileLongPath
			gosub,addmixfile
		}
	}
}
gosub,scanmixfiles

Gui Show,,RA2YR Mix Unprotector MASTER v%version% by aldrinjohnom
Return

showhideextension:
guicontrolget,showhideextension,,showhideextension
if showhideextension
	GUIControl,Enabled,TargetExtension
else GUIControl,Disabled,TargetExtension
return

showusagepopup:
Gui,+OwnDialogs
msgbox,
(
Usage:
*Add a Target File - Browse a Target file with a respective extension(eg .mix) that will be added on the Target List ->

*Add a Target Folder - Browse a folder and scans for any existing file that has the respective extension(eg .mix) to be added on the Target File List ->

*Target File List - It automatically Detects if a File's Header(eg .mix) is PROTECTED. It also filters any UNPROTECTED Files, removing them from the list.

*Target Extension - This Extension will be automatically scanned when selecting a "Target Folder".

*Unprotect all Target Files - Will UNPROTECT all CHECKED Targets on the List.

*MIX File Attributes Exclusion - there are four types of header attribute settled at its 3rd byte:
> 00(Expansion) - Inside this mix file are expansion mixes included to the game(first became possible when Yuri's Revenge was released)
> 01(CheckSummed)- Has a unique header and footer algorithm detecting if there are ERRORS/CORRUPTION on each file stored on the MIX
> 02(Encrypted) - Compacted the MIX, making it size even more smaller. But is HEADER DEPENDENT, meaning having a BAD Header will crash RA2YR
> 03(Local) - Files that existed on RA2(without expansion), although its Algorithm for calculating the header is still unknown. HAVING A BAD HEADER WILL also CRASH RA2YR.
- CheckSummed, Encrypted, and Local are almost untouchable(invulnerable to protection) meaning MIX files having this three attributes are automatically UNPROTECTED.
- You can UNCHECK this parameters to include them on scans(UNRECOMMENDED but still works).
)
return

removefromlist:
Gui,+Disabled
Gui,ListView,unprotectfile_lv
row = 0
Loop
{
    row := LV_GetNext(row - 1)
    if not row
        break
    LV_Delete(row)
}
Gui,-Disabled
return

unprotectfile_lv:
if A_GuiControl=unprotectfile_lv
{
	if A_GuiEvent=RightClick
	{
		Menu,lvcontextmenu, Show
	}
}
return

browsemixfile:
Gui -Disabled
GuiControlGet,TargetExtension,,TargetExtension
FileSelectFile,FilePath,3,,Select your Target Mix Files,MIX File (*.%TargetExtension%)
if FilePath=
	return
else
{
	Gui,ListView,unprotectfile_lv
	Loop % LV_GetCount()
	{
		LV_GetText(tmpr,A_Index,LV_GetCount("Column"))
		if (tmpr=FilePath)
			return
	}
}
addmixfile:
Gui +Disabled
unprotectedhex:=unprotectfirst10bytes(FilePath)
if RegExMatch(unprotectedhex,"Encrypted|CheckSummed|OverFlow|Local")
{
	if (A_GuiControl="")
		return
	
	if RegExMatch(unprotectedhex,"Encrypted|CheckSummed|Local")
		ToolTip,File got Rejected!`nThis .%TargetExtension% file has a "%unprotectedhex%" Attribute on its Header.,0,0,errortooltip
	else if unprotectedhex=OverFlow
		ToolTip,File got Rejected!`nThis .%TargetExtension% file has an UNFIXABLE header! It is hopeless unprotecting this .%TargetExtension% file.,0,0,errortooltip
	SetTimer,RemoveErrorToolTip,-2000
	goto,browsemixfile
}
else
{
	offsetarray:=getlmdaddressinfo(FilePath,False)
	if (offsetarray[1].Count()>0) and (offsetarray[2].Count()>0)
		lmdhealth=Recoverable
	else if (getfirst10bytes(FilePath,True)=unprotectedhex)
	{
		if (A_GuiControl="")
			return
		
		if (offsetarray[1].Count()=0) and (offsetarray[2].Count()=0)
			ToolTip,The Selected File is not PROTECTED!`nlocal mix database.dat Status: Healthy,0,0,errortooltip
		else ToolTip,The Selected File is not PROTECTED!`nlocal mix database.dat Status: Unrecoverable,0,0,errortooltip
		SetTimer,RemoveErrorToolTip,-2000
		goto,browsemixfile
	}
	else if (offsetarray[1].Count()=0) and (offsetarray[2].Count()=0)
		lmdhealth=Healthy
	else lmdhealth=UnRecoverable
}

originalhex:=getfirst10bytes(FilePath) ; detect the original header
;this check any ignored header values
Gui,ListView,ignoredattrib_lv
loop % LV_GetCount()-3 ; exclude the locals
{
	index:=A_Index+3 ; start at row 4 ignoring the "special headers" which is the encrypted,checksummed, and local
	If (index=LV_GetNext(index-1,"Checked")) ; if checked aka ignored
	{
		LV_GetText(tmpr,index,1)
		if (originalhex=tmpr) ; if this header was ignored ;RegExMatch(SubStr(FilePath,InStr(	FilePath,"\",True,0)+1),"theme.mix|thememd.mix")
		{
			if (A_GuiControl="")
				return
	
			LV_GetText(tmpr1,index,2)
			ToolTip,File got Rejected!`nThis .%TargetExtension% file's Header is at the Ignored List:`n%tmpr% %tmpr1%,0,0,errortooltip
			SetTimer,RemoveErrorToolTip,-2000
			goto,browsemixfile
		}
	}
}
;
; if this was reached, it means that this file can be UNPROTECTED
Gui,ListView,unprotectfile_lv
LV_Add((lmdhealth!="UnRecoverable"?"Check":""),originalhex,unprotectedhex,lmdhealth,FilePath) ; include it at the list
loop % LV_GetCount("Column")
{
	LV_GetText(tmpr,0,A_Index)
	if tmpr=FilePath
		LV_ModifyCol(A_Index,"AutoHDR")
	else LV_ModifyCol(A_Index,"AutoHDR Center")
}
Gui -Disabled
return

RemoveErrorToolTip:
ToolTip,,,,errortooltip
return

browsemixfolder:
FileSelectFolder,ScanPath,*%_ScanPath%,3,Select the Folder Containing Mix Files
scanmixfiles:
if ScanPath=
	return
_ScanPath:=ScanPath
Gui +Disabled

;list the ignored headers
Gui,ListView,ignoredattrib_lv
Loop % LV_GetCount()-3
{
	index:=A_Index+3 ; start at row 4 ignoring the "special headers" which is the encrypted,checksummed, and local
	If (index=LV_GetNext(index-1,"Checked")) ; if checked aka ignored
	{
		LV_GetText(tmpr,index,1)
		param1.=(A_Index=1?"":">") tmpr
	}
}
;list all the filespath that are currently listed
Gui,ListView,unprotectfile_lv
Loop % LV_GetCount()
{
	LV_GetText(tmpr,A_Index,LV_GetCount("Column"))
	param.=(A_Index=1?"":"`n") tmpr
}

GuiControlGet,TargetExtension,,TargetExtension
TargetExtension:=LTrim(TargetExtension,".") ; remove the dot at the beggining
Loop,Files,%ScanPath%\*.%TargetExtension%,FR
{
	tmpr:=A_LoopFileLongPath
	skip:=0
	loop,parse,param,`n
	{
		if (tmpr=A_LoopField)
		{
			skip:=1
			break
		}
	}
	if skip
		continue
	
	gui,show,,%A_LoopFileName% : Checking Unprotection Validity
	originalhex:=getfirst10bytes(A_LoopFileLongPath)
	unprotectedhex:=unprotectfirst10bytes(A_LoopFileLongPath)
	if !RegExMatch(unprotectedhex,"Encrypted|CheckSummed|OverFlow|Local") and !RegExMatch(param1,"(>|^)" originalhex "(>|$)")
	{
		gui,show,,%A_LoopFileName% : Analyzing Local Mix Database
		
		offsetarray:=getlmdaddressinfo(A_LoopFileLongPath,False)
		if (offsetarray[1].Count()>0) and (offsetarray[2].Count()>0)
			lmdhealth=Recoverable
		else if (offsetarray[1].Count()=0) and (offsetarray[2].Count()=0)
			lmdhealth=Healthy
		else lmdhealth=UnRecoverable
		
		if (getfirst10bytes(A_LoopFileLongPath,True)!=unprotectedhex) or (lmdhealth="Recoverable")
		{
			;if this was reached, that means it can be UNPROTECTED
			LV_Add((lmdhealth!="UnRecoverable"?"Check":""),getfirst10bytes(A_LoopFileLongPath),unprotectedhex,lmdhealth,A_LoopFileLongPath)
		}
	}
}
loop % LV_GetCount("Column")
{
	LV_GetText(tmpr,0,A_Index)
	if tmpr=FilePath
		LV_ModifyCol(A_Index,"AutoHDR")
	else LV_ModifyCol(A_Index,"AutoHDR Center")
}
gui,show,,RA2YR Mix Unprotector MASTER v%version% by aldrinjohnom
Gui -Disabled
return

unprotecttargets:
unprotecttargets()
return

unprotecttargets()
{
Gui +Disabled
Gui,ListView,unprotectfile_lv
rowcount:=LV_GetCount()
loop % rowcount
{
	lv_index:=rowcount-A_Index+1
	If (lv_index=LV_GetNext(lv_index-1,"Checked"))
	{
		LV_GetText(TargetFile,lv_index,LV_GetCount("Column"))
		
		_filename:=SubStr(TargetFile,InStr(TargetFile,"\",,0)+1)
		
		gui,show,NoActivate,% "Validating " _filename
		unprotectedhex:=unprotectfirst10bytes(TargetFile) ; get the unprotected first 10 bytes of this file
		if RegExMatch(unprotectedhex,"Encrypted|CheckSummed|OverFlow|Local")
			continue
		
		gui,show,NoActivate,% "Detecting local mix database.dat of " _filename
		; returns
		; offsetarray[1]	-	(address of unused lmd file)
		; offsetarray[2]	-	(address of corrupted lmd ID reference)
		offsetarray:=getlmdaddressinfo(TargetFile)
		
		TargetFileContent:=FileOpen(TargetFile,"rw") ; reopen the mix file ;read all contents of the file and activate write mode
		
		if (offsetarray[1].Count()>1) ; some mix files have multiple local mix database inside the file when the references are distributed among them, this detects them all and MERGES them into one local mix database, appending at the end of the MIX contents
		{
			gui,show,NoActivate,% "Merging all local mix database.dat of " _filename
			FileDelete,%A_Temp%\AJOM Innovations\local mix database.dat ; empty the file by deleting it
			lmdcontent:=FileOpen(A_Temp "\AJOM Innovations\local mix database.dat", "rw") ;inittially create a file object
			lmdcontent.Length:=52 ;  set the capacity of the lmd content to the header size(52 bytes)(52-1 because it start at 0 to 51 = 52)
			lmdcontent.pos:=0
			param=0x20434358,0x4F207962,0x2066616C,0x206E6176,0x20726564,0x6B657053,0x2717041A,0x00801910
			loop,parse,param,`,
				lmdcontent.WriteUInt(A_LoopField) ; write the lmd message header here at the end(32 bytes)
			lmdcontent.pos:=44,lmdcontent.WriteUChar(2) ; write the lmd game type at the header here(4 bytes)  starting at 45th byte - 0x02 for ts,0x05 for ra,0x06 for ra2yr - I used 0x02(ts) because it is compatible for both ra2 and ra2yr
			lmdcontent.pos:=52 ; set the writer pointer to the 53rd byte since the first 52 bytes is the lmd header
			
			filecount:=0 ;prepare for the loop by start counting at zero going inside the loop
			for index, in offsetarray[1]
			{
				TargetFileContent.Pos := offsetarray[1,index]+32 ;this sets the pointer starting before 33rd byte respect to the "offset" of this parameter
				lmdsize:=TargetFileContent.ReadUInt()-52 ; read this lmd size(4 bytes) and subtract 52 since the lmd header is 52 bytes
				
				TargetFileContent.Pos +=12 ;this sets the pointer starting before 49th byte respect to the "offset" of this parameter
				filecount+=TargetFileContent.ReadUInt() ; read the number of file entries inside this lmd(4 bytes)
				
				lmdcontent.Length+=lmdsize ; increase the capacity of lmd content by the amount of bytes equal to this lmd size
				VarSetCapacity(fileentries,0),VarSetCapacity(fileentries,lmdsize,0) ; the dummy variable which streams/extracts the lmd binary data on the mix file ; initially setting to zero
				TargetFileContent.RawRead(fileentries,lmdsize) ; streams/extracts the lmd binary data on the mix file
				lmdcontent.RawWrite(fileentries,lmdsize) ; write the streamed lmd data at the ending byte of the lmd content
				
				;;;;lmd deletion stage ; remove autodeletion of lmd since it corrupts mix files when there is a mix inside a mix
				;rightmostmixsize:=TargetFileContent.Length-TargetFileContent.Pos
				;VarSetCapacity(rightmostmixcontent,rightmostmixsize) ;make sure that the rightmostmixcontent variable has the proper capacity by exactly equating its total number of bytes into the number of bytes that will be saved to this variable
				;TargetFileContent.RawRead(rightmostmixcontent,rightmostmixsize) ; read the right-most mix from the next  byte after the last byte of the lmd content up to the last byte of the mix file
				;
				;TargetFileContent.Length-=lmdsize+52 ; decrease the filesize by an amount of this lmd file size(because we are deleting at in a raw way)
				;
				;TargetFileContent.Pos := offsetarray[1,index] ; set the writer pointer to the position of the lmd file
				;TargetFileContent.RawWrite(rightmostmixcontent,rightmostmixsize)
				;;;;
			}
			
			lmdcontent.pos:=32,lmdcontent.WriteUInt(lmdcontent.Length) ; write the lmd size at the header here(4 bytes) starting at 33rd byte
			lmdcontent.pos:=48,lmdcontent.WriteUInt(filecount) ;write the lmd size at the header here(4 bytes) starting at 49th byte
			
			TargetFileContent.Pos:=TargetFileContent.Length ; set the writer pointer at the end of this file
			
			offsetarray[1,1]:=TargetFileContent.Pos ;set the new lmd offset to this value that will be used later for recovering the lmd id reference
			
			TargetFileContent.Length+=lmdcontent.Length ; increase the size of the mix file that fits on the amount of bytes that will be written after this command, take note that the pointer(TargetFileContent.Pos) will not move
			
			VarSetCapacity(fileentries,0),VarSetCapacity(fileentries,lmdsize,0) ; the dummy variable which streams/extracts the lmd binary data on the mix file ; initially setting to zero
			lmdcontent.pos:=0 ; start before the first byte since we are extracting the whole file
			lmdcontent.RawRead(fileentries,lmdcontent.Length) ; streams/extracts the lmd binary data on our artificially created lmd file
			TargetFileContent.RawWrite(fileentries,lmdcontent.Length) ; write the lmd content here at the end
			
			lmdcontent.Length:=0,lmdcontent.Close(),VarSetCapacity(lmdcontent,0) ; clean the filecontent
			VarSetCapacity(fileentries,0),VarSetCapacity(rightmostmixcontent,0) ;erase the binary variables
			
			TargetFileContent.Close() ; save then close the lmd appended mix file
			unprotectedhex:=unprotectfirst10bytes(TargetFile) ; get the unprotected first 10 bytes of this file
			TargetFileContent:=FileOpen(TargetFile,"rw") ; reopen the mix file ;read all contents of the file and activate write mode
		}
		
		if !RegExMatch(unprotectedhex,"Encrypted|CheckSummed|OverFlow|Local")
		{
			if (offsetarray[1].Count()>0) and (offsetarray[2].Count()>0) ; if there is a corrupted lmd
			{
				gui,show,NoActivate,% "Recovering FileNames inside " _filename
				; get the lmd hex offset
				TargetFileContent.pos:=4 ;set the offset of the pointer before the 5th byte
				filecount:=TargetFileContent.ReadUShort() ; get the filecount(2 bytes)
				bodycount:=(filecount*12)+10 ; formula of bodycount
				lmdhexoffset:=offsetarray[1,1]-bodycount ; formula of hexoffset
				
				;get the lmd size
				TargetFileContent.Pos := offsetarray[1,1]+32 ;this sets the pointer starting before 33rd byte respect to the "offset" of this parameter
				lmdsize:=TargetFileContent.ReadUInt() ; read the lmd size(4 bytes)
				
				; recover the lmd id reference
				TargetFileContent.Pos := offsetarray[2,1]+4 ;this sets the pointer starting before 5th byte respect to the "offset" of this parameter
				TargetFileContent.WriteUInt(lmdhexoffset) ; write the hexoffset(4 bytes)
				TargetFileContent.WriteUInt(lmdsize) ; write the lmd size(4 bytes)
				
				gui,show,NoActivate,% "Unprotecting " _filename
				TargetFileContent.Pos := 0 ;necessary if file is UTF-8/UTF-16 LE ; this sets the pointer starting before first byte
				loop,parse,unprotectedhex,%A_Space%
					TargetFileContent.WriteUChar("0x" A_LoopField) ; Patch the first 10 bytes of the mix file, making it UNPROTECTED
			}
			
		}
		TargetFileContent.Close() ; save then close the unprotected mix file
		LV_Delete(lv_index)
	}
}
Gui,Flash,on
SetTimer,removeflash,-2000
Gui Show,,RA2YR Mix Unprotector MASTER v%version% by aldrinjohnom
Gui -Disabled
}

removeflash:
Gui,Flash,off
return

getlmdaddressinfo(TargetFile,writeenabled:=True)
/*
this function returns a 2-D array
offsetarray[1] - an array of unused lmd file's Address
usage:
offsetarray[1].Count() - can identify how many unused lmd file address are found - return "n" which is the maximum number of elements this array has
offsetarray[1,1] - the first index of offsetarray[1]
offsetarray[1,n] - the last index of offsetarray[1]

offsetarray[2] - an array of corrupted lmd id reference's Address
usage:
offsetarray[2].Count() - can identify how many corrupted lmd id reference Address are found - return "n" which is the maximum number of elements this array has
offsetarray[2,1] - the first index of offsetarray[1]
offsetarray[2,n] - the last index of offsetarray[1]
*/
{
	; 584343206279204F6C61662076616E20646572205370656B1A04172710198000 - XCC by Olaf van der Spek 0x1a 0x04 0x17 0x27 0x10 0x19 0x80 0x00
	; 1f056e36 - lmd ID
	offsetarray:=gethexoffset([[TargetFile,"584343206279204F6C61662076616E20646572205370656B1A04172710198000",0],[TargetFile,"1f056e36",0]]) ; get the offset of the lmd first
	if writeenabled
		TargetFileContent:=FileOpen(TargetFile,"rw") ; read all contents of the file and activate write mode
	else TargetFileContent:=FileOpen(TargetFile,"r") ; read all contents of the file
	
	TargetFileContent.pos:=4 ;set the offset of the pointer before the 5th byte
	filecount:=TargetFileContent.ReadUShort() ; get the filecount(2 bytes)
	bodycount:=(filecount*12)+10 ; formula of bodycount ; bodycount is the occupied number of bytes of the mix header(10 bytes) plus number of files(12 bytes each)
	
	if !((offsetarray[2].Count()>0) and offsetarray[2,1]!="") ; detects if the LMD ID was NULLIFIED(does not exist)
	{ ; append the LMD ID on the MIX File
		TargetFileContent.pos:=10 ; set the byte pointer before the 11th byte
		loop %filecount%
		{
			fileID:=TargetFileContent.ReadUInt()
			fileoffset:=TargetFileContent.ReadUInt()+bodycount
			filesize:=TargetFileContent.ReadUInt()
			; fileoffset>TargetFileContent.Length-12 means that id reference cannot exceed 12 bytes before the file size because the file id reference is 12 bytes
			if (fileID<=0) or (fileID>=0xFFFFFFFF) or (fileoffset<0) or (fileoffset>TargetFileContent.Length-12) or (filesize<0) or (filesize>TargetFileContent.Length)
			{
				; we will use this offset ID as our LMD ID reference that will be used by this mix file
				TargetFileContent.pos-=12 ; fileid,fileoffset,and filesize are 4 bytes each total of 12 bytes, we willgo back to 12 bytes to patch this three parameters
				offsetarray[2,1]:=TargetFileContent.pos ; set the offset of the pointer to the lmd ID(offsetarray[2,1] is the reference where the lmd id is located)
				if writeenabled
					TargetFileContent.WriteUInt(0x366e051f) ; write the lmd ID in little endian order
				
				break
			}
		}
	}
	else ;detect if there is a corrupted lmd
	{
		lmdcount:=offsetarray[2].Count()
		loop %lmdcount%
		{
			index:=lmdcount-A_Index+1
			
			if (offsetarray[2,index]<bodycount) ; if it is in the ID section ; sincce offsetarray is an array of lmd id reference, meaning it should not be at the "files" section(bodycount and above)
			{
				TargetFileContent.pos:=offsetarray[2,index]+4 ;set the offset of the pointer before the 5th byte at the offset
				lmdoffset:=TargetFileContent.ReadUInt()+bodycount ; 5th-8th byte = hexoffset , hexoffset+bodycount=offset
				lmdsize:=TargetFileContent.ReadUInt()
				; lmdoffset>TargetFileContent.Length-12 means that id reference cannot exceed 12 bytes before the file size because the file id reference is 12 bytes
				if (lmdoffset<0) or (lmdoffset>TargetFileContent.Length-12) or (lmdsize<0) or (lmdsize>TargetFileContent.Length)
					continue
				
				;check if the lmd file header is healthy
				TargetFileContent.pos:=lmdoffset
				param:=0x20434358+0 "," 0x4F207962+0 "," 0x2066616C+0 "," 0x206E6176+0 "," 0x20726564+0 "," 0x6B657053+0 "," 0x2717041A+0 "," 0x00801910+0 "," lmdsize
				tmpr:=""
				loop % 36/4 ; stepsize is by 4 bytes from a 32 bytes lmd header + 4 bytes lmdsize = 36 bytes
					tmpr.=(A_Index=1?"":",") TargetFileContent.ReadUInt()
				if (tmpr!=param) ; the header is corrupted
					continue
				;
			}
			
			; if it gets here meaning its header is healthy
			for i, in offsetarray[1]
			{
				if (offsetarray[1,i]=lmdoffset)
				{
					offsetarray[1].RemoveAt(i)
					break
				}
			}
			offsetarray[2].RemoveAt(index)
		}
		if (offsetarray[2].Count()=1) and (offsetarray[1].Count()>1)  ; if only one valid lmd id remains while the number of lmd file on the list is 2 or more
		{
			TargetFileContent.pos:=10 ; set the byte pointer before the 11th byte
			loop %filecount%
			{
				fileID:=TargetFileContent.ReadUInt()
				fileoffset:=TargetFileContent.ReadUInt()+bodycount
				filesize:=TargetFileContent.ReadUInt()
				for index, in offsetarray[1]
				{
					; we are hunting a mix inside a mix possibility:
					;1) the mix at the fileoffset must have a valid 10 byte header and a 12 byte id reference, therefore the considerable lmdoffset of this mix is at 23rd byte and above
					;2) the lmd of this mix file has an initial 52 bytes as the lmd header, therefore the considerable max offset cannot exceed above the distance of 52 bytes with respect to its lmd offset
					if (fileID!=0x366e051f) and (offsetarray[1,index]>fileoffset+22) and (offsetarray[1,index]<=fileoffset+filesize-52)
					{ ; there will be a time that offsetarray[1].Count() can be zero meaning there is no LMD File for this MIX File, therefore it is UNRECOVERABLE
						offsetarray[1].RemoveAt(index) ; this lmd is an lmd inside an mix of this MIX, aka mix inside a mix with an lmd
						break
					}
				}
			}
		}
	} ; now, reaching here makes the offsetarray[1] is the list of unused lmd file and offsetarray[2] is the list of corrupted id references
	return offsetarray
}

getfirst10bytes(TargetFile,3rdbytezero:=False)
; 3rdbytezero - set to TRUE or any value to make the 3rd byte zero
; 3rd byte determines if the mix file is 01 if checksummed, 02 if encrypted, 00 otherwise. Should always be 00 on protected mixes.
; 3rd byte has no e
{
	TargetFileContent:=FileOpen(TargetFile,"r") ; read mode
	if !TargetFileContent ; if failed opening the file return blank value
		return
	
	TargetFileContent.Pos := 0 ;necessary if file is UTF-8/UTF-16 LE ; this sets the pointer starting before 5th byte
	loop 10
	{
		if A_Index=1
			hex .= Format("{:02X}",TargetFileContent.ReadUChar()) ;reads 1st byte to 10th bytes
		else if (3rdbytezero!=False) and (A_Index<=3)
		{
			3rdbyte:=TargetFileContent.ReadUChar() ; reads the 3rd byte
			if 3rdbyte<=2
				hex .= " 00" ;3rd bytes become zero
			else hex .= " " Format("{:02X}",3rdbyte) ; the 3rd byte is corrupted so show it to the user
		}
		else hex .= " " Format("{:02X}",TargetFileContent.ReadUChar()) ;reads 1st byte to 10th bytes
	}
	return hex
}

unprotectfirst10bytes(TargetFile)
/*
returns 4 possible results
-	(Unprotected 10 bytes)
-	CheckSummed	-	if 3rd byte says that the files is CheckSummed, this is impossible to be protected, therefore it is unprotected
-	Encrypted	-	if 3rd byte says that the files is encrypted, this is impossible to be protected, therefore it is unprotected
-	OverFlow	-	if the BodySize(7th to 10th bytes) becomes negative, the system will not continue(The File must be corrupted)
*/
{
	TargetFileContent:=FileOpen(TargetFile,"r") ; read mode
	if !TargetFileContent ; if failed opening the file return blank value
		return
	
	;get 3rd byte
	TargetFileContent.Pos := 2 ;necessary if file is UTF-8/UTF-16 LE ; this sets the pointer starting before 3rd byte
	tmpr:=TargetFileContent.ReadUChar()
	Gui,ListView,ignoredattrib_lv
	if (tmpr=1) and LV_GetNext(0,"Checked")
		return "CheckSummed"
	else if (tmpr=2) and LV_GetNext(1,"Checked")
		return "Encrypted"
	else if (tmpr=3) and LV_GetNext(2,"Checked")
		return "Local"
	Gui,ListView,unprotectfile_lv
	;
	
	unprotectedhex:="00 00 00 00" ; the first 4 bytes should be set to zero
	
	TargetFileContent.Pos := 4 ;necessary if file is UTF-8/UTF-16 LE ; this sets the pointer starting before 5th byte
	
	hex := Format("{:02X}",TargetFileContent.ReadUChar()) ;reads 5th byte the advances pointer to 6th byte
	unprotectedhex.=" " hex ; the 5th byte is always OK
	littleendianhex:=hex ; save the hex value to be used at loop 6
	hex := Format("{:02X}",TargetFileContent.ReadUChar()) ;reads 6th byte the advances pointer to 7th byte
	unprotectedhex.=" " hex ; the 5th byte is always OK
	littleendianhex=0x%hex%%littleendianhex% ; encode the little endian format of 5th to 6th byte
	countinsidefile:=littleendianhex+0 ; convert decimal value, this is the number of files inside the mix file
	
	;FileGetSize,filesize,%TargetFile% ; get the filesize in bytes
	;BodySize:=filesize-((countinsidefile*12)+10) ; formula for calculating the body size
	BodySize:=TargetFileContent.Length-((countinsidefile*12)+10) ; formula for calculating the body size
	TargetFileContent.Close() ; close the file since reading is done anyway
	if BodySize<0 ; BodySize can't be negative, if yes meaning it overflows, protection is impossible to be done on an overflowing bodysize... Therefore it is considered as UNPROTECTED
		return "OverFlow"
	BodySize:=Format("{:x}",BodySize) ; convert decimal bodysize into hex
	loop % 8-strlen(BodySize)
		BodySize=0%BodySize% ; add extra zero at start so that the arrangement of hex is by two's
	BodySize := RegExReplace(BodySize,".."," $0",,,3) ; isolate each bytes(by two hex)
	loop,parse,BodySize,%A_Space% ; convert into little endian
	{
		if A_Index=1
			BodySize:=A_LoopField
		else BodySize=%A_LoopField% %BodySize%
	}
	
	unprotectedhex.=" " BodySize ; final hex output
return unprotectedhex
}

gethexoffset(infoarray)
;file-	can be an array or variable
;hex
;limit	-	number of occurence that will be used
{
	infocount:=infoarray.Count()
	loop %infocount%
	{
		file:=infoarray[A_Index,1]
		hex:=infoarray[A_Index,2]
		FileDelete,%A_ScriptDir%\Plugins\Swiss File Knife\dump_offset%A_Index%.txt
		if (infoarray[A_Index,3]=1)
			run,"%A_Comspec%" /c ""%A_ScriptDir%\Plugins\Swiss File Knife\sfk.exe" hexfind "%file%" -firsthit -quiet -bin /%hex%/ > "%A_ScriptDir%\Plugins\Swiss File Knife\dump_offset%A_Index%.txt"",,hide,cmdpid%A_Index%
		else
			run,"%A_Comspec%" /c ""%A_ScriptDir%\Plugins\Swiss File Knife\sfk.exe" hexfind "%file%" -quiet -bin /%hex%/ > "%A_ScriptDir%\Plugins\Swiss File Knife\dump_offset%A_Index%.txt"",,hide,cmdpid%A_Index%
	}
	offsetarray:=[[]]
	DetectHiddenWindows,On
	SetTitleMatchMode, 2
	SetTitleMatchMode, Slow
	loop %infocount%
	{
		index:=A_Index
		Process,Exist,% cmdpid%index%
		If ErrorLevel
			Process,WaitClose,% cmdpid%index%
		;if WinExist("ahk_pid " cmdpid%index%)
		;	WinWaitClose,% "ahk_pid " cmdpid%index%
	
		FileRead,report,%A_ScriptDir%\Plugins\Swiss File Knife\dump_offset%index%.txt
		
		if (infoarray[index,3]>0)
			count:=infoarray[index,3]
		else
			strreplace(report,"hit at offset ",,count)
		loop %count%
		{
			posin:=instr(report,"hit at offset ",,,A_Index)+14
			if posin<=14
				break
			posout:=instr(report,"`r`n",,posin)
			offsetarray[index,A_Index]:=SubStr(report,posin,posout-posin)
		}
		
		if (count>1) ; if there are more occurence of the ID then sort them from highest to lowest
			offsetarray[index]:=sortarray(offsetarray[index])
	}
	DetectHiddenWindows,Off
	return offsetarray
}

sortarray(array,options:="U R N")
;for more informations about the options, visit this URL:
;https://www.autohotkey.com/docs/commands/Sort.htm
{
	if !instr(options,"D") ; if the user did not choose any delimiters, then choose a smart delimiter
	{
		;"Smart Delimiter Detection" of an Array
		;find the right delimiter that does is "not a substring" of each elements of the array 
		loop 94 ; ascii 33 to ascii 126 ; (126-33)+1=94 ; has +1 because A_Index start at 1
		{
			delimiter:=chr(32+A_Index) ; callibrating delimiter from ascii 33 to 126
			
			usedelimiter:=1
			for index,value in array
			{
				if (value=delimiter) ; if delimiter is used
				{
					usedelimiter:=0
					break
				}
			}
			
			if (usedelimiter=1) ; if the delimiter does not occurred on the elements of the array
			{
				options.=" D" delimiter ; add the delimiter at the options
				break
			}
		} ; if there are no right delimiters, the "sort"'s default delimiter will be used which is "`n"
	}
	else delimiter:=RegExMatch(options,"(?<=D).*?(?=(\s|$))")
	;
	
	;put the array into a field of parameters with a delimiter on each other
	param=
	for index,value in array
		param.=(param=""?"":delimiter) value
	;
	
	Sort,param,%options%
	
	;reconstruct the array using the sorted field the delimited parameters
	array:=[]
	loop,parse,param,%delimiter%
		array[A_Index]:=A_LoopField
	;
	
	return array ; the array's key are field of indexes starting from 1 to n
}

guiclose:
exitapp
