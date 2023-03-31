#!/bin/bash -e

scriptdir=$(dirname $(type -p $0))
. $scriptdir/localversion.sh

debdist=`lsb_release -cs`

docker_pkg_depends_test()
{
	local maj="$1"
	local libs
	local list
	local dep
	local missing
	local esc=$(printf '\033')
	echo ===== Get deps in htchain-${maj}
	files=`find /opt/htchain/htchain-${maj}/`
	libs=
	for i in ${files}; do
		f=`file $i`
		if [[ $f == *"ELF 64-bit LSB"* && $f == *"interpreter"* ]]; then
			lib=`readelf -d ${i} 2>/dev/null | grep "Shared library" | cut -f 2 -d "[" | cut -f 1 -d "]" | sort -u`
			lib=`dpkg -S ${lib} 2>/dev/null | cut -f 1 -d ":" | sort -u`
			case $lib in
				*htchain*);;
				*)        libs+="$lib ";;
			esac
		fi
	done
	libs=`echo ${libs} | tr " " "\n" | sort -u`
	echo full-Depends: ${libs}

	list=()
	for i in ${libs}; do 
		# if [[ "$i" != "htchain-${flavour}-${maj}" ]] && [[ "$i" != *"-dev" ]]; then
		if [[ "$i" != "htchain" ]] && [[ "$i" != *"-dev" ]]; then
			list+=(\"$i\")
		fi
	done
	libs=`echo ${list[@]} | sed 's/\"//g'`
	for i in ${libs}; do
		r=`apt-cache rdepends $i`
		for j in ${libs}; do
			if [[ $r == *"$j"* && "$j" != "$i" ]]; then
				list=( "${list[@]/\"$i\"}" )
			fi
		done
	done
	dep=
	for i in `echo ${list[@]} | sed 's/\"//g'`; do
		dep="${dep}, $i"
	done
	echo Depends: ${dep#* }

	echo ===== Check deps in htchain-${maj}
	missing=
	# dep=`apt-cache depends htchain-${flavour}-${maj}`
	dep=`apt-cache depends htchain`
	for i in `echo ${list[@]} | sed 's/\"//g'`; do
		dep=`echo -e "${dep}" | sed "s/$i/${esc}[0;32m$i${esc}[0m/g"`
		if [[ ${dep} != *"$i"* ]]; then
			missing="${missing} $i"
		fi
	done
	echo -e "${dep}"
	echo -e "Missing:\033[0;31m${missing}\033[0m"
}

sudo apt-get install -y $scriptdir/../out/${debdist}/htchain_${VERSION}*.deb
docker_pkg_depends_test ${MAJOR}