# RA2YR reMIXer
## v2.0.0.0
------------

<div align="center">
<b>About</b></div>

***RA2YR reMIXer is a powerful tool designed to reconstruct RA2YR MIX files. We do this in order to:***

1) Reduce the file size of the MIX File by removing unused content inside the MIX File.
2) Reverse/Remove Modern MIX Protection Techniques like:
    - Header Corruption resulting XCC Mixer to fail on browsing the MIX File.
    - LMD Lookup Table Corruption resulting XCC Mixer to show incorrect file names that are found inside the MIX File. 

RA2YR reMIXer is formerly known as `RA2 MIX Unprotector Master`

------------

<div align="center">
<b>Trivia</b></div>

What is a .mix File?<br>
*it is a Compressed File like ".zip/.rar" used by RA2/RA2YR to store all of their crucial files in one place. It is the ART of being ORGANIZED!*<br>

What is MIX Protection?<br>
*MIX Protection means CORRUPTING the MIX file's HEADER, so that NOOBS trying to open .mix files in order to STEAL the works of other people will have some trouble over it.*<br>

What is MIX Unprotection?<br>
*MIX Unprotection means RECOVERING the MIX file's HEADER, so that "WhiteHat Hackers" can troubleshoot some problems stored on a MIX File.*<br>

What is LMD Corruption?<br>
*XCC Mixer uses local mix database.dat(LMD) File to know all the file names that are found inside the MIX. When LMD Informations becomes corrupted, XCC Mixer will fail on recognizing the file name of each file. These Important LMD Informations were:*<br>
*1. LMD LookUp Table - Common MIX Protectors corrupts this by puting 12 bytes of garbage value. But this can be recovered as long as the LMD File itself is present inside the MIX File.*<br>
*2. LMD File itself - Modern MIX Protectors today removes the LMD File entirely inside the MIX File. So there is no way of recovering the File names if this happens.<br>*

What is LMD Recovery?<br>
*It means we are restoring the file names one by one from LMD remnants found inside the MIX File, then fix the LMD Lookup Table to let XCC recognize file names once again.*

------------

<div align="center">
<b>Installation</b></div>

1. Download the [Latest Released Executable file](https://github.com/Aldrin-John-Olaer-Manalansan/RA2YR-reMIXer/releases/download/Latest-Executable/reMIXer.exe).
2. Put this file anywhere you want. I suggest putting it inside a folder so that the generated files during runtime are organized inside the folder.
3. Run the App anytime you want.

------------

<div align="center">
<b>Usage</b></div>

1) Add all the MIX files you wish to process inside the work directory:
> (reMIXer Root Folder)\Work\

1.1) You can put the MIX Files inside a subdirectory as long as this subdirectory is inside the work directory. Example:
> (reMIXer Root Folder)\Work\subdirectory\thismixfile.mix

2) Press "Refresh ListView" button.
3) Put a Check Mark at the Mix Files you wish to reMIX.
4) Change the reMIX "Mode" depending on your needs:
    * 1: File Size will not be reduced. The File Names will not be recovered. Only The Header will be recovered. 
    * 2: File Size will not be reduced. The Header will be recovered, and will try to recover some File Names inside the Target MIX File. 
    * 3(Recommended): File Size will be reduced. The Header will be recovered, and will try to recover some File Names inside the Target MIX File. 
4.1) Keep in mind that there is NO guarantee that ALL file names will be recovered. Some file names could still not show properly.
5) Press "reMIX all Target Files" button.
6) Wait for the reMIXing to Finish.
7) All Successfully reMIXed Files can be found inside this folder directory:
> (reMIXer Root Folder)\Done\