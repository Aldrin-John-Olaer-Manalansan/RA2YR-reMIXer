# RA2YR reMIXer
## v3.0.0.0
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

1. Download the [Latest Released Build](https://github.com/Aldrin-John-Olaer-Manalansan/RA2YR-reMIXer/releases/download/Latest-Build/RA2YR_reMIXer.zip).
2. Extract the content of this *ZIP* File anywhere you want.
3. Run **Launcher.exe** to start reMIXing.