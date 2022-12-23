#!/bin/bash

set -ex
ROOT_PATH=${PWD}
BUILD_DIR=${ROOT_PATH}/openwrt
TARGET=${1}

if [ -z "$1" ]; then
	echo "Error: please specify TARGET"
	echo "For example: EAP101"
	exit 1
fi

if [ ! "$(ls -A $BUILD_DIR)" ]; then
	python3 setup.py --setup || exit 1
    
else
	python3 setup.py --rebase
	echo "### OpenWrt repo already setup"
fi

TARGET=${TARGET^^}
ACOM=

case "${TARGET}" in
EAP101)
	TIP_TARGET=edgecore_eap101
	ACOM=acom
	# For acc package
	echo "Edge-corE EAP101: EAP101" > ${BUILD_DIR}/models.txt
	;;
EAP102)
	TIP_TARGET=edgecore_eap102
	WIFI=wifi-ax
	ACOM=acom
	# For acc package
	echo "Edge-corE EAP102: EAP102" > ${BUILD_DIR}/models.txt
	;;
EAP104)
	TIP_TARGET=edgecore_eap104
	WIFI=wifi-ax
	ACOM=acom
	# For acc package
	echo "Edge-corE EAP104: EAP104" > ${BUILD_DIR}/models.txt
	;;
SSW2AC2600)
	TIP_TARGET=edgecore_ssw2ac2600
	echo "Edge-corE Wave2: SSW2AC2600" > ${BUILD_DIR}/models.txt
	;;
OAP103-BR)
	TIP_TARGET=oap103-BR
	WIFI=wifi-ax
	ACOM=acom
	# For acc package
	echo "Edge-corE OAP103-BR: OAP103-BR" > ${BUILD_DIR}/models.txt
	;;
*)
	echo "${TARGET} is unknown"
	exit 1
	;;
esac

echo "### Generating config"
cd ${BUILD_DIR}
./scripts/gen_config.py ${TIP_TARGET} ${ACOM} || exit 1
cd -

echo "### openwrt/feeds/package patch ..."
for file in $(ls pkg_patches); do
	if [ "${file##*.}" = "patch"  ]; then
		cd openwrt/feeds/packages
		git am -3 ../../../pkg_patches/${file}
		cd -
	fi
done

echo "### Building image ..."
cd $BUILD_DIR
make clean
make -j$(nproc) V=s 2>&1 | tee build.log
echo "Done"
