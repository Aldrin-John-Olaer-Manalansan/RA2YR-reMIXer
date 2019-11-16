#SingleInstance Force
#NoEnv
#KeyHistory 0
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
ListLines Off
CoordMode,ToolTip,Screen

global version=0.0.1.0

Menu,lvcontextmenu,Add,Remove,removefromlist

Gui Add, ListView, x1 y140 w172 h130 -LV0x10 NoSortHdr NoSort +Checked vignoredattrib_lv,Ignore MIX Files with this Attribute|%A_Space%
LV_Add("Check","CheckSummed","(01 Header Attribute)"),LV_Add("Check","Encrypted","(02 Header Attribute)"),LV_Add("Check","Local","(03 Header Attribute)"),LV_Add("Check","10 00 00 d4 94 04 b8 25 9f 98","(theme.mix)"),LV_Add("Check","0a 00 e0 02 cb 02 ba 1e 9d ab","(thememd.mix)")
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

* What is MIX Unprotection?
- MIX Unprotection means RECOVERING the MIX file's HEADER, so that "WhiteHat Hackers" can troubleshoot some problems stored on a MIX File.
)
Gui Add, CheckBox,x1 y35 gshowhideextension vshowhideextension,Use Different Extension
Gui Add, Edit,Disabled x34 y55 w100 h21 +Center vTargetExtension,mix
Gui Add, Button, x34 y83 w101 h23 gbrowsemixfile,Add a Target File
Gui Add, Button, x34 y110 w101 h23 gbrowsemixfolder,Add a Target Folder
Gui Add, Button, x28 y8 w110 h23 gunprotecttargets,&Unprotect All Targets

Gui Add, ListView,% "w" A_ScreenWidth-200 " h" A_ScreenHeight-100 " x175 y6 +LV0x4000 +Checked Grid AltSubmit gunprotectfile_lv vunprotectfile_lv",Original Header|Unprotected Header|FilePath
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
	Loop % LV_GetCount()
	{
		LV_GetText(tmpr,A_Index,3)
		if (tmpr=FilePath)
			return
	}
}
Gui +Disabled
unprotectedhex:=unprotectfirst10bytes(FilePath)
if RegExMatch(unprotectedhex,"Encrypted|CheckSummed|OverFlow|Local")
{
	if RegExMatch(unprotectedhex,"Encrypted|CheckSummed|Local")
		ToolTip,File got Rejected!`nThis .%TargetExtension% file has a "%unprotectedhex%" Attribute on its Header.,0,0,errortooltip
	else if unprotectedhex=OverFlow
		ToolTip,File got Rejected!`nThis .%TargetExtension% file has an UNFIXABLE header! It is hopeless unprotecting this .%TargetExtension% file.,0,0,errortooltip
	SetTimer,RemoveErrorToolTip,-2000
	goto,browsemixfile
}
else if (getfirst10bytes(FilePath,True)=unprotectedhex)
{
	ToolTip,The Selected File is not PROTECTED!,0,0,errortooltip
	SetTimer,RemoveErrorToolTip,-2000
	goto,browsemixfile
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
LV_Add(,originalhex,unprotectedhex,FilePath) ; include it at the list
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
		if A_Index=1
			param1=%tmpr%
		else param1.=">" tmpr
	}
}
;list all the filespath that are currently listed
Gui,ListView,unprotectfile_lv
Loop % LV_GetCount()
{
	LV_GetText(tmpr,A_Index,3)
	if A_Index=1
		param=%tmpr%
	else param.=">" tmpr
}

GuiControlGet,TargetExtension,,TargetExtension
TargetExtension:=LTrim(TargetExtension,".") ; remove the dot at the beggining
Loop,Files,%ScanPath%\*.%TargetExtension%,FR
{
	originalhex:=getfirst10bytes(A_LoopFileFullPath)
	unprotectedhex:=unprotectfirst10bytes(A_LoopFileFullPath)
	if !RegExMatch(unprotectedhex,"Encrypted|CheckSummed|OverFlow|Local") and !RegExMatch(param,"(>|^)" A_LoopFileFullPath "(>|$)") and !RegExMatch(param1,"(>|^)" originalhex "(>|$)") and (getfirst10bytes(A_LoopFileFullPath,True)!=unprotectedhex) ; and !RegExMatch(A_LoopFileName,"theme.mix|thememd.mix")
	{
		;if this was reached, that means it can be UNPROTECTED
		gui,show,,Detecting Protected Files: Found %A_LoopFileName%
		LV_Add(,getfirst10bytes(A_LoopFileFullPath),unprotectedhex,A_LoopFileFullPath)
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
Gui +Disabled
Gui,ListView,unprotectfile_lv
rowcount:=LV_GetCount()
loop % rowcount
{
	index:=rowcount-A_Index+1
	If (index=LV_GetNext(index-1,"Checked"))
	{
		LV_GetText(TargetFile,index,3)
		unprotectedhex:=unprotectfirst10bytes(TargetFile) ; get the unprotected first 10 bytes of this file
		if (unprotectedhex!="Encrypted") and (unprotectedhex!="CheckSummed") and (unprotectedhex!="OverFlow")
		{
			TargetFileContent:=FileOpen(TargetFile,"rw") ; read all contents of the file and activate write mode
			TargetFileContent.Pos := 0 ;necessary if file is UTF-8/UTF-16 LE ; this sets the pointer starting before first byte
			loop,parse,unprotectedhex,%A_Space%
				TargetFileContent.WriteUChar("0x" A_LoopField) ; Patch the first 10 bytes of the mix file, making it UNPROTECTED
			TargetFileContent.Close() ; save then close the unprotected mix file
		}
		LV_Delete(index)
	}
}
MsgBox,,Status,UNPROTECTION OPERATION COMPLETE!,2
Gui -Disabled
return

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
	bigendianhex:=hex ; save the hex value to be used at loop 6
	hex := Format("{:02X}",TargetFileContent.ReadUChar()) ;reads 6th byte the advances pointer to 7th byte
	TargetFileContent.Close() ; close the file since reading is done anyway
	unprotectedhex.=" " hex ; the 5th byte is always OK
	bigendianhex=0x%hex%%bigendianhex% ; encode the big endian format of 5th to 6th byte
	countinsidefile:=bigendianhex+0 ; convert decimal value, this is the number of files inside the mix file
	
	FileGetSize,filesize,%TargetFile% ; get the filesize in bytes
	BodySize:=filesize-((countinsidefile*12)+10) ; formula for calculating the body size
	if BodySize<0 ; BodySize can't be negative, if yes meaning it overflows, protection is impossible to be done on an overflowing bodysize... Therefore it is considered as UNPROTECTED
		return "OverFlow"
	BodySize:=Format("{:x}",BodySize) ; convert decimal bodysize into hex
	loop % 8-strlen(BodySize)
		BodySize=0%BodySize% ; add extra zero at start so that the arrangement of hex is by two's
	BodySize := RegExReplace(BodySize,".."," $0",,,3) ; isolate each bytes(by two hex)
	loop,parse,BodySize,%A_Space% ; convert into big endian
	{
		if A_Index=1
			BodySize:=A_LoopField
		else BodySize=%A_LoopField% %BodySize%
	}
	
	unprotectedhex.=" " BodySize ; final hex output
return unprotectedhex
}

guiclose:
exitapp
