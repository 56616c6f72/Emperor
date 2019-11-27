#!/bin/bash
# Usage: sudo bash emperor.sh
# Author: @56616C6F72
# Comment: Collects Key Triage data for Linux

# ------------------------------------------------------------
# -- Initial Checks
# ------------------------------------------------------------

# Check if root
[[ $UID == 0 || $EUID == 0 ]] || (
  echo -e "\nMust be root! Please execute after 'su -' OR with 'sudo' . "
  exit 1
) || exit 1

# ------------------------------------------------------------
# -- Setup parameters
# ------------------------------------------------------------

SAVETO="$(pwd)/$(hostname)-$(date +%Y.%m.%d-%H.%M.%S)"			###### SAVE DIRECTORY: Where Output files will be saved.
IRCASE="$(hostname)-$(date +%Y.%m.%d-%H.%M.%S)"							###### Basename of results files
CONSOLELOG=$(pwd)/consolelog-$(date +%Y.%m.%d-%H.%M.%S).txt
Starttime=$(date '+%Y-%m-%d %H:%M:%S %Z %:z')

# ------------------------------------------------------------
# -- Functions
# ------------------------------------------------------------

get_process(){
    #Get Running Processes
    {
        PS_FORMAT=user,pid,ppid,vsz,rss,tname,stat,stime,time,args
        if ps axwwSo $PS_FORMAT &> /dev/null
        then
            # bsd
            ps axwwSo $PS_FORMAT
        elif ps -eF &> /dev/null
        then
            # gnu
            ps -eF
        else
            # bsd without ppid
            ps axuSww
        fi
    } > "$SAVETO/processes.txt"
}

get_networkdata(){
    #All Active Network Connections
    {
        if netstat -pvWanoee &> /dev/null
        then
            # gnu
            netstat -pvWanoee
        elif netstat -pvTanoee &> /dev/null
	then
            # redhat/centos
            netstat -pvTanoee
	else
	    netstat -anp
        fi
    } > "$SAVETO/netstat.txt"

    #Network Configuration
    {
        echo  -e "\n</etc/network/interfaces>";cat /etc/network/interfaces
        echo  -e "\n<ifconfig -a>";ifconfig -a
		echo  -e "\n</etc/resolv.conf>";cat /etc/resolv.conf
        echo  -e "\n<ip addr>"; ip addr
        echo  -e "\n<ip link>";ip link
        echo  -e "\n<netstat -anp>;"netstat -anp
		if lsof -i -n -P &> /dev/null
		then
			echo  -e "\n<lsof -i -n -P>";lsof -i -n -P
		fi
        echo  -e "\n<ss -ap>";ss -ap
        echo  -e "\n<route -n>";route -n # "netstat -nr"; "ip route"
        echo  -e "\n<ip neigh>";ip neigh
		echo  -e "\n</etc/hostname>";cat /etc/hostname
        echo  -e "\n<cat /etc/hosts>";cat /etc/hosts
        echo  -e "\n<cat /etc/hosts.allow>";cat /etc/hosts.allow
        echo  -e "\n<cat /etc/hosts.deny>";cat /etc/hosts.deny
    } > "$SAVETO/netinfo.txt"
	
	#SSH Folder Copy
	tar -zcvf "$SAVETO/ssh_folder.tar.gz" /etc/ssh/* 2> /dev/null
}

get_userinfo(){
    #Active logons
    if who -a &> /dev/null
    then
        who -a > "$SAVETO/activelogons-utmp.txt"
    else
        cat /var/run/utmp > "$SAVETO/utmpdump.bin"
    fi

    #All logon History
    if last -Fwx -f /var/log/wtmp* &> /dev/null
    then
        last -Fwx -f /var/log/wtmp* > "$SAVETO/alllogins-last.txt"
    else
        cp -RH /var/log/wtmp* "$SAVETO/"
    fi

	#Failed logons
    if last -Fwx -f /var/log/btmp* &> /dev/null
    then
        last -Fwx -f /var/log/btmp* > "$SAVETO/failedlogons-btmp.txt"
    else
        cp -RH /var/log/btmp* "$SAVETO/"
    fi
}

get_filetimeline(){
	
	#Open Files and Link Counts, Open files with network connection 
	if lsof &> /dev/null
	then
		lsof +L -e /run/user/1000/gvfs > "$SAVETO/lsof-openfiles-linkcounts.txt"

		lsof -i -e /run/user/1000/gvfs > "$SAVETO/lsof-openfilesnetfiles.txt"
	fi
	
	# Creates a Timeline of the file system
    {
		echo -e "\nInode,Full Path,Last Access,Last Modification,Last Status Change,User,Group,File Permissions,File Size(bytes),Symbolic Link"
        find / -xdev -type f -printf "%i,%P,%A+,%T+,%C+,%u,%g,%M,%s,%l\n" 2>/dev/null
    } > "$SAVETO/FileSystemTimeline.txt"
}

# This is slightly more in deep then get_filetimeline. As this will also get the creation time. However this function takes waaaaaaaaaay longer than others might want to consider commenting out. If you do not wish to get this info. Don't comment it out here though :) comment it out in the main
get_debugfstimeline(){

#Get root drive
myrootdrive=$(df | awk '{print $1}' | grep /)

#Get debugfs stat for all inodes
while IFS= read -r line
do

	debugfs -R "stat <$line>" "$myrootdrive" | cat >> "$SAVETO/full_inode_extract_output.txt" 
   
done < <(find / -xdev -type f -ls 2>/dev/null | awk '{print $1}') 
	
}

#Get list of deleted inodes.
get_deleted_files(){

myrootdrive=$(df | awk '{print $1}' | grep /)

debugfs -R "lsdel" "$myrootdrive" | cat > "$SAVETO/deleted_files.txt"

}

#Get Process File descriptors and exe links 
get_process_Exeandfds(){

ls  -l /proc/*/fd/* 2>/dev/null > "$SAVETO/process_fds.txt"
ls  -l /proc/*/exe 2>/dev/null > "$SAVETO/process_exeLinks.txt"

}

get_process_cmdline(){

while read line 
do

	echo "$line":$(cat "$line" 2> /dev/null) >> "$SAVETO/proc_cmdline.txt"

done < <(find /proc/ -name cmdline 2> /dev/null)

}

#Get list of all services and cron information
get_servicereg(){

    # List all services and runlevel on ubuntu16 ~
    if sysv-rc-conf -list &> /dev/null; then
        sysv-rc-conf -list　>> "$SAVETO/chkconfig.txt"
    elif insserv -s　>> "$SAVETO/chkconfig.txt" &> /dev/null; then
        insserv -s　>> "$SAVETO/chkconfig.txt"
    fi
    # List all services and runlevel on cent7 ~
    systemctl list-unit-files >> "$SAVETO/chkconfig.txt"

    # Users with crontab access
    if cp -RH /etc/cron.allow "$SAVETO/cronallow.txt" &> /dev/null; then
	cp -RH /etc/cron.allow "$SAVETO/cronallow.txt"
    fi

    # Users with crontab access
    if cp -RH /etc/cron.deny "$SAVETO/crondeny.txt" &> /dev/null; then
	cp -RH /etc/cron.deny "$SAVETO/crondeny.txt"
    fi

    # Crontab listing
    if cp -RH /etc/crontab "$SAVETO/crontab.txt" &> /dev/null; then
	cp -RH /etc/crontab "$SAVETO/crontab.txt"
    fi

    # Cronfile listing
    ls -al /etc/cron.* > "$SAVETO/cronfiles.txt"
}

# Get Shell history, Crontabs and .ssh info for all users
get_userprofile(){

    mkdir "$SAVETO/Dir_userprofiles"
    while read line
    do
        user=`echo "$line" | cut -f1 -d:`
        home=`echo "$line" | cut -f6 -d:`
        mkdir "$SAVETO/Dir_userprofiles/$user"
        #Get user shell history
		for f in $home/.*_history; do
			count=0
			while read line
			do
				echo $f $count $line >> "$SAVETO/Dir_userprofiles/$user/shellhistory.txt"
				count=$(( $count + 1 ))
			done < $f
		done


		#Get user contabs
		crontab -u $user -l > "$SAVETO/Dir_userprofiles/$user/crontab.txt"

		if [ -d "$home/.ssh/known_hosts" ]; then
			#Get ssh known hosts
			cp -RH $home/.ssh/known_hosts "$SAVETO/Dir_userprofiles/$user/ssh_known_hosts.txt"
		fi

		if [ -d "$home/.ssh/config" ]; then
			#Get ssh config
			cp -RH $home/.ssh/config "$SAVETO/Dir_userprofiles/$user/ssh_config.txt"
		fi

    done < /etc/passwd

    #Copy passwd.txt file
    cp -RH /etc/passwd "$SAVETO/passwd.txt"

    #Copy group.txt file
    cp -RH /etc/group "$SAVETO/group.txt"

    #Copy shadow file
	cp -RH /etc/group "$SAVETO/shadow.txt"
}

get_systeminfo(){
    #Get OS version information
    {
        echo -n "kernel_name="; uname -s;
        echo -n "nodename="; uname -n;
        echo -n "kernel_release="; uname -r;
        echo -n "kernel_version="; uname -v;
        echo -n "machine="; uname -m;
        echo -n "processor="; uname -p;
        echo -n "hardware_platform="; uname -i;
        echo -n "os="; uname -o;

    } > "$SAVETO/version.txt"

    #Get kernel modules
    TMP="$SAVETO/TMP"
    lsmod | sed 1d > "$TMP"
    while read module size usedby
    do
        {
            echo -e $module'\t'$size'\t'$usedby;
            modprobe --show-depends $module;
            modinfo $module;
            echo "";
        } >> "$SAVETO/modules.txt"
    done < "$TMP"
    rm "$TMP"

    #Get list of PCI devices
	if lspci &> /dev/null
	then
		lspci > "$SAVETO/lspci.txt"
	fi
	
    #Get locale information
    locale > "$SAVETO/locale.txt"

    #Get installed packages with version information - ubuntu
    if dpkg-query -W &> /dev/null
    then
        dpkg-query -W -f='${PackageSpec}\t${Version}\n' > "$SAVETO/packages.txt"
    fi
    #Get installed packages with version information - redhat/centos
    if /bin/rpm -qa --queryformat "%{NAME}\t%{VERSION}\n" &> /dev/null
    then
        /bin/rpm -qa --queryformat '%{NAME}\t%{VERSION}\n' >> "$SAVETO/packages.txt"
    fi

    #Get kernel ring buffer messages
    {
        if dmesg -T &> /dev/null
        then
            dmesg -T
        else
            dmesg
        fi
    } > "$SAVETO/dmesg.txt"

    #Get mounted devices
    mount > "$SAVETO/mounted_devices.txt"

}

#Get a full copy of /var/log folder
get_logs() {

	tar -zcvf "$SAVETO/var_log.tar.gz" /var/log/* 2> /dev/null

}

# ------------------------------------------------------------
# -- Main
# ------------------------------------------------------------

	echo -e "Emperor Linux Live Response. Written by @56616C6F72"
	echo -e "Starting data collection..."
	echo -e "Start time: $Starttime"

{
	echo -e "Collecting triage data..."
    echo -e "\nStart time: $Starttime"
	#Create Output Directory 
	mkdir -p "$SAVETO"	2>&1					

} >> "$CONSOLELOG"

	echo -e '\n(o_   (I am at work! Wont be long now!)'
	echo -e '//\'
	echo -e 'V_/_'
	echo -e "Collecting triage data..."

{
    	get_process 2>&1
	get_process_cmdline 2>&1
	get_process_Exeandfds 2>&1
	get_networkdata 2>&1
	get_filetimeline 2>&1
	get_logs 2>&1
   	get_userprofile 2>&1
	get_userinfo 2>&1
   	get_systeminfo 2>&1
   	get_servicereg 2>&1
	get_deleted_files 2>&1
	
	#Comment get_debugfstimeline if you wish do lower the runtime of the script
	get_debugfstimeline 2>&1
    	

    # end timestamp
    ENDtime=$(date '+%Y-%m-%d %H:%M:%S %Z %:z')
} >> "$CONSOLELOG"


echo -e "\nCompressing to tar.gz  ..."
CUR_DIR=$( cd "$( dirname ""${BASH_SOURCE[0]}"" )" && pwd )
cd "$SAVETO"
tar -zcvf "$SAVETO/$IRCASE"".tar.gz" * > /dev/null
cd "$CUR_DIR"
mv "$SAVETO/$IRCASE"".tar.gz" "$CUR_DIR"
rm -rf "$SAVETO"

# end timestamp

echo -e "\nEnd time: $ENDtime"
echo -e 'Triage Files Created'
echo -e '\n1)' consolelog-$(date +%Y.%m.%d-%H.%M.%S).txt
echo -e '2)' "$IRCASE"".tar.gz\n"
echo -e '\n(o_   (Thanks! Emperor OUT!)'
echo -e '//\'
echo -e 'V_/_'
echo -e ''
