alias help="/bin/cat /opt/controls-accelerator/HELP"
alias whatismyip="/sbin/ifconfig eth0 | /bin/grep inet | /usr/bin/head -n1  | /usr/bin/awk '{print $2}'"
