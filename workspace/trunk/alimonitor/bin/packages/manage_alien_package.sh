#!/bin/bash

# Simple script to manage the installation and removal of alien packages based
# on the packages provided by the AliRoot BITS
#
# Command to install a package is
# packman define ApMon v2.2.9 ApMon_perl-2.2.9.tar.gz dependencies=VO_ALICE@ROOT::v5-15-06,VO_ALICE@GEANT3::v1-7 post_install=/alice/packages/AliRoot/post_install -vo -platform Linux-i686 -se ALICE::CERN::SE
#
# where post_install= similar path for AliRoot, ROOT, GEANT3
# and platform = source for APISCONFIG or like Linux-i686 for the others
#
# Command to uninstall a package is
#packman undefine ApMon v2.2.9 -vo
#

op=$1
pkg=$2
ver=$3
plf=$4
file=$5

ALIEN="/opt/alien/bin/alien login -u admin"

usage() {
	echo -e "Usage:\n\t$0 { install | undefine } <pkg_short_name> <pkg_version> <platform> [ <platform2> ... ]"
	echo -e "\t\tpkg_short_name is like AliRoot or ROOT or GEANT3"
	echo -e "\t\tpkg_version is like v5-15-06"
	echo -e "\t\tplatform is one of Linux-i686, Linux-SLC4-i686, Linux-x86_64, Linux-ia64, Darwin-powerpc or Darwin-i386"
	echo -e "\t$0 show_available"
	echo -e "\t\tdisplay a list of avaliable packages, compiled by the build systems"
	echo -e "\t$0 show_defined"
	echo -e "\t\tdisplay the list of defined packages, as AliEn knows"
	echo -e "\t$0 show_package_platforms <pkg_name> <pkg_version>"
	echo -e "\t\tdisplay the list of platforms for an installed package"
	echo -e "\t$0 show_package_dependencies <pkg_name> <pkg_version>"
	echo -e "\t\tdisplay the list of dependencies for an installed package"
	exit 1
	
}

# pkg_short_name, pkg_version, platform - already defined
# defines bit_server and pkg_line
load_pkg() {
	echo "Getting BitServers .."
	bit_server=`wget -O - http://alirootbuild3.cern.ch:8889/BitServers.notcached 2>/dev/null| grep $platform | awk -F \| '{print $3}' | tr -d [:space:]`
	if [ "$bit_server" == "" ] ; then
		return 1
	fi
	echo "Filtering package list from $bit_server .."
	pkg_line=`wget -O - $bit_server/tarballs/Packages 2>/dev/null | grep -E -e "\\s+$pkg_short_name\\s+$pkg_version\\s+"`
	if [ "$pkg_line" == "" ] ; then
		return 1
	fi
	echo "Package details: $pkg_line"
	return 0
}

# pkg_short_name, pkg_version, platform, bit_server, pkg_line - already defined
# fetches the package from bit_server and performs the package's installation
do_install() {
	pkg_file=`echo $pkg_line | awk '{print $1}'`
	pkg_fullname=`echo $pkg_line | awk '{print $5}'`
	pkg_deps=`echo $pkg_line | awk '{print $6}'`
	pkg_spool="/var/packages_spool"
	echo "Installing $bit_server/tarballs/$pkg_file .."
	echo "Full name: $pkg_fullname"
	echo "Dependencies: $pkg_deps"
	echo "Fetching package file ${pkg_spool}/${pkg_file} .."
	
	if [ ! -f "${pkg_spool}/${pkg_file}" ]; then
	    echo "File ${pkg_spool}/${pkg_file} does not exist inside spool directory. Please check that the archive is there"
	    return
	fi
	
#	wget -O $pkg_file $bit_server/tarballs/$pkg_file 2>/dev/null
#	if [ ! -r $pkg_file ] ; then
#		echo "Failed doing wget -O $pkg_file $bit_server/tarballs/$pkg_file"
#		return
#	fi
	# the post_install script
	if [ "$pkg_short_name" == "AliRoot" -o "$pkg_short_name" == "ROOT" -o "$pkg_short_name" == "GEANT3" -o "$pkg_short_name" == "GEANT4" -o "$pkg_short_name" == "boost" -o "$pkg_short_name" == "cgal" -o "$pkg_short_name" == "fastjet" -o "$pkg_short_name" == "tcmalloc" -o "$pkg_short_name" == "jemalloc" ] ; then
		post_install="post_install=/alice/packages/$pkg_short_name/post_install"
	fi
	# the platform
	if [ "$pkg_short_name" == "APISCONFIG" ] ; then
		myplatf="source"
	else
		myplatf=`echo $platform | sed -e 's/-SLC4//'`
	fi
	
	platf_opt="-platform $myplatf"
	
	# dependencies
	if [ "$pkg_deps" != "" ] ; then
		dependencies="dependencies=$pkg_deps"
	fi
	cmd="$ALIEN -exec packman define $pkg_short_name $pkg_version "${pkg_spool}/${pkg_file}" $dependencies $post_install -vo $platf_opt -se ALICE::CERN::EOS"
	echo "Running: $cmd"
	output=`$cmd 2>&1`
	
	alreadyinstalled=`echo "$output" | grep "already exists" | grep -v -E -e "Tag.*already exists"`
	
	if [ -z "$alreadyinstalled" ]; then
	    echo "$output"
	
	    echo "Registering file in torrent"
	    if [ -x "/var/packages/copyfile.sh" ]; then
		/var/packages/copyfile.sh "${pkg_spool}/${pkg_file}"
	    else
		echo "Error: /var/packages is not properly mounted on `hostname -f`"
	    fi
	
	    cmd="$ALIEN -exec addMirror /alice/packages/$pkg_short_name/$pkg_version/$myplatf no_se torrent://alitorrent.cern.ch/torrents/$pkg_file.torrent"
	    echo "Running torrent registration: $cmd"
	    $cmd
	else
	    echo "Skipping torrent registration because package is already defined"
	    echo "$alreadyinstalled"
	fi
	
	if [ -f "${pkg_spool}/${pkg_file}" ]; then
	    rm -f "${pkg_spool}/${pkg_file}"	
	fi
	
	if [ -z "$alreadyinstalled" ]; then
	    return 0
	else
	    return 1
	fi
}

do_multi_platform_install() {
	pkg_short_name=$1
	pkg_version=$2
	shift 2
	
	any_successful=0
	
	while [ $# -gt 0 ] ; do
		platform=$1
		echo "Loading package $pkg_short_name version $pkg_version for platform $platform .."
		load_pkg
		rez=$?
		if [ $rez -eq 0 ] ; then
			do_install
			
			if [ $? -eq 0 ]; then
			    any_successful=1
			fi
		else
			echo "Failed to load package for platform $platform"
		fi
		shift
	done
	
	if [ $any_successful -eq 1 ]; then
	    recompute
	else
	    echo "Not recomputing anything"
	fi
}

# pkg_short_name, pkg_version, platform - already defined
do_undefine() {
	myplatf=`echo $platform | sed -e 's/-SLC4//'`
	cmd="$ALIEN -exec packman undefine $pkg_short_name $pkg_version -vo -platform $myplatf"
	echo "Running: $cmd .."
	$cmd
}

do_multi_platform_undefine() {
	pkg_short_name=$1
	pkg_version=$2
	shift 2
	while [ $# -gt 0 ] ; do
		platform=$1
		echo "Removing package $pkg_short_name version $pkg_version platform $platform.."
		do_undefine
		shift
	done
	
	recompute
}

show_available() {
	echo "Getting BitServers  .."
	bit_servers=`wget -O - http://alienbuild.cern.ch:8889/BitServers 2>/dev/null | awk -F \| '{print $3}'`
	for server in $bit_servers ; do
		echo "Getting packages on $server .."
		pkg_list_platform=`wget -O - $server/tarballs/Packages 2>/dev/null`
		pkg_list="${pkg_list}${pkg_list_platform}"
	done
	echo "Available packages:"
	pkg_names=`echo -e "$pkg_list" | awk '{print $2}' | sort -u`
	for pkg_name in $pkg_names ; do
		pkg_vers=`echo -e "$pkg_list" | grep "	$pkg_name	" | awk '{print $3}' | sort -u`
		for pkg_ver in $pkg_vers ; do
			pkg_platfs=`echo -e "$pkg_list" | grep "	$pkg_name	" | grep "	$pkg_ver	" | awk '{print $4}' | sort -u`
			echo -n -e "$pkg_name	$pkg_ver	"
			echo $pkg_platfs
		done
	done
}

show_package_platforms(){
    cmd=`$ALIEN -exec ls /alice/packages/$2/$3 2>/dev/null`
    
    for a in $cmd ;
    do 
	echo $a;
    done
}

show_package_dependencies(){
    cmd=`$ALIEN -exec packman dependencies VO_ALICE@$2::$3 2>/dev/null | grep "dependencies:" | awk '{print $2}'`
    
    echo $cmd;    
}


show_defined() {
	echo "Querying AliEn for defined packages .."
	$ALIEN -exec packman list -force -all
}

recompute() {
	echo "Running recompute .."
	$ALIEN -exec packman recompute
	echo "Sleeping 10 seconds .."
	sleep 10
	echo "Re-running recompute .."
	$ALIEN -exec packman recompute
}

if [ $# -eq 0 ] ; then usage; fi

case "$1" in
	install)
		shift
		if [ $# -lt 3 ] ; then usage; fi
		do_multi_platform_install $*
		;;
	undefine)
		shift
		if [ $# -lt 3 ] ; then usage; fi
		do_multi_platform_undefine $*
		;;
	show_available)
		show_available
		;;
	show_defined)
		show_defined
		;;
	show_package_platforms)
		show_package_platforms $*
		;;
	show_package_dependencies)
		show_package_dependencies $*
		;;

	*)
		usage
esac
