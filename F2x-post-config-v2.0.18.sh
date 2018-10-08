#!/bin/bash
# make sure this script and needed RPMs (jre or jdk, skype) are in the same directory
# then, run this script as root

# as of Firefox 52 (March 2017), the NPAPI-plug-in is no longer available causing Java applications in the browser to stop running
#dnf -y upgrade -x mediawriter -x liveusb-creator -x firefox
#dnf install kernel-devel kernel-headers dkms gcc	-> for VirtualBox

VERSION="2.0.18"
V_DATE="August 24th 2018"
V_CREATE="(c) Thierry Debaene"		# mail: thierry.debaene@gmail.com

# fc25 is the last fedora distro supporting the i386 architecture
fcREL=25		# last archived Fedora version, if archived then only http://dl.fedoraproject.org/pub/fedora/linux/releases/24/README files exists

print_usage() {
	$BIN/echo
	$BIN/echo "Usage: sh $0 [ [-1|-2|-B] [-a] [-b] [-e|-ej|-ec|-ep] [-eid] [-f|-fb|-fr] [-g] [-hp] [-j] [-k] [-l] [-m] [-p] [-q] [-r] [-s] [-sp] [-st] [-t] [-w] [-x] ] | [-h|-V] [--debug]"
	$BIN/echo
	$BIN/echo "	-h       : this help, all other options will be ignored"
	$BIN/echo "	-V       : print version information"
	$BIN/echo "	-1       : install repositories and setup ip(6)tables only"
	$BIN/echo "	-2       : install additional applications only"
	$BIN/echo "	-B       : install both i.e. -1 and -2"
	$BIN/echo "	-a       : also install amule, with option -2 or -B"
	$BIN/echo "	-b       : also (re)install broadcom WiFi chipset Firmware (reboot required)"
	$BIN/echo "	-dutch   : configure the logged in user's GUI to Dutch"
	$BIN/echo "	-english : configure the logged in user's GUI to US English"
	$BIN/echo "	-french  : configure the logged in user's GUI to French"
	$BIN/echo "	-german  : configure the logged in user's GUI to German"
	$BIN/echo "	-e       : also install eclipse with Java, C/C++ and PHP Development Tools (requires Java JDK)"
	$BIN/echo "	-ej      : also install eclipse with Java Development Tools only"
	$BIN/echo "	-ec      : also install eclipse with C/C++ Development Tools only"
	$BIN/echo "	-ep      : also install eclipse with PHP Development Tools only"
	$BIN/echo "	-el      : also install eclipse dutch, french and german language plugin only"
	$BIN/echo "	-eid     : also install Belgian eID middleware and GUI"
	$BIN/echo "	-f       : configure basic ip(6)tables (included in option -1)"
	$BIN/echo "	-fb      : also configure ip(6)tables for bridging"
	$BIN/echo "	-fr      : also configure ip(6)tables for radvd, DNS- and DHCP(6)-server"
	$BIN/echo "	-g       : also install some nice games, with option -2 or -B"
	$BIN/echo "	-hp      : install HP printer and scanner drivers"
	$BIN/echo "	-j       : (re)install or upgrade Oracle Java"
	$BIN/echo "	-k       : also install kdenlive, dvdstyler and recordmydesktop, with option -2 or -B"
	$BIN/echo "	-l       : also install glabels and kcover, with option -2 or -B"
	$BIN/echo "	-lang    : also install `[ $fcVER -lt 15 ] && $BIN/echo Open || $BIN/echo Libre`Office language pack Dutch, French and German"
	$BIN/echo "	-m       : also install Microsoft True Type fonts"
	$BIN/echo "	-mri     : also install aeskulap (MRI-viewer), with option -2 or -B"
#	$BIN/echo "	-o       : also install OpenStack (cloud) repository"
	$BIN/echo "	-p       : also configure paranoid ip(6)tables OUTPUT chain, with option -1, -B or -f"
	$BIN/echo "	-q       : also install QEMU, libvirt, virt-manager and UEFI-firmware (requires HW virtualisation)"
	$BIN/echo "	-r       : also install x11vnc and create Desktop/remote-help.sh file"
	$BIN/echo "	-s       : also install skype (64-bit only), with option -2 or -B"
	$BIN/echo "	-sp      : also install spotify streaming service, with option -2 or -B"
	$BIN/echo "	-st      : also install steam engine (on-line Gaming), with option -2 or -B"
	$BIN/echo "	-t       : also install git and git-gui"
	$BIN/echo "	-w       : also install wireshark-gnome"
	$BIN/echo "	-x       : also install xsane (scanner tool)"
	$BIN/echo "	--debug  : list details of all chosen options without installing them i.e. a dry run"
	$BIN/echo
	$BIN/echo "	-b, -e|-ej|-ec|-ep|el, -eid, -f|-fb|-fr, -hp, -j, -m, -q, -r, -t, -w and -x  : can also be installed separately"
	$BIN/echo
	exit 3
}

print_help() {
	$BIN/echo
	$BIN/echo "Fedora $0 script version $VERSION, $V_CREATE"
	$BIN/echo "This bash script will install usefull applications, games,"
	$BIN/echo "and Oracle Java JRE or JDK depending on the version found,"
	$BIN/echo "stop firewalld, setup iptables and ip6tables,"
	$BIN/echo "configure the xsane server access and x11vnc for remote help"
	print_usage
	exit 3
}

print_version() {
	$BIN/echo "$VERSION, $V_DATE"
	exit 3
}


# fetch Fedora release number and set path for binaries
# as fedora version is not known yet, command 'cat' and 'grep' may not (yet) be preceeded by '$BIN' path
fcVER=`cat /etc/fedora-release | grep -Eo [0-9]+`
case "$fcVER" in
   14)
     BIN="/bin"; SBIN="/sbin"; PKG="yum"
     ;;
   22|23|24|25|26|27|28|29)
     BIN="/usr/bin"; SBIN="/usr/sbin"; PKG="dnf"
     ;;
   *)
     echo "incorrect Fedora version ($fcVER), this script only works for Fedora 14, 22-29"
     exit 3
     ;;
esac


if [ ! -f $($BIN/basename "$0") ] ; then
	$BIN/echo "This script may not be run from another path"
	exit 3
fi
if [ `$BIN/whoami` != "root" ] ; then
	$BIN/echo "This script must be run as root"
	exit 3
fi
if [ `$BIN/echo $PATH | $BIN/grep -Eic ':/root/bin'` -ne 1 ] ; then
	$BIN/echo "incorrect environmental variables, please use 'su -' to become root"
	exit 3
fi
if [ `$BIN/logname | $BIN/grep -Eic 'root'` -eq 1 ] ; then
	$BIN/echo "not logged in as regular user. login again and then use 'su -' to become root"
	exit 3
fi

# read all arguments into the array VAR[]
i=0; DEBUG=0; ONE=0; TWO=0; PARANOID=0; _JAVA=0; AMULE=0; BROAD=0; EID_BEL=0; FIREW=0; VIRBR0=0; RADVD=0; GAMES=0; SKYPE=0; SPOTIFY=0; STEAM=0; XSANE=0; HPLIP=0; GIT=0; ECLIPSE=0; WIRESHARK=0; QEMU=0; OPENSTACK=0; REM_HELP=0; OFFLANG=0; DUTCH=0; ENGLISH=0; FRENCH=0; GERMAN=0; MRI=0; MSTT=0; VIDEO=0; LABELS=0;
for p in $*; do
	i=$[$i+1]; VAR[$i]="$p"; #echo "$i: $p, ${VAR[$i]}";
	if [ "${VAR[$i]}" == "--debug" ] ; then DEBUG=1 ; fi
done
if [ "$DEBUG" == "1" ]; then $BIN/echo -e "$i arguments found\nchecking, please wait ..." ; fi

# check if each argument (e.g. -h) is a valid script option
j=1;
while (( j <= i ))   # Double parentheses, and no "$" preceding variables.
do
    case "${VAR[$j]}" in
	"--debug")	# display debug information (don't execute)
		DEBUG=1
		;;
	"--help")	# help requested
		print_help
		;;
	"--version")	# vesion requested
		print_version
		;;
	"-h")	# help requested
		print_help
		;;
	"-V")	# vesion requested
		print_version
		;;
	"-1")	# install repositories, flash, wget and configure iptables
		ONE=1; FIREW=1
		;;
	"-2")	# install applications only
		TWO=1
		;;
	"-B")	# install repositories and apllications and, configure iptables
		ONE=1; TWO=1; FIREW=1
		;;
	"-a")	# install aMule
		AMULE=1
		;;
	"-b")	# install Broadcomm WiFi chipset Firmware
		BROAD=1
		;;
	"-dutch")	# set user's GUI to Dutch
		DUTCH=1; OFFLANG=1;
		;;
	"-english")	# set user's GUI to US English
		ENGLISH=1
		;;
	"-french")	# set user's GUI to French
		FRENCH=1; OFFLANG=1;
		;;
	"-german")	# set user's GUI to German
		GERMAN=1; OFFLANG=1;
		;;
	"-e")	# install eclipse with Java, C/C++ and PHP Development Tools
		ECLIPSE=1
		;;
	"-ej")	# install eclipse with Java Development Tools
		ECLIPSE=2
		;;
	"-ec")	# install eclipse with C/C++ Development Tools
		ECLIPSE=3
		;;
	"-ep")	# install eclipse with PHP Development Tools
		ECLIPSE=4
		;;
	"-el")	# install eclipse with dutch, french and german and german language plugin
		ECLIPSE=5
		;;
	"-eid")	# install Belgian eID middleware and GUI
		EID_BEL=1
		;;
	"-f")	# configure basic ip(6)tables
		FIREW=1
		;;
	"-fb")	# configure ip(6)tables for bridging
		VIRBR0=1; FIREW=1
		;;
	"-fr")	# configure ip(6)tables for radvd, DNS- and DHCP(6)-server
		RADVD=1; FIREW=1
		;;
	"-g")	# install some games
		GAMES=1
		;;
	"-hp")	# install HP printer and scanner drivers
		HPLIP=1
		;;
	"-j")	# install java only
		_JAVA=1
		;;
	"-lang")	# install LibreOffice language pack Dutch and French
		OFFLANG=1
		;;
	"-k")	# install kdenlive, dvdstyler and recordmydesktop
		VIDEO=1
		;;
	"-l")	# install glabels and kcover
		LABEL=1
		;;
	"-m")	# install Microsoft True Type fonts
		MSTT=1
		;;
	"-mri")	# install aeskulap (DICOM viewer of MRI scans)
		MRI=1
		;;
	"-o")	# install OpenStack RDO repository
		OPENSTACK=1
		;;
	"-p")	# paranoid ip(6)tables OUTPUT chain
		PARANOID=1; FIREW=1
		;;
	"-q")	# install QEMU, libvirt, virt-manager and UEFI-firmware
		QEMU=1
		;;
	"-r")	# install remote help
		REM_HELP=1
		;;
	"-s")	# install skype
		SKYPE=1
		;;
	"-sp")	# install spotify
		SPOTIFY=1
		;;
	"-st")	# install steam engine
		STEAM=1
		;;
	"-t")	# install git with gui
		GIT=1
		;;
	"-w")	# install wireshark-gnome
		WIRESHARK=1
		;;
	"-x")	# install xsane (scanner) and test server connection
		XSANE=1
		;;
	*)
		# invalid argument found; exits at first unknown option and doesn't report other unknown options
		$BIN/echo -e "Error: unknown option '${VAR[$j]}' specified"
		exit 3
    esac
    ((j += 1))   # let "j+=1"
done

# at least one of the following 19 actions is needed !
if [ "$ONE" != "1" ] && [ "$TWO" != "1" ] && [ "$HPLIP" != "1" ] && [ "$GIT" != "1" ] && [ "$BROAD" != "1" ] && [ "$ECLIPSE" == "0" ] && [ "$EID_BEL" != "1" ] && [ "$FIREW" != "1" ] && [ "$_JAVA" != "1" ] && [ "$OFFLANG" != "1" ] && [ "$DUTCH" != "1" ] && [ "$ENGLISH" != "1" ] && [ "$FRENCH" != "1" ] && [ "$GERMAN" != "1" ] && [ "$MSTT" != "1" ] && [ "$WIRESHARK" != "1" ] && [ "$QEMU" != "1" ] && [ "$OPENSTACK" != "1" ] && [ "$REM_HELP" != "1" ] && [ "$XSANE" != "1" ] ; then 
	print_usage
	exit 3
fi

# check if all needed files (to install) are found in same directory (jre or jdk, skype, flash-player-npapi, ...)
if [ $fcVER -lt 17 ] && [ "$ONE" == "1" ] ; then
	# rpmfusion-free fedora 16- repo doesn't have fuse-exfat packaged
	if [ ! -f `$BIN/echo "fuse-exfat-1.0.1-1.$fcVER.`$BIN/uname -p`.rpm"` ] ; then
		$BIN/echo "fuse-exfat-1.0.1-1.$fcVER.`$BIN/uname -p`.rpm not found in this same directory"
		if [ "$DEBUG" == "0" ]; then
			exit 3
		fi
	# starting fedora 27, the rpm -K command has different output: "OK" is no longer at 4th position but at 3rd position. Therefor, the awk solutions below only partly work
	#elif [ "`$BIN/rpm -K --nosignature `$BIN/echo "fuse-exfat-1.0.1-1.$fcVER.`$BIN/uname -p`.rpm"` | $BIN/awk '{print $4}'`" != "OK" ] ; then
	#elif [ "`$BIN/rpm -K --nosignature `$BIN/echo "fuse-exfat-1.0.1-1.$fcVER.`$BIN/uname -p`.rpm"` | $BIN/awk '$3=="OK" {print $3} $4=="OK" {print $4}'`" != "OK" ] ; then
    # fedora26- md5 OK, fedora27+ digests OK or NOT OK
	elif [ `$BIN/rpm -K --nosignature `$BIN/echo "fuse-exfat-1.0.1-1.$fcVER.`$BIN/uname -p`.rpm"` | $BIN/grep -Eic "md5 ok|digests ok"` -lt 1 ] ; then
		$BIN/echo "fuse-exfat-1.0.1-1.$fcVER.`$BIN/uname -p`.rpm corrupt"
		if [ "$DEBUG" == "0" ]; then
			exit 3
		fi
	fi
	if [ ! -f `$BIN/echo "exfat-utils-1.0.1-1.$fcVER.`$BIN/uname -p`.rpm"` ] ; then
		$BIN/echo "exfat-utils-1.0.1-1.$fcVER.`$BIN/uname -p`.rpm not found in this same directory"
		if [ "$DEBUG" == "0" ]; then
			exit 3
		fi
	elif [ `$BIN/rpm -K --nosignature `$BIN/echo "exfat-utils-1.0.1-1.$fcVER.`$BIN/uname -p`.rpm"` | $BIN/grep -Eic "md5 ok|digests ok"` -lt 1 ] ; then
		$BIN/echo "exfat-utils-1.0.1-1.$fcVER.`$BIN/uname -p`.rpm corrupt"
		if [ "$DEBUG" == "0" ]; then
			exit 3
		fi
	fi
fi
# change of Oracle Java RPM name from version 8 to version 9 needs 'grep' change:
# jre-8u144-linux-x64.rpm is found with 'grep -E jre.+x64.rpm', and jre-{9.0.4,8u144}_linux-x64{_bin,}.rpm are found with 'grep -E jre.+x64.*\.rpm'
_JRE_686="corrupt"; JRE_686="no name"
if [ `$BIN/ls -v | $BIN/grep -Ec jre.+586.*\.rpm` -gt 0 ] ; then JRE_686=`$BIN/ls -v jre*586*.rpm | $BIN/tail -1` && [ `$BIN/rpm -K --nosignature ${JRE_686} | $BIN/grep -Eic "md5 ok|digests ok"` -eq 1 ] && _JRE_686="OK" ; fi
_JDK_686="corrupt"; JDK_686="no name"
if [ `$BIN/ls -v | $BIN/grep -Ec jdk.+586.*\.rpm` -gt 0 ] ; then JDK_686=`$BIN/ls -v jdk*586*.rpm | $BIN/tail -1` && [ `$BIN/rpm -K --nosignature ${JDK_686} | $BIN/grep -Eic "md5 ok|digests ok"` -eq 1 ] && _JDK_686="OK" ; fi
_JRE_x64="corrupt"; JRE_x64="no name"
if [ `$BIN/ls -v | $BIN/grep -Ec jre.+x64.*\.rpm` -gt 0 ] ; then JRE_x64=`$BIN/ls -v jre*x64*.rpm | $BIN/tail -1` && [ `$BIN/rpm -K --nosignature ${JRE_x64} | $BIN/grep -Eic "md5 ok|digests ok"` -eq 1 ] && _JRE_x64="OK" ; fi
_JDK_x64="corrupt"; JDK_x64="no name"
if [ `$BIN/ls -v | $BIN/grep -Ec jdk.+x64.*\.rpm` -gt 0 ] ; then JDK_x64=`$BIN/ls -v jdk*x64*.rpm | $BIN/tail -1` && [ `$BIN/rpm -K --nosignature ${JDK_x64} | $BIN/grep -Eic "md5 ok|digests ok"` -eq 1 ] && _JDK_x64="OK" ; fi
#echo "${_JRE_686};${JRE_686};${_JDK_686};${JDK_686};${_JRE_x64};${JRE_x64};${_JDK_x64};${JDK_x64}"
if [ "$_JAVA" == "1" ] ; then
	# -o = OR, || = OR, -a = AND, && = AND
	if [ `$BIN/uname -p` == "i686" ] ; then
		if [ "$JRE_686" == "no name" ] && [ "$JDK_686" == "no name" ] ; then
			$BIN/echo "32-bit jre or jdk RPM not found in this same directory"
			if [ "$DEBUG" == "0" ]; then
				# don't interrupt execution when --debug is set, just mention that a file was not found
				exit 3
			fi
		else
			if [ "$JDK_686" != "no name" ] && [ "$_JDK_686" != "OK" ] ; then
				$BIN/echo "Oracle Java 32-bit JDK RPM corrupt"
				if [ "$DEBUG" == "0" ]; then
					exit 3
				fi
			fi
			# skip JRE testing if JDK was found
			if [ "$JDK_686" == "no name" ] && [ "$JRE_686" != "no name" ] && [ "$_JRE_686" != "OK" ] ; then
				$BIN/echo "Oracle Java 32-bit JRE RPM corrupt"
				if [ "$DEBUG" == "0" ]; then
					exit 3
				fi
			fi
		fi
	fi
	if [ `$BIN/uname -p` == "x86_64" ] ; then
		if [ "$JRE_x64" == "no name" ] && [ "$JDK_x64" == "no name" ] ; then
			$BIN/echo "64-bit jre or jdk RPM not found in this same directory"
			# don't interrupt execution when --debug is set, just mention that a file was not found
			if [ "$DEBUG" == "0" ]; then
				exit 3
			fi
		else
			if [ "$JDK_x64" != "no name" ] && [ "$_JDK_x64" != "OK" ] ; then
				$BIN/echo "Oracle Java 64-bit JDK RPM corrupt"
				if [ "$DEBUG" == "0" ]; then
					exit 3
				fi
			fi
			# skip JRE testing if JDK was found
			if [ "$JDK_x64" == "no name" ] &&[ "$JRE_x64" != "no name" ] && [ "$_JRE_x64" != "OK" ] ; then
				$BIN/echo "Oracle Java 64-bit JRE RPM corrupt"
				if [ "$DEBUG" == "0" ]; then
					exit 3
				fi
			fi
		fi
	fi
fi
# skype-4.3 is end of live as of 2017 July 01 so, below file is no longer valid
#if [ "$SKYPE" == "1" ] ; then
#	if [ ! -f skype-4.3.0.37-fedora.i586.rpm ] ; then
#		$BIN/echo "skype-4.3.0-37 RPM not found in this same directory"
#		if [ "$DEBUG" == "0" ]; then
#			exit 3
#		fi
#	elif [ `$BIN/rpm -K --nosignature skype-4.3.0.37-fedora.i586.rpm | $BIN/grep -Eic "md5 ok|digests ok"` -lt 1 ] ; then
#		$BIN/echo "skype-4.3.0.37-fedora.i586.rpm RPM corrupt"
#		if [ "$DEBUG" == "0" ]; then
#			exit 3
#		fi
#	fi
#fi
# install the new 64-bit-only skype-for-linux previously downloaded from Skype website
if [ "$SKYPE" == "1" ] ; then
	if [ `$BIN/uname -p` == "i686" ] ; then
		$BIN/echo "skypeforlinux can only be installed on 64-bit systems"
		if [ "$DEBUG" == "0" ]; then
			exit 3
		fi
	else
		if [ ! -f skypeforlinux-64.rpm ] ; then
			$BIN/echo "skypeforlinux-64.rpm not found in this same directory"
			if [ "$DEBUG" == "0" ]; then
				exit 3
			fi
		elif [ `$BIN/rpm -K --nosignature skypeforlinux-64.rpm | $BIN/grep -Eic "md5 ok|digests ok"` -lt 1 ] ; then
			$BIN/echo "skypeforlinux-64.rpm RPM corrupt"
			if [ "$DEBUG" == "0" ]; then
				exit 3
			fi
		fi
	fi
fi
# uncomment next if-then-else block when the 'dnf install flash-plugin' from Adobe repository (confured with .repo file) doesn't work anymore
if [ "$ONE" == "1" ] ; then
	if [ `$BIN/uname -p` == "i686" ] ; then
		if [ `ls | $BIN/grep -Ec flash-player-npapi*.i386*` -ne 0 ] ; then
#		if [ `ls | $BIN/grep -Ec flash-player-npapi*.i386*` -eq 0 ] ; then
#			$BIN/echo "flash-player-npapi i386 RPM not found in this same directory"
#			if [ "$DEBUG" == "0" ]; then
#				exit 3
#			fi
		  if [ `$BIN/rpm -K --nosignature flash-player-npapi*.i386* | $BIN/grep -Eic "md5 ok|digests ok"` -lt 1 ] ; then
#		elif [ `$BIN/rpm -K --nosignature flash-player-npapi*.i386* | $BIN/grep -Eic "md5 ok|digests ok"` -lt 1 ] ; then
			$BIN/echo "flash-player-npapi i386 RPM corrupt"
			if [ "$DEBUG" == "0" ]; then
				exit 3
			fi
		  fi
		fi
	fi
	if [ `$BIN/uname -p` == "x86_64" ] ; then
		if [ `ls | $BIN/grep -Ec flash-player-npapi*.x86_64*` -ne 0 ] ; then
#		if [ `ls | $BIN/grep -Ec flash-player-npapi*.x86_64*` -eq 0 ] ; then
#			$BIN/echo "flash-player-npapi x86_64 RPM not found in this same directory"
#			if [ "$DEBUG" == "0" ]; then
#				exit 3
#			fi
		  if [ `$BIN/rpm -K --nosignature flash-player-npapi*.x86_64* | $BIN/grep -Eic "md5 ok|digests ok"` -lt 1 ] ; then
#		elif [ `$BIN/rpm -K --nosignature flash-player-npapi*.x86_64* | $BIN/grep -Eic "md5 ok|digests ok"` -lt 1 ] ; then
			$BIN/echo "flash-player-npapi x86_64 RPM corrupt"
			if [ "$DEBUG" == "0" ]; then
				exit 3
			fi
		  fi
		fi
	fi
fi

if [ "$BROAD" == "1" ] && [ "$ONE" != "1" ] ; then
	if [ ! -f /etc/yum.repos.d/rpmfusion-nonfree.repo ] ; then
		$BIN/echo "rpmfusion-nonfree repository not installed but required for broadcom-wl installation"
		if [ "$DEBUG" == "0" ]; then
			exit 3
		fi
	fi
fi
# check that no more than one GUI languages is selected at same time
GUI_LANG=$(( DUTCH+ENGLISH+FRENCH+GERMAN ));
if [ $GUI_LANG -gt 1 ] ; then
	$BIN/echo "-dutch, -english, -french and -german are mutually exclusive, choose one not more"
	if [ "$DEBUG" == "0" ]; then
		exit 3
	fi
fi
# check if the preconditions for eclipse are met
#if [ "$_JAVA" != "1" ] && [ `rpm -qa | $BIN/egrep -i 'jdk1|jdk-devel' | $BIN/egrep -c '7|8'` -lt 1 ] ; then
#	$BIN/echo "can't install eclipse; no Java JDK 7+ found or set to be installed"
#	if [ "$DEBUG" == "0" ]; then
#		exit 3
#	fi
#fi
# check if the preconditions for QEMU are met
if [ "$QEMU" == "1" ] ; then
	if [ `$BIN/grep -Ec 'vmx|svm' /proc/cpuinfo` -lt 1 ] || [ "`$BIN/uname -p`" != "x86_64" ] || [ `$BIN/rpm -qa | $BIN/grep -ic 'xen'` -gt 3 ] || [ `$SBIN/lsmod | $BIN/grep -Ec 'kvm'` -lt 2 ] ; then
		# [ "`uname -r`" 4.4.13-200.fc22.x86_64  -gt 2.6.20 ]
		$BIN/echo "your processor does not support virtualisation or is not 64-bit or, kvm module is not loaded or xen is installed"
		if [ "$DEBUG" == "0" ]; then
			exit 3
		fi
	fi
fi

# modifiy fedora.repo and fedora-updates.repo for archived Fedora versions
#$BIN/date +%s 							# current time epoc format 
#$BIN/date -d "Oct 21 1973" +%s			# convert given date to epoc format
if [ $fcVER -le $fcREL ]; then
	# don't modify if already archived repo configured
	if [ `$BIN/grep -Ec "^baseurl=http:\/\/dl.fedoraproject.org\/pub\/archive" /etc/yum.repos.d/fedora.repo` -ge 1 ]; then
		$BIN/sed -i -e '1,15s/^#baseurl=/baseurl=/' -e '1,15s/\(baseurl=.*\)/#\1\nbaseurl=http:\/\/dl.fedoraproject.org\/pub\/archive\/fedora\/linux\/releases\/$releasever\/Everything\/$basearch\/os\//' -e '1,15s/^#mirrorlist=/mirrorlist=/' -e '1,15s/\(mirrorlist=.*\)/#\1/' /etc/yum.repos.d/fedora.repo
	fi
	if [ `$BIN/grep -Ec "^baseurl=http:\/\/dl.fedoraproject.org\/pub\/archive" /etc/yum.repos.d/fedora-updates.repo` -ge 1 ]; then
		$BIN/sed -i -e '1,15s/^#baseurl=/baseurl=/' -e '1,15s/\(baseurl=.*\)/#\1\nbaseurl=http:\/\/dl.fedoraproject.org\/pub\/archive\/fedora\/linux\/updates\/$releasever\/$basearch\//' -e '1,15s/^#mirrorlist=/mirrorlist=/' -e '1,15s/\(mirrorlist=.*\)/#\1/' /etc/yum.repos.d/fedora-updates.repo
	fi
	$BIN/echo "Warning: This fedora version is archived. 3rd-party repos might no longer exist"
	read -p "Press any key to continue... " -n1 -s
	echo -e "\n"
fi

# correct faulty fedora 14 GNOME nautilus menu entry
if [ $fcVER -eq 14 ] && [ -f /usr/share/applications/gnome-nautilus.desktop ] ; then
	$BIN/sed -i 's/^NoDisplay=true/#NoDisplay=true\nCategories=GNOME;GTK;System;Utility;Core;/' /usr/share/applications/gnome-nautilus.desktop
fi


# start installation according chosen options
if [ "$ONE" == "1" ] ; then
	# https://www.tecmint.com/things-to-do-after-fedora-24-workstation-installation/ 		-> some post-install ideas, not all good
	$BIN/echo "wget tool will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install wget
	fi
	$BIN/echo "adobe, rpmfusion and `[ $fcVER -lt 20 ] && $BIN/echo livna || $BIN/echo remi` repositories will be configured for fedora $fcVER"
	if [ "$DEBUG" == "0" ]; then 
		RPMFUSION=0
		if [ ! -f `$BIN/echo "rpmfusion-free-release-$fcVER.noarch.rpm"` ] || [ ! -f `$BIN/echo "rpmfusion-nonfree-release-$fcVER.noarch.rpm"` ] ; then 
			$BIN/wget `$BIN/echo "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$fcVER.noarch.rpm"`
			$BIN/wget `$BIN/echo "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fcVER.noarch.rpm"`
			RPMFUSION=1
		fi
		$BIN/$PKG -y `[ $fcVER -lt 20 ] && $BIN/echo "localinstall --nogpgcheck" || $BIN/echo install` `$BIN/echo "*-$fcVER.noarch.rpm"`
		# repo for libdvdcss as a replacement for livna repo
		REMI=0; LIVNA=0;
		if [ $fcVER -lt 20 ]; then 
			if [ ! -f livna-release.rpm ] ; then 
				$BIN/wget http://ftp-stud.fht-esslingen.de/pub/Mirrors/rpm.livna.org/livna-release.rpm
				LIVNA=1
			fi
			$BIN/yum -y localinstall --nogpgcheck livna-release.rpm
		else
			if [ ! -f `$BIN/echo "remi-release-$fcVER.rpm"` ] ; then 
				$BIN/wget `$BIN/echo "http://rpms.famillecollet.com/fedora/remi-release-$fcVER.rpm"`
				#wget http://rpms.remirepo.net/RPM-GPG-KEY-remi
				REMI=1
			fi
			$BIN/dnf -y install `$BIN/echo "*-$fcVER.rpm"`
		fi
		# repo for flash-plugin as a replacement for my adobe-linux repo
		ADOBE=0
		if [ `$BIN/uname -p` == "i686" ] ; then
			if [ ! -f adobe-release-i386-1.0-1.noarch.rpm ] ; then 
				$BIN/wget http://linuxdownload.adobe.com/adobe-release/adobe-release-i386-1.0-1.noarch.rpm
				ADOBE=1
			fi
			$BIN/$PKG -y `[ $fcVER -lt 20 ] && $BIN/echo "localinstall --nogpgcheck" || $BIN/echo install` adobe-release-i386*
			# disable adobe .repo as RPMs changed location somewhere in 2017 when Firefox stopped NPAPI support
			#$BIN/sed -i 's/^enab.*/enabled=0/' /etc/yum.repos.d/adobe-linux-i386.repo
		fi
		if [ `$BIN/uname -p` == "x86_64" ] ; then
			if [ ! -f adobe-release-x86_64-1.0-1.noarch.rpm ] ; then 
				$BIN/wget http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
				ADOBE=1
			fi
			$BIN/$PKG -y `[ $fcVER -lt 20 ] && $BIN/echo "localinstall --nogpgcheck" || $BIN/echo install` adobe-release-x86_64*
			# disable adobe .repo should Adobe repo giving problems again
#			$BIN/sed -i 's/^enab.*/enabled=0/' /etc/yum.repos.d/adobe-linux-x86_64.repo
		fi
		# remove downloaded repository rpm's (all versions: rpm, rpm.1)
		if [ "$RPMFUSION" == "1" ] ; then $BIN/rm -f `$BIN/echo "rpmfusion*$fcVER.noarch.rpm*"` ; fi
		if [ "$REMI" == "1" ] ; then $BIN/rm -f `$BIN/echo "remi-release-$fcVER.rpm*"` ; fi
		if [ "$LIVNA" == "1" ] ; then $BIN/rm -f livna-release.rpm* ; fi
		if [ "$ADOBE" == "1" ] ; then $BIN/rm -f adobe-release-*.rpm* ; fi
	fi
	$BIN/echo "flash-{plugin,player-npapi}, ntfs-3g, fuse-exfat, unrar and p7zip will be installed"
	if [ "$DEBUG" == "0" ]; then
		# old names (2016-):
		#wget http://linuxdownload.adobe.com/linux/i386/flash-plugin-11.2.202.616-release.i386.rpm
		#wget http://linuxdownload.adobe.com/linux/x86_64/flash-plugin-11.2.202.616-release.x86_64.rpm
		# new names with NPAPI or PPAPI (2017+):
		#wget http://linuxdownload.adobe.com/linux/i386/flash-player-npapi-26.0.0.137-release.i386.rpm 		-> for firefox
		#wget http://linuxdownload.adobe.com/linux/x86_64/flash-player-npapi-26.0.0.137-release.x86_64.rpm
		#wget http://linuxdownload.adobe.com/linux/i386/flash-player-ppapi-26.0.0.137-release.i386.rpm 		-> for chrome
		#wget http://linuxdownload.adobe.com/linux/x86_64/flash-player-ppapi-26.0.0.137-release.x86_64.rpm
		if [ `$BIN/uname -p` == "i686" ] ; then
			if [ `ls | $BIN/grep -Ec flash-player-npapi*.i386*` -ne 0 ] ; then
				$BIN/$PKG -y install flash-player-npapi*i386* mozplugger ntfs-3g unrar p7zip
			else
				$BIN/$PKG -y install flash-plugin mozplugger ntfs-3g unrar p7zip
			fi
		fi
		if [ `$BIN/uname -p` == "x86_64" ] ; then
			if [ `ls | $BIN/grep -Ec flash-player-npapi*.x86_64*` -ne 0 ] ; then
				$BIN/$PKG -y install flash-player-npapi*x86_64* mozplugger ntfs-3g unrar p7zip
			else
				$BIN/$PKG -y install flash-plugin mozplugger ntfs-3g unrar p7zip
			fi
		fi
		if [ $fcVER -lt 20 ]; then
			$BIN/$PKG -y localinstall --nogpgcheck fuse-exfat-1.0.1-1.`$BIN/echo $fcVER`.`$BIN/uname -p`.rpm exfat-utils-1.0.1-1.`$BIN/echo $fcVER`.`$BIN/uname -p`.rpm
			$BIN/ln -s /usr/sbin/mount.exfat $SBIN/mount.exfat
			$BIN/ln -s /usr/sbin/mount.exfat-fuse $SBIN/mount.exfat-fuse
		else
			$BIN/$PKG -y install fuse-exfat
		fi
	fi
	# check if Bluetooth hardware is present and install needed binaries not installed by default (bug ?)
	# fedora26+ obsoleted blueman package in favor of blueberry package !
	if [ `$BIN/lsusb | $BIN/grep -ic blue` -ge 1 ]; then
		$BIN/echo "bluetooth applet will be installed"
		if [ "$DEBUG" == "0" ]; then 
			$BIN/$PKG -y install bluez bluez-cups `[ $fcVER -lt 26 ] && $BIN/echo blueman || $BIN/echo blueberry` NetworkManager-bluetooth
			if [ $fcVER -lt 20 ]; then 
				$SBIN/chkconfig bluetooth on
				$SBIN/service bluetooth start
			else
				$BIN/systemctl enable bluetooth
				$BIN/systemctl start bluetooth
			fi
		fi
	fi
	$BIN/echo "meld, gparted and cups-pdf will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install meld gparted cups-pdf `[ $fcVER -lt 20 ] && $BIN/echo alacarte`
	fi
	$BIN/echo "wavemon and S.M.A.R.T. tools will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install wavemon smartmontools
	fi
	$BIN/echo "`[ $fcVER -ge 20 ] && $BIN/echo "inxi and "`lshw will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install lshw `[ $fcVER -ge 20 ] && $BIN/echo inxi`
	fi
	$BIN/echo "testdisk including PhotoRec will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install testdisk
	fi
	$BIN/echo "vinagre and virt-viewer for VNC- or SPICE-enabled virtual machines will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install virt-viewer vinagre
	fi
	$BIN/echo "SELinux troubleshooter will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install setroubleshoot setroubleshoot-server setools-console
	fi
	$BIN/echo "some not used services (nfs, rpcbind) will be stopped"
	if [ "$DEBUG" == "0" ]; then 
		if [ $fcVER -lt 20 ]; then 
			# fedora 19- services
			$SBIN/service nfs stop
			$SBIN/chkconfig nfs off
			$SBIN/service nfslock stop
			$SBIN/chkconfig nfslock off
			$SBIN/service rpcbind stop
			$SBIN/chkconfig rpcbind off
			$SBIN/service rpcgssd stop
			$SBIN/chkconfig rpcgssd off
			$SBIN/service rpcidmapd stop
			$SBIN/chkconfig rpcidmapd off
			$SBIN/service rpcsvcgssd stop
			$SBIN/chkconfig rpcsvcgssd off
		else
			# fedora 20+ services
			$BIN/systemctl stop nfs.service
			$BIN/systemctl disable nfs.service
			$BIN/systemctl stop nfs-client.target
			$BIN/systemctl disable nfs-client.target
			$BIN/systemctl stop rpcbind.socket
			$BIN/systemctl disable rpcbind.socket
			$BIN/systemctl mask rpcbind.socket
			$BIN/systemctl stop rpcbind.service 2>/dev/null
			$BIN/systemctl disable rpcbind.service 2>/dev/null
			$BIN/systemctl mask rpcbind.service 2>/dev/null
			$BIN/systemctl stop rpc-statd.service 2>/dev/null
			$BIN/systemctl disable rpc-statd.service 2>/dev/null
			$BIN/systemctl stop rpc-statd-notify.service 2>/dev/null
			$BIN/systemctl disable rpc-statd-notify.service 2>/dev/null
		fi
	fi
	$BIN/echo "totem, rhythmbox, parole, exaile, xfburn, brasero and claws-mail will be removed"
	if [ "$DEBUG" == "0" ]; then 
		if [ $fcVER -ge 26 ]; then
			$BIN/$PKG -y remove totem rhythmbox parole exaile 2>/dev/null
		else
			# also for Fedora 14, not only Fedora > 26
			$BIN/$PKG -y remove totem rhythmbox parole 2>/dev/null
		fi
		$BIN/$PKG -y remove xfburn brasero 2>/dev/null
		$BIN/$PKG -y remove evolution claws-mail claws-mail-plugins-pdf-viewer claws-mail-plugins-fancy claws-mail-plugins-smime 2>/dev/null
	fi
	# install latests fc14 available firefox version from repository https://rpms.remirepo.net/archives/fedora/14/
	if [ $fcVER -eq 14 ]; then
		$BIN/echo "latest available fc$fcVER firefox version will be installed"
		if [ "$DEBUG" == "0" ]; then 
			REMIFIRE=0
			if [ ! -f `$BIN/echo "remi-release-$fcVER.rpm"` ] ; then 
				$BIN/wget https://rpms.remirepo.net/archives/fedora/$fcVER/remi/`$BIN/uname -p`/firefox-26.0-1.fc$fcVER.remi.`$BIN/uname -p`.rpm
				REMIFIRE=1
			fi
			if [ ! -f `$BIN/echo "remi-release-$fcVER.rpm"` ] ; then 
				$BIN/wget https://rpms.remirepo.net/archives/fedora/$fcVER/remi/`$BIN/uname -p`/xulrunner-last-26.0-1.fc$fcVER.remi.`$BIN/uname -p`.rpm
				REMIFIRE=1
			fi
			$BIN/$PKG -y `[ $fcVER -lt 20 ] && $BIN/echo "localinstall --nogpgcheck" || $BIN/echo install` `$BIN/echo "*.fc$fcVER.remi.`$BIN/uname -p`.rpm"`
			if [ "$REMIFIRE" == "1" ] ; then $BIN/rm -f `$BIN/echo "*.fc$fcVER.remi.`$BIN/uname -p`.rpm"` ; fi
		fi
	fi
fi

if [ "$OFFLANG" == "1" ] || [ "$DUTCH" == "1" ] || [ "$FRENCH" == "1" ] || [ "$GERMAN" == "1" ]; then
	$SBIN/paperconfig -p A4
fi

if [ "$OFFLANG" == "1" ] ; then
	$BIN/echo "`[ $fcVER -lt 15 ] && $BIN/echo Open || $BIN/echo Libre`Office language pack Dutch, French and German will be installed"
	if [ $fcVER -ge 15 ] ; then
		if [ "$DEBUG" == "0" ]; then 
			$BIN/$PKG -y install libreoffice-langpack-nl autocorr-nl hunspell-nl hyphen-nl libreoffice-langpack-fr autocorr-fr hyphen-fr hunspell-fr libreoffice-langpack-de autocorr-de hunspell-de hyphen-de
		fi
	else
		if [ "$DEBUG" == "0" ]; then 
			$BIN/$PKG -y install openoffice.org-langpack-nl autocorr-nl hunspell-nl hyphen-nl openoffice.org-langpack-fr autocorr-fr hunspell-fr hyphen-fr openoffice.org-langpack-de autocorr-de hunspell-de hyphen-de
		fi
	fi
fi
if [ "$DUTCH" == "1" ] ; then
	$BIN/echo "`$BIN/logname`'s GUI will be set to Dutch (logout twice to apply)"
	if [ "$DEBUG" == "0" ]; then 
		# for GNOME 2.32, from fedora 16 onwards GNOME 3 is default GUI so, I use MATE
		if [ $fcVER -le 15 ]; then
#			$BIN/echo -e "[Desktop]\nLanguage=en_US.utf8\nLayout=be" > /home/`$BIN/logname`/.dmrc
			# the next commands will remove user customised keyboard layout
			$BIN/echo -e "[Desktop]\nLanguage=nl_BE.utf8" > /home/`$BIN/logname`/.dmrc
			$BIN/chcon -u system_u -t xdm_home_t /home/`$BIN/logname`/.dmrc
			$BIN/chmod 0600 /home/`$BIN/logname`/.dmrc
			$BIN/chown `$BIN/logname`:`$BIN/logname` /home/`$BIN/logname`/.dmrc
		else
			# for MATE installed Fedora'
			$BIN/echo  -e "export LANGUAGE=nl_BE.UTF-8\nexport LANG=nl_BE.UTF-8" > /home/`$BIN/logname`/.i18n
			$BIN/chcon -t user_home_t /home/`$BIN/logname`/.i18n
			$BIN/chmod 0600 /home/`$BIN/logname`/.i18n
			$BIN/chown `$BIN/logname`:`$BIN/logname` /home/`$BIN/logname`/.i18n
		fi
	fi
fi
if [ "$ENGLISH" == "1" ] ; then
	$BIN/echo "`$BIN/logname`'s GUI will be set to US English (logout twice to apply)"
	if [ "$DEBUG" == "0" ]; then 
		if [ $fcVER -le 15 ]; then
			$BIN/echo -e "[Desktop]\nLanguage=en_US.utf8" > /home/`$BIN/logname`/.dmrc
			$BIN/chcon -u system_u -t xdm_home_t /home/`$BIN/logname`/.dmrc
			$BIN/chmod 0600 /home/`$BIN/logname`/.dmrc
			$BIN/chown `$BIN/logname`:`$BIN/logname` /home/`$BIN/logname`/.dmrc
		else
			$BIN/echo  -e "export LANGUAGE=en_US.UTF-8\nexport LANG=en_US.UTF-8" > /home/`$BIN/logname`/.i18n
			$BIN/chcon -t user_home_t /home/`$BIN/logname`/.i18n
			$BIN/chmod 0600 /home/`$BIN/logname`/.i18n
			$BIN/chown `$BIN/logname`:`$BIN/logname` /home/`$BIN/logname`/.i18n
		fi
	fi
fi
if [ "$FRENCH" == "1" ] ; then
	$BIN/echo "`$BIN/logname`'s GUI will be set to French (logout twice to apply)"
	if [ "$DEBUG" == "0" ]; then 
		if [ $fcVER -le 15 ]; then
			$BIN/echo -e "[Desktop]\nLanguage=fr_FR.utf8" > /home/`$BIN/logname`/.dmrc
			$BIN/chcon -u system_u -t xdm_home_t /home/`$BIN/logname`/.dmrc
			$BIN/chmod 0600 /home/`$BIN/logname`/.dmrc
			$BIN/chown `$BIN/logname`:`$BIN/logname` /home/`$BIN/logname`/.dmrc
		else
			$BIN/echo  -e "export LANGUAGE=fr_FR.UTF-8\nexport LANG=fr_FR.UTF-8" > /home/`$BIN/logname`/.i18n
			$BIN/chcon -t user_home_t /home/`$BIN/logname`/.i18n
			$BIN/chmod 0600 /home/`$BIN/logname`/.i18n
			$BIN/chown `$BIN/logname`:`$BIN/logname` /home/`$BIN/logname`/.i18n
		fi
	fi
fi
if [ "$GERMAN" == "1" ] ; then
	$BIN/echo "`$BIN/logname`'s GUI will be set to German (logout twice to apply)"
	if [ "$DEBUG" == "0" ]; then 
		if [ $fcVER -le 15 ]; then
			$BIN/echo -e "[Desktop]\nLanguage=de_DE.utf8" > /home/`$BIN/logname`/.dmrc
			$BIN/chcon -u system_u -t xdm_home_t /home/`$BIN/logname`/.dmrc
			$BIN/chmod 0600 /home/`$BIN/logname`/.dmrc
			$BIN/chown `$BIN/logname`:`$BIN/logname` /home/`$BIN/logname`/.dmrc
		else
			$BIN/echo  -e "export LANGUAGE=de_DE.UTF-8\nexport LANG=de_DE.UTF-8" > /home/`$BIN/logname`/.i18n
			$BIN/chcon -t user_home_t /home/`$BIN/logname`/.i18n
			$BIN/chmod 0600 /home/`$BIN/logname`/.i18n
			$BIN/chown `$BIN/logname`:`$BIN/logname` /home/`$BIN/logname`/.i18n
		fi
	fi
fi

if [ "$MSTT" == "1" ] ; then
	$BIN/echo "Microsoft True Type fonts will be installed"
	if [ "$DEBUG" == "0" ]; then 
		MSTTDL=0
		if [ ! -f msttcore-fonts-installer-2.6-1.noarch.rpm ] ; then 
			$BIN/wget https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm --no-check-certificate
			MSTTDL=1
		fi
		if [ `$BIN/rpm -K --nosignature msttcore-fonts-installer* 2>&1 | $BIN/grep -ic error` -gt 0 ] ; then
			$BIN/echo "msttcore-fonts-installer-2.6-1.noarch.rpm is not an RPM package, skipping installation"
		else
			$BIN/$PKG -y `[ $fcVER -lt 20 ] && $BIN/echo "localinstall --nogpgcheck" || $BIN/echo install` `$BIN/ls msttcore-fonts-installer*`
		fi
		# remove downloaded rpm's (all versions: rpm, rpm.1)
		if [ "$MSTTDL" == "1" ] ; then $BIN/rm -f msttcore-fonts-installer-*.rpm* ; fi
	fi
fi

if [ "$BROAD" == "1" ] ; then
	$BIN/echo "Broadcom BCM43[11,12,13,21,22,142,224,225,227,228,31,52,60] Firmware will be (re)installed (reboot to apply)"
	if [ "$DEBUG" == "0" ]; then 
		# if broadcom-wl was installed before, uninstall all kmod-wl or new kmod-wl will not be compiled and installed again
		$BIN/rpm -e `$BIN/rpm -qa | $BIN/grep ^kmod-wl`
		$BIN/$PKG -y remove broadcom-wl
		# because of bug, install kernel-devel first or broadcom-wl will install wrong kernel-PAEdevel as dependency
		$BIN/$PKG -y install kernel-headers-`$BIN/uname -r` kernel-devel-`$BIN/uname -r`
		# broadcom-wl requires rpmfusion-non-free repository
		$BIN/$PKG -y install broadcom-wl
	fi
fi

if [ "$FIREW" == "1" ] ; then
	$BIN/echo "TCP_wrapper will be configured for IPv4 and IPv6"
	if [ "$DEBUG" == "0" ]; then 
		#vim /etc/hosts.deny
		if [ `$BIN/grep -Eic "all:" /etc/hosts.deny` -eq 0 ] ; then
			$BIN/echo -e "ALL:ALL" >> /etc/hosts.deny
		fi
		#vim /etc/hosts.allow 
		# link-local addresses: 169.254. and [fe80::]/64; [2a02:a03f::]/32 = Proximus Global Unicast prefix
		#echo -e "sendmail: 127., 192., [::1]/128, [2a02:a03f::]/32, [fe80::]/64" >> /etc/hosts.allow
		if [ `$BIN/grep -Eic "sshd:" /etc/hosts.allow` -eq 0 ] ; then
			$BIN/echo -e "sshd: 127., 192., [::1]/128, [2a02:a03f::]/32, [fe80::]/64" >> /etc/hosts.allow
		fi
	fi
	$BIN/echo "/etc/hosts will be used to block some adware sites for IPv4 and IPv6"
	# remember: /etc/hosts can only block hosts, NOT domains !
	if [ "$DEBUG" == "0" ]; then 
		#vim /etc/hosts
		if [ `$BIN/grep -Eic "ad.doubleclick.net" /etc/hosts` -eq 0 ] ; then
			# cannonical name for dart.l.doubleclick.net, no IPv6 addr yet (dig ad.doubleclick.net aaaa)
			$BIN/echo -e "127.0.0.1\tad.doubleclick.net" >> /etc/hosts
		fi
		if [ `$BIN/grep -Eic "dart.l.doubleclick.net" /etc/hosts` -eq 0 ] ; then
			$BIN/echo -e "127.0.0.1\tdart.l.doubleclick.net" >> /etc/hosts
		fi
		if [ `$BIN/grep -Eic "adclick.g.doubleclick.net" /etc/hosts` -eq 0 ] ; then
			# cannonical name for pagead.l.doubleclick.net, no IPv6 addr yet (dig adclick.g.doubleclick.net aaaa)
			$BIN/echo -e "127.0.0.1\tadclick.g.doubleclick.net" >> /etc/hosts
		fi
		# don't add next or clicking on a link of a google search result will complain with page not found
#		if [ `$BIN/grep -Eic "www.googleadservices.com" /etc/hosts` -eq 0 ] ; then
#			# cannonical name for pagead.l.doubleclick.net, no IPv6 addr yet (dig www.googleadservices.com aaaa)
#			$BIN/echo -e "127.0.0.1\twww.googleadservices.com" >> /etc/hosts
#		fi
		if [ `$BIN/grep -Eic "pagead.l.doubleclick.net" /etc/hosts` -eq 0 ] ; then
			$BIN/echo -e "127.0.0.1\tpagead.l.doubleclick.net" >> /etc/hosts
		fi
		if [ `$BIN/grep -Ei "^127" /etc/hosts | $BIN/grep -Eic "googleads.g.doubleclick.net"` -eq 0 ] ; then
			# cannonical name for pagead46.l.doubleclick.net
			$BIN/echo -e "127.0.0.1\tgoogleads.g.doubleclick.net" >> /etc/hosts
		fi
		if [ `$BIN/grep -Ei "^127" /etc/hosts | $BIN/grep -Eic "pagead2.googlesyndicate.com"` -eq 0 ] ; then
			$BIN/echo -e "127.0.0.1\tpagead2.googlesyndicate.com" >> /etc/hosts
		fi
		if [ `$BIN/grep -Ei "^127" /etc/hosts | $BIN/grep -Eic "pagead46.l.doubleclick.net"` -eq 0 ] ; then
			$BIN/echo -e "127.0.0.1\tpagead46.l.doubleclick.net" >> /etc/hosts
		fi
		if [ `$BIN/grep -Ei "^127" /etc/hosts | $BIN/grep -Eic "f6457565dc681.dm.px8a6cqau6mey33js512.com"` -eq 0 ] ; then
			# cannonical name for px8a6cqau6mey33js512.com
			$BIN/echo -e "127.0.0.1\tf6457565dc681.dm.px8a6cqau6mey33js512.com" >> /etc/hosts
		fi
		if [ `$BIN/grep -Ei "^127" /etc/hosts | $BIN/grep -Eic "px8a6cqau6mey33js512.com"` -eq 0 ] ; then
			$BIN/echo -e "127.0.0.1\tpx8a6cqau6mey33js512.com" >> /etc/hosts
		fi
		if [ `$BIN/grep -Ei "^127" /etc/hosts | $BIN/grep -Eic "s7.addthis.com"` -eq 0 ] ; then
			$BIN/echo -e "127.0.0.1\ts7.addthis.com" >> /etc/hosts
		fi
		if [ `$BIN/grep -Ei "^::1" /etc/hosts | $BIN/grep -Eic "googleads.g.doubleclick.net"` -eq 0 ] ; then
			# cannonical name for pagead46.l.doubleclick.net
			$BIN/echo -e "::1\t\tgoogleads.g.doubleclick.net" >> /etc/hosts
		fi
		if [ `$BIN/grep -Ei "^::1" /etc/hosts | $BIN/grep -Eic "pagead2.googlesyndicate.com"` -eq 0 ] ; then
			$BIN/echo -e "::1\t\tpagead2.googlesyndicate.com" >> /etc/hosts
		fi
		if [ `$BIN/grep -Ei "^::1" /etc/hosts | $BIN/grep -Eic "pagead46.l.doubleclick.net"` -eq 0 ] ; then
			$BIN/echo -e "::1\t\tpagead46.l.doubleclick.net" >> /etc/hosts
		fi
		if [ `$BIN/grep -Ei "^::1" /etc/hosts | $BIN/grep -Eic "s7.addthis.com"` -eq 0 ] ; then
			$BIN/echo -e "::1\t\ts7.addthis.com" >> /etc/hosts
		fi
	fi
	$BIN/echo "iptables and ip6tables will be configured and firewalld disabled"
	if [ "$DEBUG" == "1" ] && [ "$RADVD" == "1" ] ; then
		$BIN/echo "ip(6)tables will be configured to accept radvd, named and dhcp(6) requests"
    fi
	if [ "$DEBUG" == "1" ] && [ "$PARANOID" == "1" ] ; then
		$BIN/echo "ip(6)tables paranoid OUTPUT rules will be configured"
    fi
	if [ "$DEBUG" == "0" ]; then 
		# yum|dnf install iptables-utils that only adds /usr/sbin/nfnl_osf, therfore not installing iptables-utils
		$BIN/$PKG -y install iptables-services
		if [ $fcVER -lt 20 ]; then 
			# fedora 19- services
			if [ $fcVER -ge 15 ]; then
				$SBIN/service firewalld stop
				$SBIN/chkconfig firewalld off
			fi
			$SBIN/service iptables start
			$SBIN/chkconfig iptables on
			$SBIN/service ip6tables start
			$SBIN/chkconfig ip6tables on
		else
			# fedora 20+ services
			$BIN/systemctl stop firewalld
			$BIN/systemctl disable firewalld
			$BIN/systemctl mask firewalld
			$BIN/systemctl enable iptables
			$BIN/systemctl enable ip6tables
			$BIN/systemctl start iptables
			$BIN/systemctl start ip6tables
		fi
		# check name of wired LAN interface (E64x0 laptops Thierry)
		LAN_INT=""
	    case "`$SBIN/ifconfig -a | $BIN/sed -n '1s/^\([^ ]\+\).*/\1/p'`" in
		"eth0:")		# set LAN interface to eth0
			LAN_INT="-i eth0"
			;;
		"eno1:")		# set LAN interface to eno1
			LAN_INT="-i eno1"
			;;
		"enp0s25:")	# set LAN interface to enp0s25
			LAN_INT="-i enp0s25"
			;;
		*)
			# unknown interface name found
			LAN_INT=""
	    esac
		#vi /etc/sysconfig/iptables
		$SBIN/iptables -F
		$SBIN/iptables -X
		$SBIN/iptables -P INPUT DROP
		$SBIN/iptables -P FORWARD DROP
		$SBIN/iptables -P OUTPUT ACCEPT
		$SBIN/iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
		# for dual stack systems, drop IPv6 in IPv4 i.e. IPv4 protocol field = 41 (ipv6)
		$SBIN/iptables -A INPUT -p 41 -j DROP
		$SBIN/iptables -A FORWARD -p 41 -j DROP
		# on dual stack systems, drop a few IPv6 in IPv4 tunneling mechanisms
		$SBIN/iptables -A INPUT -s 192.88.99.0/24 -j DROP					# 6to4 relay server addr
		$SBIN/iptables -A OUTPUT -m conntrack --ctstate INVALID -j DROP
		$SBIN/iptables -A OUTPUT -d 192.88.99.0/24 -j DROP
		$SBIN/iptables -A OUTPUT -p tcp -m tcp --dport 5072 -j DROP			# Anything In Anything (AYIYA) tunnel via TCP/UDP#5072
		$SBIN/iptables -A OUTPUT -p udp -m udp --dport 5072 -j DROP
		$SBIN/iptables -A OUTPUT -p tcp -m tcp --dport 3653 -j DROP			# IPv6 tunnel brokers via TCP/UDP#3653 (TSP protocol)
		$SBIN/iptables -A OUTPUT -p udp -m udp --dport 3653 -j DROP
		$SBIN/iptables -A INPUT -p icmp -j ACCEPT
		$SBIN/iptables -A INPUT -i lo -j ACCEPT
		$SBIN/iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
		$SBIN/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 22 -j ACCEPT
		# allow hosts to make DNS-queries to this DNS-sever (UDP#53) and get an IP-addr from this DHCP-server (DHCP UDP#67) and PXE-boot (DHCP UDP#69)
		if [ "$RADVD" == "1" ] ; then
			$SBIN/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 53 -j ACCEPT
			$SBIN/iptables -A INPUT -p udp -m conntrack --ctstate NEW -m udp --dport 53 -j ACCEPT
			$SBIN/iptables -A INPUT -p udp -m conntrack --ctstate NEW -m udp -m multiport --dports 67,69 -j ACCEPT
		fi
		# allow Virtual Machines connected to bridge virbr0 to resolve URLs (DNS #53) and get an IP-addr from host (DHCP #67) and PXE-boot (DHCP #69)
		BR0_INT="-i virbr0"
		if [ "$VIRBR0" == "1" ] && [ "$QEMU" != "1" ] && [ `$BIN/ps -ef | $BIN/grep -c libvirtd` -lt 2 ] ; then
			$SBIN/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp $BR0_INT --dport 22 -j ACCEPT
			$SBIN/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp $BR0_INT --dport 53 -j ACCEPT
			$SBIN/iptables -A INPUT -p udp -m conntrack --ctstate NEW -m udp $BR0_INT --dport 53 -j ACCEPT
			$SBIN/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp $LAN_INT --dport 53 -j ACCEPT
			$SBIN/iptables -A INPUT -p udp -m conntrack --ctstate NEW -m udp $LAN_INT --dport 53 -j ACCEPT
			$SBIN/iptables -A INPUT -p udp -m conntrack --ctstate NEW -m udp $BR0_INT -m multiport --dports 67,69 -j ACCEPT
			$SBIN/iptables -A INPUT -p udp -m conntrack --ctstate NEW -m udp $LAN_INT -m multiport --dports 67,69 -j ACCEPT
			# check and if not, activate IPv4 forwarding
			IP4FWD=0
			# fedora 18- IPv4 forwarding configured in /etc/sysctl.conf
			if [ `$BIN/grep -Eci "^net.ipv4.conf.all.forwarding" /etc/sysctl.conf` -ge 1 ] ; then
				$BIN/sed -i 's/^net.ipv4.conf.all.forwarding.*/net.ipv4.conf.all.forwarding = 1/' /etc/sysctl.conf
				IP4FWD=1
			fi
			# fedora 19+ IPv4 forwarding configured in /usr/lib/sysctl.d/* or in /etc/sysctl.d/*.conf
			for i in "`$BIN/ls /usr/lib/sysctl.d`" ; do
				if [ `$BIN/grep -Eci "^net.ipv4.conf.all.forwarding" $i` -ge 1 ] ; then
					$BIN/sed -i 's/^net.ipv4.conf.all.forwarding.*/net.ipv4.conf.all.forwarding = 1/' $i
					IP4FWD=1
				fi
			done
			for i in "`$BIN/ls /etc/sysctl.d`" ; do
				if [ `$BIN/grep -Eci "^net.ipv4.conf.all.forwarding" $i` -ge 1 ] ; then
					$BIN/sed -i 's/^net.ipv4.conf.all.forwarding.*/net.ipv4.conf.all.forwarding = 1/' $i
					IP4FWD=1
				fi
			done
			if [ $IP4FWD -ne 1]; then
				if [ $fcVER -lt 19 ]; then
					$BIN/echo -e "net.ipv4.conf.all.forwarding = 1 " >> /etc/sysctl.conf
				else
					$BIN/echo -e "net.ipv4.conf.all.forwarding = 1" >> /etc/sysctl.d/51-forwarding.conf		
				fi
			fi
			BR0_INT="virbr0"
			$SBIN/iptables -A FORWARD -o $BR0_INT -j ACCEPT
			$SBIN/iptables -A FORWARD -i $BR0_INT -j ACCEPT
		fi
		if [ "$LAN_INT" != "" ]; then
			# allow incoming http(s) from wired LAN interface only
			$SBIN/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp $LAN_INT -m multiport --dports 80,443 -j ACCEPT
		fi
		$SBIN/iptables -A INPUT -p udp -m conntrack --ctstate NEW -m udp --dport 1194 -j ACCEPT
		# when using avahi service, accept mDNS (multicast DNS requests) for destination IPv4 addr 224.0.0.251/32
		#$SBIN/iptables -A INPUT -p udp -m conntrack --ctstate NEW -m udp --dport 5353 -j ACCEPT
		$SBIN/iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
		$SBIN/iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited
		if [ "$PARANOID" == "1" ] ; then
			$BIN/echo "iptables and ip6tables paranoid OUTPUT rules will be configured"
			$SBIN/iptables -P OUTPUT DROP
			$SBIN/iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			$SBIN/iptables -A OUTPUT -d 127.0.0.0/8 ! -o lo -j DROP
			$SBIN/iptables -A OUTPUT -d 127.0.0.0/8 -o lo -j ACCEPT
			$SBIN/iptables -A OUTPUT -p icmp -j ACCEPT
			$SBIN/iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 22 -j ACCEPT
			$SBIN/iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 25 -j ACCEPT
			$SBIN/iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 53 -j ACCEPT
			$SBIN/iptables -A OUTPUT -p udp -m conntrack --ctstate NEW --dport 53 -j ACCEPT
			$SBIN/iptables -A OUTPUT -p udp -m conntrack --ctstate NEW -m multiport --dports 67,68 -j ACCEPT
			$SBIN/iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW -m multiport --dports 80,443 -j ACCEPT
			$SBIN/iptables -A OUTPUT -p udp -m conntrack --ctstate NEW --dport 123 -j ACCEPT
			$SBIN/iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW -m multiport --dports 110,995 -j ACCEPT
			$SBIN/iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW -m multiport --dports 143,993 -j ACCEPT
			$SBIN/iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 587 -j ACCEPT
			$SBIN/iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 1194 -j ACCEPT
			if [ "$XSANE" == "1" ] ; then
				# Xsane scanner-server TCP#6566
				$SBIN/iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 6566 -j ACCEPT
			fi
			# CUPS (and IPP) TCP#631, HP JetDirect socket TCP#9100, SNMP TCP#161 (to discover printer capabilities)
			$SBIN/iptables -A OUTPUT -p tcp -m conntrack --ctstate NEW -m multiport --dports 161,631,9100 -j ACCEPT
		fi
		$SBIN/iptables-save > /etc/sysconfig/iptables
		$SBIN/iptables -nvL
		#vi /etc/sysconfig/ip6tables
		$SBIN/ip6tables -F
		$SBIN/ip6tables -X
		$SBIN/ip6tables -P INPUT DROP
		$SBIN/ip6tables -P FORWARD DROP
		$SBIN/ip6tables -P OUTPUT ACCEPT
		# fix the IPv6 Routing Header Type 0 security issue for kernel-2.6.21.1-
		# deprecating RFC: https://tools.ietf.org/html/rfc5095
		$SBIN/ip6tables -A INPUT -m rt --rt-type 0 --rt-segsleft 0 -j DROP							# '--rt-segsleft 0' can be left out
		$SBIN/ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP
		$SBIN/ip6tables -A INPUT ! -i lo -s ::1/128 -j DROP											# anti-spoofing
		# either allow all (not secure) icmpv6 messages (one rule below) or implement RFC4890 (many icmp rules hereafter)
		#$SBIN/ip6tables -A INPUT -p icmpv6 -j ACCEPT
		# implement RFC4890 (IETF.org ICMPv6 Filtering Recommendations) then block all remaining icmpv6 messages
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 1 -j ACCEPT								# destination-unreachable
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 2 -j ACCEPT								# packet-too-big
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 3 -j ACCEPT								# time-exceeded
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 4 -j ACCEPT								# parameter-problem
		# allow incoming and outgoing 'ping -6' (same as 'ping6')
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 128 -m limit --limit 30/min -j ACCEPT		# echo-request
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 128 -j DROP	# drop exceeding number of requests or ESTABLISHED rule will accept anyway
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 129 -j ACCEPT								# echo-reply
		# allow listener messages from link-local addresses only
 		#$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 130 -s fe80::/10 -j ACCEPT				# listener query
		#$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 131 -s fe80::/10 -j ACCEPT				# listener report
		#$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 132 -s fe80::/10 -j ACCEPT				# listener done
		#$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 143 -s fe80::/10 -j ACCEPT				# listener report v2
		# allow (RS,) RA, NS, NA  and redirect from directly (Hop Limit = 255) connected router or host and not from Internet routers or hosts
		# Router and Neighbour Discovery is performed with multicast addr ff00::/8, https://tools.ietf.org/html/rfc4861
		# ff01::1 (node-local), ff02::1 (link-local), ff05::1 (site-local) for ND and ff01::2, ff02::2, ff05::2 for RD
		# allow hosts to make ICMPv6 Router Solicitations to this Router (radvd)
		if [ "$RADVD" == "1" ] ; then
			# radvd (you are a router) is running on this machine
			$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 133 -m hl --hl-eq 255 -j ACCEPT		# router-solicitation
		fi
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 134 -m hl --hl-eq 255 -j ACCEPT			# router-advertisement
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 135 -m hl --hl-eq 255 -j ACCEPT			# neighbor-solicitation
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 136 -m hl --hl-eq 255 -j ACCEPT			# neighbor-advertisement
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 137 -m hl --hl-eq 255 -j ACCEPT			# redirect (from router)
		# allow RFC3122 and RFC4286
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 141 -m hl --hl-eq 255 -j ACCEPT			# Inverse ND Solicitation
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 142 -m hl --hl-eq 255 -j ACCEPT			# Inverse ND Advertisement
		# allow cryptographic Neighbour Dicovery messages	
		#$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 148 -m hl --hl-eq 255 -j ACCEPT			# certificate path Solic
		#$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 149 -m hl --hl-eq 255 -j ACCEPT			# certificate path Advert
		# allow Multicast Router Advertisement, Solicitation and Termination messages from link-local addresses only 
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 151 -s fe80::/10 -m hl --hl-eq 1 -j ACCEPT
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 152 -s fe80::/10 -m hl --hl-eq 1 -j ACCEPT
		$SBIN/ip6tables -A INPUT -p icmpv6 --icmpv6-type 153 -s fe80::/10 -m hl --hl-eq 1 -j ACCEPT
		#$SBIN/ip6tables -A INPUT -p icmpv6 -m limit --limit 30/min -j LOG --log-prefix "ICMPv6 DROP " --log-tcp-options --log-ip-options
		$SBIN/ip6tables -A INPUT -p icmpv6 -j DROP
		$SBIN/ip6tables -A INPUT -i lo -j ACCEPT
		$SBIN/ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
		# block Benchmarking, Orchid and Documentation addresses, https://www.ripe.net/ipv6-address-types
		$SBIN/ip6tables -A INPUT -s 2001:0002::/48 -j DROP
		$SBIN/ip6tables -A INPUT -s 2001:0010::/28 -j DROP
		$SBIN/ip6tables -A INPUT -s 2001:db8::/32 -j DROP
		# on dual stack systems, block tunnel prefixes to avoid automatic tunnel set up via router advertisement messages (hackers)
		$SBIN/ip6tables -A INPUT -s 2002::/16 -j DROP												# 6to4 tunneling
		$SBIN/ip6tables -A INPUT -s 2001:0000::/32 -j DROP											# Teredo server using UDP#3544
		$SBIN/ip6tables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 22 -j ACCEPT
		# allow hosts to make DNS-queries to this DNS-sever (UDP#53)
		if [ "$RADVD" == "1" ] ; then
			$SBIN/ip6tables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 53 -j ACCEPT
			$SBIN/ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -m udp --dport 53 -j ACCEPT
		fi
		# allow Virtual Machines connected to bridge virbr0 to resolve URLs (DNS #53) and get an IP-addr from host (DHCPv6-server #547)
		if [ "$VIRBR0" == "1" ] && [ "$QEMU" != "1" ] && [ `$BIN/ps -ef | $BIN/grep -c libvirtd` -lt 2 ] ; then
			$SBIN/ip6tables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp $BR0_INT --dport 22 -j ACCEPT
			$SBIN/ip6tables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp $BR0_INT --dport 53 -j ACCEPT
			$SBIN/ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -m udp $BR0_INT --dport 53 -j ACCEPT
			$SBIN/ip6tables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp $LAN_INT --dport 53 -j ACCEPT
			$SBIN/ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -m udp $LAN_INT --dport 53 -j ACCEPT
			# accept DHCPv6-server (UDP#547) traffic, remove next 2 lines for stateless autoconfiguration or statically configured machines
			$SBIN/ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -m udp $BR0_INT --dport 547 -j ACCEPT
			$SBIN/ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -m udp $LAN_INT --dport 547 -j ACCEPT
			# check and if not, activate IPv6 forwarding
			# cat /proc/sys/net/ipv6/conf/default/forwarding; cat /proc/sys/net/ipv6/conf/all/forwarding
			IP6FWD=0
			# fedora 18- IPv6 forwarding configured in /etc/sysctl.conf
			if [ `$BIN/grep -Eci "^net.ipv6.conf.all.forwarding" /etc/sysctl.conf` -ge 1 ] ; then
				$BIN/sed -i 's/^net.ipv6.conf.all.forwarding.*/net.ipv6.conf.all.forwarding = 1/' /etc/sysctl.conf
				IP6FWD=1
			fi
			# fedora 19+ IPv6 forwarding configured in /usr/lib/sysctl.d/* or in /etc/sysctl.d/*.conf
			for i in "`$BIN/ls /usr/lib/sysctl.d`" ; do
				if [ `$BIN/grep -Eci "^net.ipv6.conf.all.forwarding" $i` -ge 1 ] ; then
					$BIN/sed -i 's/^net.ipv6.conf.all.forwarding.*/net.ipv6.conf.all.forwarding = 1/' $i
					IP6FWD=1
				fi
			done
			for i in "`$BIN/ls /etc/sysctl.d`" ; do
				if [ `$BIN/grep -Eci "^net.ipv6.conf.all.forwarding" $i` -ge 1 ] ; then
					$BIN/sed -i 's/^net.ipv6.conf.all.forwarding.*/net.ipv6.conf.all.forwarding = 1/' $i
					IP6FWD=1
				fi
			done
			if [ $IP6FWD -ne 1]; then
				if [ $fcVER -lt 19 ]; then
					$BIN/echo -e "net.ipv6.conf.all.forwarding = 1 " >> /etc/sysctl.conf
				else
					$BIN/echo -e "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.d/51-forwarding.conf		
				fi
			fi
			BR0_INT="virbr0"
			$SBIN/ip6tables -A FORWARD -o $BR0_INT -j ACCEPT
			$SBIN/ip6tables -A FORWARD -i $BR0_INT -j ACCEPT
		fi
		if [ "$LAN_INT" != "" ]; then
			# allow incoming http(s) from wired LAN interface only
			$SBIN/ip6tables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp $LAN_INT -m multiport --dports 80,443 -j ACCEPT
		fi
		# accept DHCPv6-client (UDP#546) traffic, remove next line for stateless autoconfiguration or statically configured machines
		$SBIN/ip6tables -A INPUT -p udp -d fe80::/64 -m conntrack --ctstate NEW -m udp --dport 546 -j ACCEPT
		# accept DHCPv6-server (UDP#547) traffic i.e. this machine is a DHCPv6-server
		if [ "$RADVD" == "1" ] ; then
			$SBIN/ip6tables -A INPUT -p udp -s fe80::/64 -m conntrack --ctstate NEW -m udp --dport 547 -j ACCEPT
		fi
		$SBIN/ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -m udp --dport 1194 -j ACCEPT
		# when using avahi service, accept mDNS (multicast DNS requests) for destination IPv6 addr ff02::fb/128
		#$SBIN/ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -m udp --dport 5353 -d ff02::fb -j ACCEPT
		#$SBIN/ip6tables -A INPUT -m limit --limit 1/second --limit-burst 10 -j LOG --log-prefix "IPv6 DROP " --log-tcp-options --log-ip-options
		$SBIN/ip6tables -A INPUT -j REJECT --reject-with icmp6-adm-prohibited
		$SBIN/ip6tables -A FORWARD -m rt --rt-type 0 --rt-segsleft 0 -j DROP
		$SBIN/ip6tables -A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
		$SBIN/ip6tables -A OUTPUT -m rt --rt-type 0 --rt-segsleft 0 -j DROP
		$SBIN/ip6tables -A OUTPUT -m conntrack --ctstate INVALID -j DROP
		if [ "$PARANOID" == "1" ] ; then
			$SBIN/ip6tables -P OUTPUT DROP
			$SBIN/ip6tables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -d ::1 ! -o lo -j DROP
			$SBIN/ip6tables -A OUTPUT -d ::1 -o lo -j ACCEPT
			# accept all outgoing ICMPv6 messages might be too much - needs some tuning
			$SBIN/ip6tables -A OUTPUT -p ipv6-icmp -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 22 -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 25 -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 53 -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -p udp -m conntrack --ctstate NEW --dport 53 -j ACCEPT
			# DHCPv4 traffic (#67 or #68) should not be allowed as IPv6 uses #547 and #546 (see below)
			#$SBIN/ip6tables -A OUTPUT -p udp -m conntrack --ctstate NEW -m multiport --dports 67,68 -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -p tcp -m conntrack --ctstate NEW -m multiport --dports 80,443 -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -p udp -m conntrack --ctstate NEW --dport 123 -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -p tcp -m conntrack --ctstate NEW -m multiport --dports 110,995 -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -p tcp -m conntrack --ctstate NEW -m multiport --dports 143,993 -j ACCEPT
			# accept DHCPv6-server (UDP#547) traffic, remove next line for stateless autoconfiguration or statically configured machines
			$SBIN/ip6tables -A OUTPUT -p udp -m conntrack --ctstate NEW --dport 547 -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 587 -j ACCEPT
			$SBIN/ip6tables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 1194 -j ACCEPT
			if [ "$XSANE" == "1" ] ; then
				$SBIN/ip6tables -A OUTPUT -p tcp -m conntrack --ctstate NEW --dport 6566 -j ACCEPT
			fi
			$SBIN/ip6tables -A OUTPUT -p tcp -m conntrack --ctstate NEW -m multiport --dports 161,631,9100 -j ACCEPT
		fi
		$SBIN/ip6tables-save > /etc/sysconfig/ip6tables
		$SBIN/ip6tables -nvL
		#$BIN/chown root.root /etc/sysconfig/iptables
		$BIN/chcon -u system_u -t system_conf_t /etc/sysconfig/iptables
		#$BIN/chown root.root /etc/sysconfig/ip6tables
		$BIN/chcon -u system_u -t system_conf_t /etc/sysconfig/ip6tables
		$BIN/ls -lZ /etc/sysconfig/ip* 2>/dev/null
		#	-rw-------. 1 root root system_u:object_r:system_conf_t:s0 1850 Dec 19 18:06 /etc/sysconfig/ip6tables
		#	-rw-------. 1 root root system_u:object_r:system_conf_t:s0 1753 Dec  1  2014 /etc/sysconfig/ip6tables-config
		#	-rw-------. 1 root root system_u:object_r:system_conf_t:s0 1867 Dec 19 18:07 /etc/sysconfig/iptables
		#	-rw-------. 1 root root system_u:object_r:system_conf_t:s0 1740 Dec  1  2014 /etc/sysconfig/iptables-config
		$BIN/ls -lZ /var/lock/subsys/ip* 2>/dev/null
		#	-rw-r--r--. root root system_u:object_r:var_lock_t:s0  /var/lock/subsys/ip6tables
		#	-rw-r--r--. root root system_u:object_r:var_lock_t:s0  /var/lock/subsys/iptables
	fi
fi

if [ "$_JAVA" == "1" ] ; then
	$BIN/echo "Oracle Java will be installed and old versions removed"
	if [ `$BIN/rpm -q firefox|$BIN/sed -e "s/firefox-//g" -e "s/\..*//g"` -ge 52 ] ; then 
		# https://support.mozilla.org/en-US/kb/use-java-plugin-to-view-interactive-content
		# https://www.java.com/nl/download/help/firefox_java.xml
		# https://fedoramagazine.org/firefox-npapi-plugins-fedora/ 				-> how to bypass Java block in Firefox-52
		# http://www.omgubuntu.co.uk/2017/03/force-enable-firefox-52-npapi-support
		$BIN/echo "remember: from Firefox-52 onwards, NPAPI-plugins are no longer supported (Java will not run in Firefox)!"
	fi
	if [ "$DEBUG" == "0" ]; then 
		# http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
		# https://www.if-not-true-then-false.com/2014/install-oracle-java-8-on-fedora-centos-rhel/
		$BIN/cp /var/lib/alternatives/java /root/java.alternatives.`$BIN/date "+%Y-%M-%d"` 2>/dev/null
		$BIN/cp /var/lib/alternatives/javaws /root/javaws.alternatives.`$BIN/date "+%Y-%M-%d"` 2>/dev/null
		$BIN/cp /var/lib/alternatives/javac /root/javac.alternatives.`$BIN/date "+%Y-%M-%d"` 2>/dev/null
		$BIN/cp /var/lib/alternatives/jar /root/jar.alternatives.`$BIN/date "+%Y-%M-%d"` 2>/dev/null
		$BIN/cp /var/lib/alternatives/libjavaplugin.so /root/libjavaplugin.so.alternatives.`$BIN/date "+%Y-%M-%d"` 2>/dev/null
		$BIN/cp /var/lib/alternatives/libjavaplugin.so.x86_64 /root/libjavaplugin.so.x86_64.alternatives.`$BIN/date "+%Y-%M-%d"` 2>/dev/null
		# for i686 or x86_64 architecture and ALL jre/jdk-versions: remove any installed old JRE or JDK version
		if [ `$BIN/rpm -qa | $BIN/grep -Eic 'jre1|jdk1'` -ge 1 ] ; then
			# remove all installed JAVA packages before removing symlinks
			F_ARRAY=(`rpm -qa | $BIN/grep -Ei 'jre1|jdk1'`)
			for i in "${F_ARRAY[@]}" ; do
				$BIN/$PKG -y remove $i
			done
			# usage: alternatives --remove <name> <path>
			$SBIN/alternatives --remove java /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/bin/java 2&>/dev/null
			$SBIN/alternatives --remove javaws /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/bin/javaws 2&>/dev/null
			$SBIN/alternatives --remove java /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/bin/java 2&>/dev/null
			$SBIN/alternatives --remove javaws /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/bin/javaws 2&>/dev/null
			$SBIN/alternatives --remove javac /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/bin/javac 2&>/dev/null
			$SBIN/alternatives --remove jar /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/bin/jar 2&>/dev/null
			# remove previous Firefox symbolic links to java
			if [ `$BIN/uname -p` == "i686" ] ; then
				$BIN/echo "old i686 libjavaplugin.{so,so.x86_64} symbolic links will be removed"
				F1_ARRAY=(`$SBIN/alternatives --display libjavaplugin.so|grep -i '^/usr/java/jre1'|awk '{print $1}'`)
				for i in "${F1_ARRAY[@]}" ; do
					echo removing $i symlink
					$SBIN/alternatives --remove libjavaplugin.so $i #2&>/dev/null
				done
				F1_ARRAY=(`$SBIN/alternatives --display libjavaplugin.so.x86_64|grep -i '^/usr/java/jre1'|awk '{print $1}'`)
				for i in "${F1_ARRAY[@]}" ; do
					echo removing $i symlink
					$SBIN/alternatives --remove libjavaplugin.so.x86_64 $i #2&>/dev/null/
				done
				F2_ARRAY=(`$SBIN/alternatives --display libjavaplugin.so|grep -i '^/usr/java/jdk1'|awk '{print $1}'`)
				for i in "${F2_ARRAY[@]}" ; do
					echo removing $i symlink
					$SBIN/alternatives --remove libjavaplugin.so $i #2&>/dev/null
				done
				F2_ARRAY=(`$SBIN/alternatives --display libjavaplugin.so.x86_64|grep -i '^/usr/java/jdk1'|awk '{print $1}'`)
				for i in "${F2_ARRAY[@]}" ; do
					echo removing $i symlink
					$SBIN/alternatives --remove libjavaplugin.so.x86_64 $i #2&>/dev/null/
				done
#				$SBIN/alternatives --remove libjavaplugin.so /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/lib/i386/libnpjp2.so 2&>/dev/null
#				$SBIN/alternatives --remove libjavaplugin.so /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/lib/i386/libnpjp2.so 2&>/dev/null
			fi
			if [ `$BIN/uname -p` == "x86_64" ] ; then
				$BIN/echo "old x86_64 libjavaplugin.{so,so.x86_64} symbolic links will be removed"
				F3_ARRAY=(`$SBIN/alternatives --display libjavaplugin.so|grep -i '^/usr/java/jre1'|awk '{print $1}'`)
				for i in "${F3_ARRAY[@]}" ; do
					echo removing $i symlink
					$SBIN/alternatives --remove libjavaplugin.so $i #2&>/dev/null
				done
				F3_ARRAY=(`$SBIN/alternatives --display libjavaplugin.so.x86_64|grep -i '^/usr/java/jre1'|awk '{print $1}'`)
				for i in "${F3_ARRAY[@]}" ; do
					echo removing $i symlink
					$SBIN/alternatives --remove libjavaplugin.so.x86_64 $i #2&>/dev/null/
				done
				F4_ARRAY=(`$SBIN/alternatives --display libjavaplugin.so|grep -i '^/usr/java/jdk1'|awk '{print $1}'`)
				for i in "${F4_ARRAY[@]}" ; do
					echo removing $i symlink
					$SBIN/alternatives --remove libjavaplugin.so $i #2&>/dev/null
				done
				F4_ARRAY=(`$SBIN/alternatives --display libjavaplugin.so.x86_64|grep -i '^/usr/java/jdk1'|awk '{print $1}'`)
				for i in "${F4_ARRAY[@]}" ; do
					echo removing $i symlink
					$SBIN/alternatives --remove libjavaplugin.so.x86_64 $i #2&>/dev/null
				done
#				$SBIN/alternatives --remove libjavaplugin.so /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/lib/amd64/libnpjp2.so 2&>/dev/null
#				$SBIN/alternatives --remove libjavaplugin.so.x86_64 /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/lib/amd64/libnpjp2.so 2&>/dev/null/
#				$SBIN/alternatives --remove libjavaplugin.so /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/lib/amd64/libnpjp2.so 2&>/dev/null
#				$SBIN/alternatives --remove libjavaplugin.so.x86_64 /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/lib/amd64/libnpjp2.so 2&>/dev/
			fi
		fi
		# for ALL jre/jdk-versions: remove symlink created by Java install and make a new Firefox symlink to alternatives switch
		if [ `$BIN/uname -p` == "i686" ] ; then
			if [ "${JDK_686}" != "no name" ] ; then
				# with Oracle JDK, also install openJDK
				$BIN/$PKG -y install java-*-openjdk-devel
				$BIN/$PKG -y install ${JDK_686}
				# usage: alternatives --install <link> <name> <path> <priority>
				$SBIN/alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so libjavaplugin.so /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/lib/i386/libnpjp2.so 2999999
				# next 2 lines correct Oracle Java install with 18066 priority, this is lower than openJDK priority
				$SBIN/alternatives --remove java /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/bin/java 2&>/dev/null
				$SBIN/alternatives --install /usr/bin/java java /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/bin/java 2999999
				$SBIN/alternatives --install /usr/bin/javaws javaws /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/bin/javaws 2999999
				$SBIN/alternatives --install /usr/bin/javac javac /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/bin/javac 2999999
				# /usr/bin/jar is symlink to /etc/alternatives/jar whish is symlink to /usr/java/jdk1.8.0_131/bin/jar
				#$SBIN/alternatives --install /usr/bin/jar jar /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/bin/jar 2999999
			elif [ "${JRE_686}" != "no name" ] ; then
				$BIN/$PKG -y install ${JRE_686}
				# usage: alternatives --install <link> <name> <path> <priority>
				$SBIN/alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so libjavaplugin.so /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/lib/i386/libnpjp2.so 2999999
				# next 2 lines correct Oracle Java install with 18066 priority, this is lower than openJDK priority
				$SBIN/alternatives --remove java /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/bin/java 2&>/dev/null
				$SBIN/alternatives --install /usr/bin/java java /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/bin/java 2999999
				$SBIN/alternatives --install /usr/bin/javaws javaws /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/bin/javaws 2999999
			fi
			# next line removes incorrect empty (with //) alternatives entry
			$SBIN/alternatives --remove libjavaplugin.so /usr/java//jre/lib/i386/libnpjp2.so 2&>/dev/null
		fi
		if [ `$BIN/uname -p` == "x86_64" ] ; then
			if [ "${JDK_x64}" != "no name" ] ; then
				# with Oracle JDK, also install openJDK
				$BIN/$PKG -y install java-*-openjdk-devel
				$BIN/$PKG -y install ${JDK_x64}
				# if the next symbolic link is incorrrect, the alternatives will be configured with the correct jave version but but java in firefox will not work
				$SBIN/alternatives --install /usr/lib64/mozilla/plugins/libjavaplugin.so libjavaplugin.so.x86_64 /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/lib/amd64/libnpjp2.so 2999999
				# next 2 lines correct Oracle Java install with 18066 priority, this is lower than openJDK priority
				$SBIN/alternatives --remove java /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/bin/java 2&>/dev/null
				$SBIN/alternatives --install /usr/bin/java java /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/bin/java 2999999
				$SBIN/alternatives --install /usr/bin/javaws javaws /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/bin/javaws 2999999
				$SBIN/alternatives --install /usr/bin/javac javac /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/bin/javac 2999999
				# /usr/bin/jar is symlink to /etc/alternatives/jar whish is symlink to /usr/java/jdk1.8.0_131/bin/jar
				#$SBIN/alternatives --install /usr/bin/jar jar /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/bin/jar 2999999
			elif [ "${JRE_x64}" != "no name" ] ; then
				$BIN/$PKG -y install ${JRE_x64}
				# if the next symbolic link is incorrrect, the alternatives will be configured with the correct jave version but but java in firefox will not work
				$SBIN/alternatives --install /usr/lib64/mozilla/plugins/libjavaplugin.so libjavaplugin.so.x86_64 /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/lib/amd64/libnpjp2.so 2999999
				# next 2 lines correct Oracle Java install with 18066 priority, this is lower than openJDK priority
				$SBIN/alternatives --remove java /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/bin/java 2&>/dev/null
				$SBIN/alternatives --install /usr/bin/java java /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/bin/java 2999999
				$SBIN/alternatives --install /usr/bin/javaws javaws /usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/jre/bin/javaws 2999999
			fi
			# next line removes incorrect empty (with //) alternatives entry
			$SBIN/alternatives --remove libjavaplugin.so.x86_64 /usr/java//jre/lib/amd64/libnpjp2.so 2&>/dev/null
		fi
		# next 2 lines removes incorrect empty alternatives entry
		$SBIN/alternatives --remove java /usr/java//jre/bin/java 2&>/dev/null
		$SBIN/alternatives --remove javaws /usr/java//jre/bin/javaws 2&>/dev/null
		$SBIN/alternatives --remove javac /usr/java//bin/javac 2&>/dev/null
#		$SBIN/alternatives --remove jar /usr/java//bin/jar 2&>/dev/null
		if [ `$BIN/uname -p` == "i686" ] ; then
			$SBIN/alternatives --auto libjavaplugin.so
#			$SBIN/alternatives --display libjavaplugin.so
		fi
		if [ `$BIN/uname -p` == "x86_64" ] ; then
			$SBIN/alternatives --auto libjavaplugin.so.x86_64
#			$SBIN/alternatives --display libjavaplugin.so.x86_64
		fi
		$SBIN/alternatives --auto java
#		$SBIN/alternatives --display java
		if [ "${_JDK_686}" == "OK" ] || [ "${_JDK_x64}" == "OK" ] ; then
			$SBIN/alternatives --auto javac
#			$SBIN/alternatives --display javac
			$SBIN/alternatives --auto jar
#			$SBIN/alternatives --display jar
		fi
		# for i686 and x86_64 only and ALL jre/jdk-versions: add java to search path (needed for some development applications)
		$BIN/echo -e "create /etc/profile.d/java.sh"
		if [ "${_JDK_686}" == "OK" ] || [ "${_JDK_x64}" == "OK" ] ; then
			$BIN/echo -e "export JAVA_HOME=\"/usr/java/`$BIN/ls /usr/java/ | $BIN/grep jdk1`/bin\"" > /etc/profile.d/java.sh
			$BIN/echo -e "export JAVA_PATH=\"\$JAVA_HOME\"" >> /etc/profile.d/java.sh
			$BIN/echo -e "export PATH=\"\$PATH:\$JAVA_HOME\"" >>  /etc/profile.d/java.sh
			$BIN/cat /etc/profile.d/java.sh
		elif [ "${_JRE_686}" == "OK" ] || [ "${_JRE_x64}"  == "OK" ] ; then
			$BIN/echo -e "export JAVA_HOME=\"/usr/java/`$BIN/ls /usr/java/ | $BIN/grep jre1`/bin\"" > /etc/profile.d/java.sh
			$BIN/echo -e "export JAVA_PATH=\"\$JAVA_HOME\"" >> /etc/profile.d/java.sh
			$BIN/echo -e "export PATH=\"\$PATH:\$JAVA_HOME\"" >>  /etc/profile.d/java.sh
			$BIN/cat /etc/profile.d/java.sh
		fi
		# ignore errors '2&>/dev/null' when archi != i686 or x86_64 and when _Jxx_xxx != OK
		$BIN/chmod 0644 /etc/profile.d/java.sh 2&>/dev/null
		$BIN/chown root.root /etc/profile.d/java.sh 2&>/dev/null
		$BIN/chcon -u system_u -t bin_t /etc/profile.d/java.sh 2&>/dev/null
		source /etc/profile.d/java.sh 2&>/dev/null
	fi
fi

if [ "$TWO" == "1" ] ; then
	$BIN/echo "vlc with libdvdcss will be installed, totem, rhythmbox and parole removed"
	if [ "$DEBUG" == "0" ]; then 
		if [ $fcVER -ge 26 ]; then
			$BIN/$PKG -y remove totem rhythmbox parole exaile 2>/dev/null
		else
			# also for Fedora 14, not only Fedora > 26
			$BIN/$PKG -y remove totem rhythmbox parole 2>/dev/null
		fi
		$BIN/$PKG -y install vlc libdv-tools libcdaudio libdvdnav libdc1394 fftw2 madplay mjpegtools faac faad2 libdvdcss --enablerepo=`[ $fcVER -gt 20 ] && echo remi || echo livna`
	fi
	$BIN/echo "mixxx and gstreamer with plugins will be installed"
	if [ "$DEBUG" == "0" ]; then
		$BIN/$PKG -y install mixxx gstreamer gstreamer-plugins-bad gstreamer-plugins-bad-free gstreamer-ffmpeg gstreamer-plugins-bad-free-extras gstreamer-plugins-bad-nonfree gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-ugly gstreamer-tools
	fi
	$BIN/echo "k3b, grip and audacity will be installed, xfburn and brasero removed"
	if [ "$DEBUG" == "0" ]; then
		$BIN/$PKG -y remove xfburn brasero 2>/dev/null
		$BIN/$PKG -y install k3b k3b-extras-freeworld grip transcode cdda2wav cdparanoia id3lib lame audacity
		# correct k3b permissions unfortunately removed from k3b at compile time by RedHat
#		if [ $fcVER -ge 20 ]; then
			# make symlink /usr/bin/cdrecord -> /usr/bin/wodim execute as root, security breach !, in case of problems, add /usr/bin/{growiso,cdrdoa} as well
			$BIN/chmod u+s $BIN/wodim
			# add logged on user to cdrom group
			$SBIN/usermod -aG cdrom `$BIN/logname`
			$BIN/wodim  --devices
#		fi
	fi
	if [ "$DEBUG" == "1" ] && [ "$LABEL" != "1" ] ; then $BIN/echo "glabels and kcover will be installed if -l option is also set" ; fi
	if [ "$LABEL" == "1" ] ; then
		$BIN/echo "glabels and kcover will be installed"
		if [ "$DEBUG" == "0" ]; then
			$BIN/$PKG -y install glabels kover
		fi
	fi
	$BIN/echo "gimp, digikam and cheese will be installed (needed for xsane)"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install gimp digikam cheese
	fi
	if [ "$DEBUG" == "1" ] && [ "$VIDEO" != "1" ] ; then $BIN/echo "kdenlive, dvdstyler and recordmydesktop will be installed will be installed if -k option is also set" ; fi
	if [ "$VIDEO" == "1" ] ; then
		$BIN/echo "kdenlive, dvdstyler and recordmydesktop will be installed"
		if [ "$DEBUG" == "0" ]; then 
			if [ $fcVER -eq 28 ]; then
				$BIN/$PKG -y install --releasever=27 recordmydesktop
				$BIN/$PKG -y upgrade jack-audio-connection-kit jack-audio-connection-kit-e*
			fi
			$BIN/$PKG -y install kdenlive mlt dvdauthor dvgrab dvdstyler `[ $fcVER -lt 28 ] && $BIN/echo recordmydesktop`
			if [ $fcVER -eq 14 ]; then
				# correct kdenlive "MLT's SDL module not found" fatal error
				$BIN/echo -e "[version]\nversion=0.8" > /home/`$BIN/logname`/.kde/share/config/kdenliverc
				$BIN/chown `$BIN/logname`:`$BIN/logname` /home/`$BIN/logname`/.kde/share/config/kdenliverc
			fi
		fi
	fi
	$BIN/echo "thunderbird, calibre, evince, xchm and pdfmod will be installed, claws-mail and evolution removed"
	if [ "$DEBUG" == "0" ]; then 
		# https://wiki.gnome.org/Apps/Evince 					-> document viewer
		# http://community.linuxmint.com/software/view/calibre 	-> e-book solution
		# https://www.digitalocean.com/community/tutorials/how-to-create-a-calibre-ebook-server-on-ubuntu-14-04
		$BIN/$PKG -y remove evolution claws-mail claws-mail-plugins-pdf-viewer claws-mail-plugins-fancy claws-mail-plugins-smime 2>/dev/null
#		$BIN/$PKG -y install `[ $fcVER -lt 25 ] && $BIN/echo pdfedit` evince calibre xchm thunderbird `[ $fcVER -lt 19 ] && $BIN/echo gnochm`
		$BIN/$PKG -y install inkscape pdfmod pdf-tools evince calibre thunderbird `[ $fcVER -lt 19 ] && $BIN/echo gnochm || $BIN/echo xchm`
		# correct double ';;' bug 'Error in file "/usr/share/applications/evince.desktop": "" is an invalid MIME type ("" does not contain a subtype)'
		# https://bugzilla.redhat.com/show_bug.cgi?id=1471474
		$BIN/sed -i '/^MimeType/s/;;/;/g' /usr/share/applications/evince.desktop
	fi
	if [ "$DEBUG" == "1" ] && [ "$MRI" != "1" ] ; then $BIN/echo "aeskulap (MRI viewer) will be installed if -mri option is also set" ; fi
	if [ "$MRI" == "1" ] ; then
		$BIN/echo "aeskulap (MRI viewer) will be installed"
		if [ "$DEBUG" == "0" ]; then 
			$BIN/$PKG -y install aeskulap
		fi
	fi
	if [ "$DEBUG" == "1" ] && [ "$AMULE" != "1" ] ; then $BIN/echo "aMule will be installed if -a option is also set" ; fi
	if [ "$AMULE" == "1" ] ; then
		$BIN/echo "amule will be installed"
		if [ "$DEBUG" == "0" ]; then 
			$BIN/$PKG -y install amule
			# create symbolic link on Desktop for Incoming directory of hidden aMule directory
			$BIN/ln -s /home/`$BIN/logname`/.aMule/Incoming /home/`$BIN/logname`/Desktop/aMule
		fi
	fi
	if [ "$DEBUG" == "1" ] && [ "$GAMES" != "1" ] ; then $BIN/echo "some games will be installed if -g option is also set" ; fi
	if [ "$GAMES" == "1" ] ; then
		$BIN/echo "some games will be installed"
		if [ "$DEBUG" == "0" ]; then 
			# install kernel-headers-4.0.4-301.fc22.i686 (default installed kernel-version from MATE live DVD) required for gnome games first
			$BIN/$PKG -y install kernel-headers-`$BIN/uname -r`
			$BIN/$PKG -y install frozen-bubble supertux `[ $fcVER -lt 20 ] && $BIN/echo "gnome-games gnome-games-sudoku kdegames-minimal" || $BIN/echo "gnome-mines gnome-mahjongg gnome-sudoku four-in-a-row kpat"`
		#	$BIN/$PKG -y install joystick-support
		fi
	fi
	if [ "$DEBUG" == "1" ] && [ "$SKYPE" != "1" ] ; then $BIN/echo "Skype will be installed if -s option is also set" ; fi
#	if [ "$SKYPE" == "1" ] ; then
	if [ "$SKYPE" == "1" ] && [ `$BIN/uname -p` == "x86_64" ] ; then
#		$BIN/echo "skype and needed i586 libraries will be installed"
		$BIN/echo "skype-for-linux (64-bit) will be installed"
		if [ "$DEBUG" == "0" ] ; then 
#			$BIN/$PKG -y `[ $fcVER -lt 20 ] && $BIN/echo "localinstall --nogpgcheck" || $BIN/echo install` skype-4.3.0.37-fedora.i586.rpm
			$BIN/$PKG -y `[ $fcVER -lt 20 ] && $BIN/echo "localinstall --nogpgcheck" || $BIN/echo install` skypeforlinux-64.rpm
		fi
	fi
	if [ "$DEBUG" == "1" ] && [ "$SPOTIFY" != "1" ] ; then $BIN/echo "Spotify-client (music streaming service) will be installed if -sp option is also set" ; fi
	if [ "$SPOTIFY" == "1" ] ; then
		$BIN/echo "Spotify-client and .repo will be installed"
		if [ "$DEBUG" == "0" ]; then
			$BIN/wget http://negativo17.org/repos/fedora-spotify.repo -O /etc/yum.repos.d/fedora-spotify.repo
			$BIN/$PKG -y install spotify-client
		fi
	fi
	# last 2 fedora releases supported, but obsolete: https://negativo17.org/steam/
	# https://gist.github.com/mattbell87/137f49baa3b8e2ad497758c9dd84bb19
	# https://linuxconfig.org/installing-steam-on-fedora-25-linux
	# https://wiki.archlinux.org/index.php/Steam/Troubleshooting
	if [ "$DEBUG" == "1" ] && [ "$STEAM" != "1" ] ; then $BIN/echo "Steam engine (Gaming) will be installed if -st option is also set" ; fi
	if [ "$STEAM" == "1" ] ; then
		$BIN/echo "Steam engine (32-bit) will be installed"
		if [ "$DEBUG" == "0" ]; then
			# make sure of is that the 32bit version of your graphics driver is installed on your system
			# Intel:
#			$BIN/$PKG -y install xorg-x11-drv-intel mesa-libGL.i686 mesa-dri-drivers.i686
			# AMD:
#			$BIN/$PKG -y install xorg-x11-drv-amdgpu mesa-libGL.i686 mesa-dri-drivers.i686
			# open source NVidia:
#			$BIN/$PKG -y install xorg-x11-drv-nouveau mesa-libGL.i686 mesa-dri-drivers.i686
			# proprietary NVidia:
#			$BIN/$PKG -y install xorg-x11-drv-nvidia-libs.i686
			# steam.i686 is available for fc20+ from rpmfusion.org/nonfree repository so, no need to use negativo17.org repo
			# https://negativo17.org/repos/steam/ to find out the supported fedora versions
#			$BIN/wget http://negativo17.org/repos/fedora-steam.repo -O /etc/yum.repos.d/fedora-steam.repo
			$BIN/$PKG -y install steam
			# install S3 texture compression library, 32-bit version is a dependency of steam and already installed
#			$BIN/$PKG -y install libtxc_dxtn
			# enable 'Big Picture' mode
#			setsebool -P allow_execheap 1
		fi
	fi
fi

if [ "$GIT" == "1" ] ; then
	$BIN/echo "git and git-gui will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install git git-gui git-extras
	fi
fi
# eclipse v4.6/v4.7 requires Java JDK 8+, v4.5 requires Java JDK 7+
# https://wiki.eclipse.org/Eclipse/Installation 		
#											-> Java IDE: fc22 eclipse-4.5 (Mars), fc23/24 v4.6 (Neon), fc26/27 v4.7 (Oxigen)
# https://www.eclipse.org/downloads/index.php?show_instructions=TRUE 	-> how to manualy install eclipse with new installer
# available eclipse plugins: dnf search eclipse
if [ "$ECLIPSE" -gt "0" ] ; then
	case "${ECLIPSE}" in
	  "1")
 		$BIN/echo "eclipse with Java, C/C++ and PHP Development Tools as well as openjdk-devel will be installed"
		;;
	  "2")
		$BIN/echo "eclipse with Java Development Tools will be installed"
		;;
	  "3")
		$BIN/echo "eclipse with c++ Development Tools will be installed"
		;;
	  "4")
		$BIN/echo "eclipse with PHP Development Tools will be installed"
		;;
	  "5")
		$BIN/echo "eclipse with dutch, french and german language plugins will be installed"
		;;
	  *)
		# too high value found
		$BIN/echo -e "Error: illegal value '${ECLIPSE}' for ECLIPSE variable"
	esac
	if [ "$DEBUG" == "0" ]; then 
		jVER=0; jtVER=`rpm -qa | grep ^jdk`
		[ `echo $jtVER | grep -Ec "9\."` -eq 1 ] && jVER=9; [ `echo $jtVER | grep -Ec "8\."` -eq 1 ] && jVER=8; [ `echo $jtVER | grep -Ec "7\."` -eq 1 ] && jVER=7;
		if [ $fcVER -eq 22 ] && [ $jVER -eq 7 ] || [ $fcVER -ge 23 ] && [ $jVER -eq 8 ] ; then
			case "${ECLIPSE}" in
			  "1")
		 		#$BIN/echo "eclipse with Java, C/C++ and PHP Development Tools as well as openjdk-devel will be installed"
				if [ "$DEBUG" == "0" ]; then 
					$BIN/$PKG -y install eclipse eclipse-jdt eclipse-cdt eclipse-pdt
				fi
				;;
			  "2")
				#$BIN/echo "eclipse with Java Development Tools will be installed"
				if [ "$DEBUG" == "0" ]; then 
					$BIN/$PKG -y install eclipse eclipse-jdt
				fi
				;;
			  "3")
				#$BIN/echo "eclipse with c++ Development Tools will be installed"
				if [ "$DEBUG" == "0" ]; then 
					$BIN/$PKG -y install eclipse eclipse-cdt
				fi
				;;
			  "4")
				#$BIN/echo "eclipse with PHP Development Tools will be installed"
				if [ "$DEBUG" == "0" ]; then 
					$BIN/$PKG -y install eclipse eclipse-pdt
				fi
				;;
			  "5")
				#$BIN/echo "eclipse with dutch, french and german language plugins will be installed"
				if [ "$DEBUG" == "0" ]; then 
					$BIN/$PKG -y install eclipse-nls-nl eclipse-nls-fr eclipse-nls-de
				fi
				;;
			  *)
				# too high value found
				$BIN/echo -e "Error: illegal value '${ECLIPSE}' for ECLIPSE variable"
			esac
		else
			$BIN/echo "skipping eclipse installation: Fedora $fcVER Eclipse version not compatible JAVA version $jVER"
		fi
	fi
fi
if [ "$HPLIP" == "1" ] ; then
	$BIN/echo "HP printer and scanner drivers will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install hplip hplip-common
	fi
fi
if [ "$QEMU" == "1" ] ; then
	$BIN/echo "QEMU, libvirt, virt-manager and UEFI-firmware will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/wget https://www.kraxel.org/repos/firmware.repo -O /etc/yum.repos.d/kraxel-qemu-firmware.repo
		$BIN/$PKG -y install qemu-kvm qemu-img spice-server spice-vdagent socat edk2.git-ovmf-x64 virt-manager virt-viewer libvirt libvirt-python virt-install bridge-utils
	fi
fi
if [ "$OPENSTACK" == "1" ] ; then
	$BIN/echo "OpenStack RDO repository will be installed"
	if [ "$DEBUG" == "0" ]; then 
		STACK=0
		if [ ! -f rdo-release.rpm ] ; then
#			$BIN/wget https://www.rdoproject.org/repos/rdo-release.rpm
			STACK=1
		fi
		if [ `$BIN/rpm -K --nosignature rdo-release* 2>&1 | $BIN/grep -ic error` -gt 0 ] ; then
			$BIN/echo "rdo-release.rpm is not an RPM package, skipping installation"
		else
			# next installs centos7 openstack-newton.repo and centos7 rdo-qemu-ev.repo who conflicts with regular fedora.repo
			$BIN/$PKG -y `[ $fcVER -lt 20 ] && $BIN/echo "localinstall --nogpgcheck" || $BIN/echo install` rdo-release.rpm
			# install OpenStack from community RDO (RPM Distribution of OpenStack) repo
#			$BIN/$PKG -y install fedora-release-openstack-mitaka openstack-packstack
		fi
		# remove downloaded repository rpm's (all versions: rpm, rpm.1)
		if [ "$STACK" == "1" ] ; then $BIN/rm -f rdo-release.rpm* ; fi
	fi
fi
if [ "$WIRESHARK" == "1" ] ; then
	$BIN/echo "Wireshark will be installed"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install wireshark-gnome
	fi
fi
if [ "$REM_HELP" == "1" ] ; then
	$BIN/echo "x11vnc will be installed and remote-help.sh file created"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y install x11vnc
		$BIN/echo -e '#!/bin/bash\n/$BIN/x11vnc -connect trans-action.homelinux.net:5500' > /home/`$BIN/logname`/Desktop/remote-help.sh
		$BIN/chmod 0770 /home/`$BIN/logname`/Desktop/remote-help.sh
		$BIN/chown `$BIN/logname`:`$BIN/logname` /home/`$BIN/logname`/Desktop/remote-help.sh
	fi
fi

if [ "$EID_BEL" == "1" ] ; then
	$BIN/echo "Belgian eID middleware and GUI will be installed"
	if [ "$DEBUG" == "0" ]; then 
		# don't install if it is already installed !
		if [ `$BIN/rpm -qa | $BIN/grep -c eid-archive` -lt 1  ]; then
			# repo for Belgian eID application
			EIDBEL=0
			if [ ! -f eid-archive-fedora-2016-2.noarch.rpm ] ; then
				# we need to set user-agent or Belgian-eid site will serve corrupt RPM file
				$BIN/wget https://eid.belgium.be/sites/default/files/software/eid-archive-fedora-2016-2.noarch.rpm --header="User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:23.0) Gecko/20100101 Firefox/23.0"
				EIDBEL=1
			fi
			if [ `$BIN/rpm -K --nosignature eid-archive-fedora* 2>&1 | $BIN/grep -ic error` -gt 0 ] ; then
				$BIN/echo "eid-archive-fedora-20xx-x.noarch.rpm is not an RPM package, skipping installation"
			else
				$BIN/$PKG -y install `$BIN/ls eid-archive*`
				# upgrade eid-archive-fedora repo just in case a more resent version exists
				$BIN/$PKG -y upgrade `$BIN/ls eid-archive*` 2&>/dev/null
				# install Belgian eID software and generic cardreader driver
				$BIN/$PKG -y install eid-mw eid-viewer pcsc-lite
				# install Belgian eID plugin to firefox
				#wget https://addons.mozilla.org/firefox/downloads/file/166336/eid_belgie-1.0.18-fx.xpi
#				$BIN/echo -e "\nstart firefox and install eID plugin from https://addons.mozilla.org/firefox/downloads/latest/51744\n"
				# start pcscd to avoid first time: "no reader found" but, don't enable pcscd
				if [ $fcVER -ge 20 ]; then
					$BIN/systemctl start pcscd
				fi
			fi
			# remove downloaded repository rpm's (all versions: rpm, rpm.1)
			if [ "$EIDBEL" == "1" ] ; then $BIN/rm -f eid-archive-fedora-*.rpm* ; fi
		else
			$BIN/echo "Belgian eID repo already installed, skipping"
		fi
		# disable repo to avoid updates of eid-mw and eid-viewer because of resulting firefox problems
		$BIN/sed -i '/^enabled=/ s/=.*/=0/g' /etc/yum.repos.d/eid-archive.repo
		$BIN/echo "test browser configuration at http://www.test.eid.belgium.be/"
	fi
fi

# to easily see the output, this section should be the last section
if [ "$XSANE" == "1" ] ; then
	$BIN/echo "xsane will be configured for HP8270 scanner and connection to scanner-server checked"
	if [ "$DEBUG" == "0" ]; then 
		$BIN/$PKG -y remove simple-scan
		$BIN/$PKG -y install xsane xsane-gimp sane-backends libsane-hpaio sane-backends-drivers-scanners sane-backends-drivers-cameras
		$BIN/rpm -qa | $BIN/grep sane
		#	xsane-gimp-0.998-4.fc14.i686
		#	sane-backends-libs-1.0.22-5.fc14.i686
		#	sane-backends-drivers-cameras-1.0.22-5.fc14.i686
		#	sane-backends-drivers-scanners-1.0.22-5.fc14.i686	-> or local test will not work, neither will sane check for scanners on the network
		#	libsane-hpaio-3.11.10-5.fc14.i686
		#	sane-backends-1.0.22-5.fc14.i686
		#	xsane-0.998-4.fc14.i686
		#	xsane-common-0.998-4.fc14.i686
		if [ `$BIN/grep -Ec "/usr/local/lib" /etc/ld.so.conf` -lt 1 ] ; then
			$BIN/echo "/usr/local/lib" >> /etc/ld.so.conf
		fi
		# uncomment "net" and 'avision' lines in /etc/sane.d/dll.conf
		if [ `$BIN/grep -Ec "#net" /etc/sane.d/dll.conf` -eq 1 ] || [ `$BIN/grep -Ec "#avision" /etc/sane.d/dll.conf` -eq 1 ]; then
			$BIN/sed -i -e "s/^#net/net/" -e "s/^#avision/avision/" /etc/sane.d/dll.conf
		fi
		# add HP8270 scanner to /etc/sane.d/avision.conf or to hp.conf
		if [ `$BIN/grep -Ec "usb 0x03f0 0x3905" /etc/sane.d/avision.conf` -lt 1 ] && [ `$BIN/grep -Ec "usb 0x03f0 0x3905" /etc/sane.d/hp.conf` -lt 1 ] ; then
			$BIN/echo -e "usb 0x03f0 0x3905" >> /etc/sane.d/avision.conf
		fi
		# configure IP-address of scan-server in /etc/sane.d/net.conf
		if [ `$BIN/grep -Ec "192.168.1.11" /etc/sane.d/net.conf` -lt 1 ] ; then
			$BIN/echo -e "192.168.1.11" >> /etc/sane.d/net.conf
		fi
		#telnet 192.168.1.11 6566	-> ^], quit, to test if server (saned via xinetd) is listening on scanner port (TCP#6566)
		$BIN/scanimage -d test -T
		# make sure your network scanner is switched on before launching the next command !
		$BIN/scanimage -L
	fi
fi

# cups network printer
# menu System -> Administration -> Printing, click ADD, enter root pwd, click arrow before Networkprinter, click Find Networkprinter,
# fill as host 192.168.1.2 (address of HP_3800) in, click Search, select 'HP Linux Imaging and Printing (HPLIP)', click Next,
# Searching for drivers" will appear, click the tickbox before "Duplexer installed", click Next, click Apply, enter root pwd, click "Print test page"
# click OK, click OK

