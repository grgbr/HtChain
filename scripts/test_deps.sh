#!/bin/bash -e

if [ ! -f /.dockerenv ]; then
    >&2 echo "$0 must be run in docker."
    >&2 echo "Re-run it as following command:"
    >&2 echo "make DEBDIST=jammy test-deps"
	exit 1
fi

scriptdir=$(dirname $(type -p $0))
outdir=$(realpath $scriptdir/../out)
. $scriptdir/localversion.sh

debdist=`. /etc/os-release && echo "$VERSION_CODENAME"`

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
				*htchain-${maj}*);;
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

sudo apt-get install -y $outdir/${debdist}/htchain-${MAJOR}_${VERSION}*.deb
docker_pkg_depends_test ${MAJOR}