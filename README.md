# Fedora 20+ Post-install script
This bash script will install usefull applications, games, and Oracle Java JRE or JDK depending on the version found.
Furthermore, it will stop firewalld, setup iptables and ip6tables, configure the xsane server access and x11vnc for remote help.
You can re-run it to install a new Java version and uninstall at the same time the old version or to reconfigure your firewall rules when they were messed up for some reason.

usage:
  the script requires root privileges!  sudo will not work.
  
  \# sh F2x-post-config-v2.0.18.sh                -> shows all possible option
  \# sh F2x-post-config-v2.0.18.sh -1 -2 --debug  -> shows what will be installed with option -1 and -2
  
