#/bin/bash

if [ -z $NDK_ROOT ]
	then
		echo "NDK_ROOT not specified.  aborting"
		exit 1
fi

#TODO:  Support for x86_64
ARMSYSROOT="androidtoolchains/arm"
MIPSSYSROOT="androidtoolchains/mips"
MIPS64SYSROOT="androidtoolchains/mips64"

supported=(arm mips mips64)
arch=''

while getopts 'a:' flag; do
	case "${flag}" in
		a) arch="${OPTARG}" ;;
		*) 
			echo "Unknown flag ${flag}"			
			exit 1 ;;
	esac
done

good_arch=false

for i in "${supported[@]}" 
do
	if [ "${i}" = "${arch}" ]; then
		good_arch=true
	fi
done

if [ "${good_arch}" = false ] ; then
	echo "Unknown architecture ${arch}"
	exit 1
fi

sysroot=""
prefix=""
echo "Identifying toolchain for ${arch}"
if [ "${arch}" = "arm" ]; then 
	sysroot="${ARMSYSROOT}"
    prefix="arm-linux-androidabi-"
elif [ "${arch}" = "mips" ]; then
    prefix="mipsel-linux-android-"
	sysroot="${MIPSSYSROOT}"
else
    prefix="mips64el-linux-android-"
	sysroot="${MIPS64SYSROOT}"
fi

INSTALL=out/

echo "the toolchain at ${sysroot} will be our sysroot for this build" 

./configure \

--prefix=$INSTALL \

--enable-shared \

--disable-static \

--disable-doc \

--disable-ffmpeg \

--disable-ffplay \

--disable-ffprobe \

--disable-ffserver \

--disable-avdevice \

--disable-doc \

--disable-symver \

--cross-prefix=$prefix \

--target-os=linux \

--arch=${arch} \

--enable-cross-compile \

--sysroot=$sysroot \

--extra-cflags="-Os -fpic $ADDI_CFLAGS" \

--extra-ldflags="$ADDI_LDFLAGS" \

$ADDITIONAL_CONFIGURE_FLAG

make clean

make -j$(nproc)

make install