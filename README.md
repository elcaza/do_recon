# Do Recon
A tool to help you in scans of infrastructure. It scans a bundle of sites and puts the results in a directory for each site analyzed.

## What does this do?
By order:
1. Create a log file for all the assets
1. Check interfaces available in the system
1. Create a directory for each active to scan
1. Makes a nslookup search
1. Makes a traceroute
1. Makes a nmap --top-ports scan
1. Makes a nmap -sV scan only with the discovered open ports
1. Makes a nmap scan for all ports
1. Makes a nmap -sC scan only with the discovered open ports
1. Makes a nmap --script vuln  scane with the discovered open ports
1. Make reports: 
    + All open ports
    + All open ports with versions
    + CVEs reported by nmap (beta)

## How to use
~~~bash
./do_recon.sh input_file.txt
~~~

## Example input file
~~~
1.site1.com
2.site2.org.mx
3.anothersite.com
4.example.com
5.example2.com
6.other.es
~~~

## Options for the script to infrastructure
### Setting log file
LOGFILE=$(date '+%d-%m-%Y')".log"
### Setting the new line separator
NEW_LINE="======================================="

### Scan options (true || false)
1. CHECK_INTERFACE=true
1. CREATE_DIRECTORY=true
1. DO_NSLOOKUP=true
1. DO_TRACE=true
1. DO_NMAP_TOP_PORTS=true
1. DO_NMAP_SV=true
1. DO_NMAP_ALL_PORTS=true
1. DO_NMAP_SC=true
1. DO_NMAP_SCRIPT_VULNES=true
1. REPORT_ALL_OPEN_PORTS=true

### Variables for the nmap scan
1. NMAP_DELAY=5
    + Delay in seconds before to run another nmap scan
1. NMAP_TIMEOUT=0
    + Timeout 0 = No timeout. Any else, timeout in seconds
1. TOP_PORTS=1000
1. MAX_RETRIES=1
1. MIN_RATE=500
1. T=-T3
    + -T0, -T1, -T2, -T3, -T4, -T5
    + Default -T3

## Requirements
+ nmap
+ traceroute 
+ nslookup 

To install
~~~bash
sudo apt update && sudo apt install nmap traceroute dnsutils
~~~

## nmap scans used by the script
~~~bash
# $DO_NMAP_TOP_PORTS
timeout $NMAP_TIMEOUT nmap --vv $T -Pn --open --top-ports $TOP_PORTS --max-retries $MAX_RETRIES -oA $FILE"_"$TOP_PORTS $SITE

# $DO_NMAP_SV
timeout $NMAP_TIMEOUT nmap --vv $T -Pn --open -sV --max-retries $MAX_RETRIES -p $PORTS -oA $FILE"_sv" $SITE

# $DO_NMAP_ALL_PORTS
timeout $NMAP_TIMEOUT nmap --vv $T -Pn --open -p- --max-retries $MAX_RETRIES --min-rate $MIN_RATE -oA $FILE"_all_ports" $SITE

# $DO_NMAP_SC
timeout $NMAP_TIMEOUT nmap --vv $T -Pn --open -sV -sC --max-retries $MAX_RETRIES -p $PORTS -oA $FILE"_sc" $SITE

# $DO_NMAP_SCRIPT_VULNES
timeout $NMAP_TIMEOUT nmap --vv $T -Pn --open -sV --script vuln --max-retries $MAX_RETRIES -p $PORTS -oA $FILE"_script_vulnes" $SITE
~~~