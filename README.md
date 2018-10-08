# Fedora 20+ Post-install script

This bash script will setup 3rd-party repositories, install usefull applications, games, and Oracle Java JRE or JDK depending on the version found in the same directory as the script.
Furthermore, it will setup iptables and ip6tables, stop firewalld, configure the xsane server access and x11vnc for remote help.

You can re-run this script to install a new Java version and uninstall at the same time the old version or to configure your firewall rules again when they were messed up for some reason.

usage:
  ```bash
  # sh F2x-post-config-v2.0.18.sh
  # sh F2x-post-config-v2.0.18.sh -1 -2 --debug
  ```
  
  
