<div align="center">
  <img width=500px src="https://raw.githubusercontent.com/elcaza/misc/refs/heads/main/images/do_recon/do_recon.jpeg">
  <br>
  <h1>Do Recon</h1>
  <br>
</div>

A tool to help you in scans of infrastructure. It scans a bundle of sites and puts the results in a directory for each site analyzed.

Let us do the important but tedious job of mapping the network and doing the reconnaissance. After that, just read the outputs and try to hack them!

## What does this do?
By order:
1. Create a log file for all the assets 
    + In case of any error or interruptions you can trace the bug to fix it
1. Check interfaces available in the system 
    + Keeps the visibility about the network interfaces used during the process.
1. Create a directory for each active scanned 
    + All the evidence will be organized in its own directory.
1. Makes a nslookup search 
    + Map the domain name and IP addresses
1. Makes a traceroute 
    + An easy way to traces the path of packets across a network and a simple way to identify if the asset isn’t reached correctly
1. Makes a nmap --top-ports scan 
    + A faster scan that provides you information to start to work in the manual scan.
1. Makes a nmap -sV scan, just for the discovered open ports 
    + A faster scan that provides you information to start to work in the manual scan.
1. Makes a nmap scan for all ports 
    + A complete scan of the asset.
1. Makes a nmap -sC scan just for the discovered open ports 
    + A deep scan of the asset.
1. Makes a nmap --script vuln  scan with the discovered open ports 
    + A deep scan of the asset to find vulnerabilities.
1. Make reports: 
    + All open ports
    + All open ports with versions
    + CVEs reported by nmap (beta)

## Requirements
+ nmap
+ traceroute 
+ nslookup 

Install requirements
~~~bash
sudo apt update && sudo apt install nmap traceroute dnsutils
~~~

## Input - How to use

### Download and run
~~~bash
git clone https://github.com/elcaza/do_recon.git
cd do_recon
./do_recon.sh input_file.txt
~~~

### Download, install and run
~~~bash
git clone https://github.com/elcaza/do_recon.git
cd do_recon
sudo cp do_recon.sh /usr/local/bin/
do_recon.sh input_file.txt
~~~

### Uninstall
~~~bash
sudo rm /usr/local/bin/do_recon.sh
~~~

### To stop the script
~~~bash
./do_recon.sh stop
~~~

### To remove all files created by the tool
\* Delete all folders and log files in the current path, be careful!
~~~bash
./do_recon.sh reset
~~~

## Output
~~~bash
├── 10-03-2025.log
├── 1.scanme.nmap.org
│   ├── 1.scanme.nmap.org_1000.gnmap
│   ├── 1.scanme.nmap.org_1000.nmap
│   ├── 1.scanme.nmap.org_1000.xml
│   ├── 1.scanme.nmap.org_all_ports.gnmap
│   ├── 1.scanme.nmap.org_all_ports.nmap
│   ├── 1.scanme.nmap.org_all_ports.xml
│   ├── 1.scanme.nmap.org_nslookup.txt
│   ├── 1.scanme.nmap.org_sc.gnmap
│   ├── 1.scanme.nmap.org_sc.nmap
│   ├── 1.scanme.nmap.org_script_vulnes.gnmap
│   ├── 1.scanme.nmap.org_script_vulnes.nmap
│   ├── 1.scanme.nmap.org_script_vulnes.xml
│   ├── 1.scanme.nmap.org_sc.xml
│   ├── 1.scanme.nmap.org_sv.gnmap
│   ├── 1.scanme.nmap.org_sv.nmap
│   ├── 1.scanme.nmap.org_sv.xml
│   ├── 1.scanme.nmap.org_traceroute.txt
│   └── open_top_ports.txt
├── 2.demo.testfire.net
│   ├── 2.demo.testfire.net_1000.gnmap
│   ├── 2.demo.testfire.net_1000.nmap
│   ├── 2.demo.testfire.net_1000.xml
│   ├── 2.demo.testfire.net_all_ports.gnmap
│   ├── 2.demo.testfire.net_all_ports.nmap
│   ├── 2.demo.testfire.net_all_ports.xml
│   ├── 2.demo.testfire.net_nslookup.txt
│   ├── 2.demo.testfire.net_sc.gnmap
│   ├── 2.demo.testfire.net_sc.nmap
│   ├── 2.demo.testfire.net_script_vulnes.gnmap
│   ├── 2.demo.testfire.net_script_vulnes.nmap
│   ├── 2.demo.testfire.net_script_vulnes.xml
│   ├── 2.demo.testfire.net_sc.xml
│   ├── 2.demo.testfire.net_sv.gnmap
│   ├── 2.demo.testfire.net_sv.nmap
│   ├── 2.demo.testfire.net_sv.xml
│   ├── 2.demo.testfire.net_traceroute.txt
│   └── open_top_ports.txt
├── report
│   ├── all_cve_beta.txt
│   ├── all_open_ports.txt
│   └── all_open_ports_version.txt
~~~

## Example of input file
It's required setting a number ID and “dot (.)” before the URL site
~~~
1.site1.com
2.site2.org.com
3.anothersite.com
4.example.com
5.example2.com
6.other.es
~~~

Do not use in input file:
~~~bash
/
/path
http://
https://
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