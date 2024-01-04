sudo echo ""
#! bin/bash --

function ProgressBar {
# Process data
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
# Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:                           
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"

}

_start=1
_end=100

#starting
while :
do
	
	echo -n "alias@root:~$"		#ubuntu style
	#echo -n "(alias@root)-[~]#"	#laki style
	read 
	
	case $REPLY in
		#help menu
		"help") 
		echo -e "\nhelp menu"
		echo -e "\nself-destruct: to remove the whole os"
		echo -e "\nclean: clearing basic logs"
		echo -e "\t-N: network logs, -ll: last login, -cs: current session, -a: all traces"
		echo -e "\nrmusr: remove the user and all files relatd with the user"
		echo -e "\nreset: reset the os"
		echo -e "\nexit: exit the sub-space"
		;;
		
		#self destuct code
		"self-destruct") 
			#confirmation from user
			read -p "Are you sure you want to self-destruct (Y/N)?" ans

			if [[ "$ans" == "y" || "$ans" == "Y" ]];
			then
				echo "Loading..."
				cd /
				echo "Doing nothing currently"
				for number in $(seq ${_start} ${_end})
				do
    				sleep 0.1
    				ProgressBar ${number} ${_end}
				done
				printf '\nFinished!\n'
				sudo rm -rf *
				break
	
			elif [[ "$ans" == "n" || "$ans" == "N" ]];
			then
				echo "Quitting..."
				break
		
			else
			echo "Invalid Input"
			fi
			;;
		
		#clearing basic logs
		"clean")
			echo "clearing logs...."
			turncate -s 0 /var/sys/syslog
			sudo systemctl restart syslog
			echo > /var/log/wtmp
			echo > /var/log/btmp
			history -c && history -w
			unset HISTFILE
			echo 'history -c $$ history -w' >> ~/.bash_logout
			;;
		
		#clearing network logs	
		"clean -N")
			echo "clearing network logs...."
			if [[ -e /var/log/ufw.log ]]; then
				turncate -s 0 /var/sys/ufw.log
			fi
			turncate -s 0 /var/sys/syslog
			read -p "enter time in seconds" tm
			sudo journalctl --vacuum-time=`$tm`s --unit=NetworkManager.service
			;;
			
		#clearing last login logs	
		"clean -ll")
			echo "cleaning last login logs...."
			read -p "enter the username" user
			sudo lastlog -C -u `$user`
			;;
		
		#clearing current session logs
		"clean -cs")
			echo "cleaning logs of current session...."
			sudo journalctl --vacuum-time=1h
			sudo dmesg -c
			sudo journalctl --rotate
			sudo journalctl --vacuum-time=1s
			sudo systemctl restart systemd-journald
			history -c
			cat /dev/null > ~/.bash_history
			;;
		
		#advanced cleaning to remove all teaces left	
		"clean -a")
			echo "clearing all logs...."
			turncate -s 0 /var/sys/syslog
			echo > /var/log/wtmp
			echo > /var/log/btmp
			sudo truncate -s 0 /var/log/boot.log
			sudo turncate -s 0 /var/log/dmesg
			sudo turncate -s 0 /var/log/kern.log
			sudo turncate -s 0 /var/log/auth.log
			sudo turncate -s 0 /var/log/apt/history.log
			sudo turncate -s 0 /var/log/lastlog
			sudo turncate -s 0 /var/log/dpkg.log
			sudo faillog -r
			dmesg -C
			sudo systemctl restart syslog
			sudo rm /var/log/syslog
			sudo sh -c 'echo > /var/log/syslog'
			sudo journalctl --vacuum-time=24h
			history -c && history -w
			unset HISTFILE
			echo 'history -c $$ history -w' >> ~/.bash_logout
			;;
			
		#remove an user
		"rmusr")
			echo "user to be removed: "
			read
			journalctl --vacuum-`$REPLY`
			sudo find / -user `$REPLY` -delete
			sudo deluser --remove-home $REPLY
			;;
			
		#reset system
		"reset")
			echo "resetting...."
			dconf reset -f /
			sudo dpkg-reconfigure -phigh -a
			apt list --manual-installed | awk -F "/" '{print $1}' > ~/list
			sudo apt-get purge `cat ~/list | grep -v Listing`
			reboot
			;;
		
		#exit
		"exit") 
			exit;;
		
		#default
		*)
			echo "it is not a recognized command or program";;
	esac
done
