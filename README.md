# Emperor Linux IR Triage Collection 
Emperor is a bash script that collects extensive data from almost all Linux distributions to help DFIR professionals triage cyber incidents.

- [What does it Collect](#what-does-it-collect)
- [Requirements](#requirements)
- [Usage](#usage)
- [Advice](#advice)
- [Other Triage Tools](#other-triage-tools)
- [Author](#author)

## What does it collect?
In Summary, This script will try to collect all of the below items with most relevant context from IR perspective

- All Running Processes
- Listing of all File Descriptors for all process
- Listing of /proc/PID/exe symbolic link for all process
- Listing of all process start commands (i.e. /proc/<PID>cmdline)
- All Active Network Connections
- All Network Information 
- Bash History for all users
- SSH Known hosts for all users 
- SSH config for all users
- Copy of /etc/ssh folder
- Copy of /var/log folder
- Crontabs for all users
- Crontab access and deny
- Crontab directory listing
- passwd.txt file
- shadow.txt file
- group.txt file
- File System Timeline in csv (Except Mount Points) (Inode,Full Path,Last Access,Last Modification,Last Status Change,User,Group,File Permissions,File Size(bytes),Symbolic Link)
- Debugfs stats for all files (Except Mount Points)
- Debugfs Deleted inodes
- All Users currently logged in
- History of all logins and logouts
- All failed logons
- System Information (OS, Kernel, locale, Machine, Processor etc)
- Kernel Modules
- Installed Packages

I recommend skimming through the code to get a full understanding never the less. :)

## Requirements
For most part none. It uses default packages available in most linux distributions. However there are few checks placed and if it's not possible to run the command it might skip it or take a copy of the raw files. 

## Usage
This script was built to automate as much as possible. I recommend running it from an external device/usb to avoid overwriting evidence. Just in case you need a full image in future. However output is usually 100-200 MBs so up to you really. 

```
user@host:<dir>$ chmod +x Emperor.sh
user@host:<dir>$ sudo ./Emperor.sh
```

Once it's finished running. Emperor will dump 2 files into the same directory it resides. 

1. Hostname-date-time.tar.gz
2. consolelog-date-time.txt (Think of this as a debug/console log)

If you are going to get this transfered across network. **I highly recommend encrypting it!**

## Advice
get_debugfstimeline function by far takes longest to run and output is not easily timelineable. However as far as i know, this is the only way to get creation times for files which can be a key artifact. I am hoping to develop a parser for this in the future to create a timeline out of this.

You can comment this function out if you like to speed up the process. To give you an idea, the whole script takes ~36 mins on an Ubuntu 16 VM with full package. With get_debugfstimeline commented out. This can be lowered down to 5-10 mins.  

## Other Triage Tools
I have tried to use what is already out there to build this script. Some had great logging. Some had great functionality. Over the years, functionality was added by coding or using code snippets from these. I would like to mention a particular one to pay respect to them and thank them for their contributions. 

- [Recruit-CSIRT/LinuxTriage](https://github.com/Recruit-CSIRT/LinuxTriage) written by [Tatsuya Ichida](https://github.com/icchida)

This was the most well written and complete Linux script out there for years and have given me great inspiration to create Emperor. 

## Author
Mert Surmeli
**@56616C6F72**
