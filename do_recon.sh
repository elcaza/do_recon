#!/bin/bash
## Usage: ./do_recon.sh input_file.txt

#################################################
#################################################
# GLOBAL VARIABLES AND OPTIONS
 
# Establece el nombre del archivo para el log
LOGFILE=$(date '+%d-%m-%Y')".log"
NEW_LINE="======================================="

# Scan options ? true||false
CHECK_INTERFACE=true
CREATE_DIRECTORY=true
DO_NSLOOKUP=true
DO_TRACE=true
DO_NMAP_TOP_PORTS=true
DO_NMAP_SV=true
DO_NMAP_ALL_PORTS=true
DO_NMAP_SC=true
DO_NMAP_SCRIPT_VULNES=true
MAKE_REPORTS=true

# NMAP SCAN VARIABLES
NMAP_DELAY=5
# Timeout 0 = No timeout. Anyelse, timeout in seconds
NMAP_TIMEOUT=0
TOP_PORTS=1000
MAX_RETRIES=1
MIN_RATE=500
# -T0, -T1, -T2, -T3, -T4, -T5
# Default -T3
T=-T3
# END OF GLOBAL VARIABLES AND OPTIONS
#################################################
#################################################

#################################################
# Funciones

log_start_options () {
	echo $NEW_LINE | tee -a $LOGFILE
	echo "Start:" $(date '+%d-%m-%Y %H:%M:%S') | tee -a $LOGFILE
	echo -e "** Scan options:\n" | tee -a $LOGFILE
	echo "LOGFILE:" $LOGFILE | tee -a $LOGFILE
	echo "CHECK_INTERFACE:" $CHECK_INTERFACE | tee -a $LOGFILE
	echo "CREATE_DIRECTORY:" $CREATE_DIRECTORY | tee -a $LOGFILE
	echo "DO_NSLOOKUP:" $DO_NSLOOKUP | tee -a $LOGFILE
	echo "DO_TRACE:" $DO_TRACE | tee -a $LOGFILE
	echo "DO_NMAP_TOP_PORTS:" $DO_NMAP_TOP_PORTS | tee -a $LOGFILE
	echo "DO_NMAP_SV:" $DO_NMAP_SV | tee -a $LOGFILE
	echo "DO_NMAP_ALL_PORTS:" $DO_NMAP_ALL_PORTS | tee -a $LOGFILE
	echo "DO_NMAP_SC:" $DO_NMAP_SC | tee -a $LOGFILE
	echo "DO_NMAP_SCRIPT_VULNES:" $DO_NMAP_SCRIPT_VULNES | tee -a $LOGFILE
	echo "MAKE_REPORTS:" $MAKE_REPORTS | tee -a $LOGFILE
	
	echo -e "\nNmap scan variables:" | tee -a $LOGFILE
	echo "NMAP_DELAY:" $NMAP_DELAY | tee -a $LOGFILE
	echo "NMAP_TIMEOUT:" $NMAP_TIMEOUT | tee -a $LOGFILE
	echo "TOP_PORTS:" $TOP_PORTS | tee -a $LOGFILE
	echo "MAX_RETRIES:" $MAX_RETRIES | tee -a $LOGFILE
	echo "MIN_RATE:" $MIN_RATE | tee -a $LOGFILE
	echo "-T:" $T | tee -a $LOGFILE
}

log_start () {
	echo $NEW_LINE | tee -a $LOGFILE
	echo "Start:" $(date '+%d-%m-%Y %H:%M:%S') | tee -a $LOGFILE
	echo "Sitio: " $SITE | tee -a $LOGFILE
	echo "Carpeta: " $FILE | tee -a $LOGFILE
}
 
log_end () {
	echo "End:" $(date '+%d-%m-%Y %H:%M:%S') | tee -a $LOGFILE
}
 
log_activity() {
	echo $1 | tee -a "../$LOGFILE"
}

do_start () {
	SITE=$(echo $line | cut -d "." -f2- | tr -d '\r')
	FILE=$(echo $line | tr -d '\r')

	log_start

	cd $FILE
}

do_exit () {
	cd ..
	log_end
}

do_delay () {
	sleep $NMAP_DELAY
	echo "Delay: " $NMAP_DELAY | tee -a "../$LOGFILE"
}

get_filtered_ports () {
	PORTS=$(cat *.nmap | egrep "open" | cut -d "/" -f1 | sort -u | grep -v '|' | grep -v '#' | tr "\n" "," | sed 's/\(.*\),/\1 /')
	echo $PORTS > open_top_ports.txt
}

log_time_out () {
	if [ $? -ne 0 ]; then
		echo "Scan stopped by timeout: $NMAP_TIMEOUT seconds" | tee -a "../$LOGFILE"
	fi
}

#################################################
# Starting program

if [ $# -ne 1 ]
then
	echo "Use: $0 input_file"
	echo -e "\nInput file example: Read the README.md file"
	exit
else
	if [ "$1" == "stop" ]; then
		echo "Stopping"
		ps -ef | grep 'do_recon'
		ps -ef | grep 'do_recon' | grep -v grep | awk '{print $2}' | xargs -r kill -9
		exit
	fi

	if [ "$1" == "reset" ]; then
		echo "Deleting all folders and log files..."
		rm -R */ *.log
		exit
	fi 

	if [ ! -f "$1" ]; then
		echo "File does not exist"
		exit
	fi 
fi

log_start_options

if $CHECK_INTERFACE
then
	echo -e "\nInterfaces:" | tee -a $LOGFILE
	ip a | tee -a $LOGFILE
fi
 
if $CREATE_DIRECTORY
then
	while IFS= read -r line || [ -n "$line" ]
	do
		SITE=$(echo $line | cut -d "." -f2- | tr -d '\r')
		FILE=$(echo $line | tr -d '\r')
 
		log_start
		mkdir $FILE
		cd $FILE
		log_activity "OK - mkdir $SITE"

		do_exit
	done < $1
fi

if $DO_NSLOOKUP
then
	while IFS= read -r line || [ -n "$line" ]
	do
		do_start

		nslookup $SITE | tee -a $FILE"_nslookup.txt"
		log_activity "OK - nslookup $SITE"
	   
	   	do_exit
	done < $1
fi

if $DO_TRACE
then
	while IFS= read -r line || [ -n "$line" ]
	do
		do_start

		traceroute $SITE | tee -a $FILE"_traceroute.txt"
		log_activity "OK - traceroute $SITE"
	   
	   	do_exit
	done < $1
fi

if $DO_NMAP_TOP_PORTS
then
	while IFS= read -r line || [ -n "$line" ]
	do
		do_start

		timeout $NMAP_TIMEOUT nmap --vv $T -Pn --open --top-ports $TOP_PORTS --max-retries $MAX_RETRIES -oA $FILE"_"$TOP_PORTS $SITE
		log_time_out
		log_activity "OK - nmap --top-ports $TOP_PORTS $SITE"   
		do_delay
		
		do_exit
	done < $1
fi

if $DO_NMAP_SV
then
	while IFS= read -r line || [ -n "$line" ]
	do
		do_start
		
		get_filtered_ports
		timeout $NMAP_TIMEOUT nmap --vv $T -Pn --open -sV --max-retries $MAX_RETRIES -p $PORTS -oA $FILE"_sv" $SITE
		log_time_out
		log_activity "OK - nmap -sV $SITE" 
		do_delay

		do_exit
	done < $1
fi
 
if $DO_NMAP_ALL_PORTS
then
	while IFS= read -r line || [ -n "$line" ]
	do
		do_start

		timeout $NMAP_TIMEOUT nmap --vv $T -Pn --open -p- --max-retries $MAX_RETRIES --min-rate $MIN_RATE -oA $FILE"_all_ports" $SITE
		log_time_out
		log_activity "OK - nmap all ports $SITE"
		do_delay

		do_exit
	done < $1
fi
 
if $DO_NMAP_SC
then
	while IFS= read -r line || [ -n "$line" ]
	do
		do_start

		get_filtered_ports
		timeout $NMAP_TIMEOUT nmap --vv $T -Pn --open -sV -sC --max-retries $MAX_RETRIES -p $PORTS -oA $FILE"_sc" $SITE
		log_time_out
		log_activity "OK - nmap -sC $SITE"

		do_exit
	done < $1
fi
 
if $DO_NMAP_SCRIPT_VULNES
then
	while IFS= read -r line || [ -n "$line" ]
	do
		do_start

		get_filtered_ports
		timeout $NMAP_TIMEOUT nmap --vv $T -Pn --open -sV --script vuln --max-retries $MAX_RETRIES -p $PORTS -oA $FILE"_script_vulnes" $SITE
		log_time_out
		log_activity "OK - nmap --script vuln $SITE"
	    
		do_exit

	done < $1
fi

if $MAKE_REPORTS
then
	mkdir report
	while IFS= read -r line || [ -n "$line" ]
	do
		do_start
	   
		cat *.nmap | egrep "open" | cut -d "/" -f1 | sort -u | grep -v '|' | grep -v '#' >> "../report/all_open_ports.tmp"
		log_activity "OK - Get all open ports: $SITE"

		cat *.nmap | egrep "open" | tr -s ' ' | sort -u | grep -v '#' | grep -v "|" >> "../report/all_open_ports_version.tmp"
		log_activity "OK - Get all open ports version: $SITE"

		cat *.nmap | egrep "IDs:" | tr -s ' '  >> "../report/all_cve_beta.tmp"
		log_activity "OK - Get all CVE IDs (beta): $SITE"
	
		do_exit
	done < $1
	cat "./report/all_open_ports.tmp" | sort -u > "./report/all_open_ports.txt"
	rm ./report/all_open_ports.tmp
	
	cat "./report/all_open_ports_version.tmp" | sort -u > "./report/all_open_ports_version.txt"
	rm ./report/all_open_ports_version.tmp

	cat "./report/all_cve_beta.tmp" | sort -u > "./report/all_cve_beta.txt"
	rm ./report/all_cve_beta.tmp
fi
