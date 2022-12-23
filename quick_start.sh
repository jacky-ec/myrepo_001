#!/bin/bash

ROOT_PATH=${PWD}
BUILD_DIR=${ROOT_PATH}/openwrt

devices=(EAP101 EAP102 EAP104 SSW2AC2600 OAP103-BR)
count=0
for p in ${devices[@]}; do
	echo $count: $p
	count=$((count + 1))
done

echo ""

read -p "Please select target device : " device

echo ""

case $device in
0)
	TARGET=EAP101
	;;
1)
	TARGET=EAP102
	;;
2)
	TARGET=EAP104
	;;
3)
	TARGET=SSW2AC2600
	;;
4)
	TARGET=OAP103-BR
	;;
*)
	echo "The selected target device does not exist !!"

	exit 1
	;;
esac

echo "Selected target device is ${devices[$device]}"

echo ""

set -ex

if [ ! "$(ls -A $BUILD_DIR)" ]; then
	python3 setup.py --setup || exit 1
    
else
	python3 setup.py --rebase
	echo "### OpenWrt repo already setup"
fi

TARGET=${TARGET^^}

case "${TARGET}" in
EAP101)
	TIP_TARGET=edgecore_eap101
	# For acc package
	echo "Edge-corE Wave2: EAP101" > ${BUILD_DIR}/models.txt
	;;
EAP102)
	TIP_TARGET=edgecore_eap102
	WIFI=wifi-ax
	# For acc package
	echo "Edge-corE Wave2: EAP102" > ${BUILD_DIR}/models.txt
	;;
EAP104)
	TIP_TARGET=edgecore_eap104
	WIFI=wifi-ax
	# For acc package
	echo "Edge-corE Wave2: EAP104" > ${BUILD_DIR}/models.txt
	;;
SSW2AC2600)
	TIP_TARGET=edgecore_ssw2ac2600
	echo "Edge-corE Wave2: SSW2AC2600" > ${BUILD_DIR}/models.txt
	;;
OAP103-BR)
	TIP_TARGET=oap103-BR
	WIFI=wifi-ax
	# For acc package
	echo "Edge-corE Wave2: OAP103-BR" > ${BUILD_DIR}/models.txt
	;;
*)
	echo "${TARGET} is unknown"
	exit 1
	;;
esac

echo "### Generating config"
cd ${BUILD_DIR}
./scripts/gen_config.py ${TIP_TARGET} || exit 1
cd -

echo "### openwrt/feeds/package patch ..."
for file in $(ls pkg_patches); do
	if [ "${file##*.}" = "patch"  ]; then
		cd openwrt/feeds/packages
		git am -3 ../../../pkg_patches/${file}
		cd -
	fi
done

