echo "##### install update and necessary package"
sudo apt update
sudo apt install build-essential chrpath gawk git bmap-tools texinfo diffstat tree zstd liblz4-tool zip -y

echo "##### prepare folder structure"
export "CUR_DIR=$(pwd)"
mkdir -p $CUR_DIR/portable/yocto/kirkstone
mkdir $CUR_DIR/portable/yocto/kirkstone/builds
mkdir $CUR_DIR/portable/yocto/kirkstone/downloads

echo "##### clone source"
git clone -b kirkstone git://git.yoctoproject.org/poky.git $CUR_DIR/portable/yocto/kirkstone/poky
git clone -b kirkstone https://github.com/agherzan/meta-raspberrypi.git $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi
git clone -b kirkstone git://git.openembedded.org/meta-openembedded $CUR_DIR/portable/yocto/kirkstone/meta-openembedded
git clone -b nilrt/master/kirkstone https://github.com/ni/meta-security.git $CUR_DIR/portable/yocto/kirkstone/meta-security
git clone -b kirkstone https://github.com/lgirdk/meta-virtualization.git $CUR_DIR/portable/yocto/kirkstone/meta-virtualization

#patch meta-security
git apply --unsafe-paths $CUR_DIR/patch/meta-security-0001.patch --directory=$CUR_DIR/portable/yocto/kirkstone/meta-security


echo "##### configuring bitbake layer"
source $CUR_DIR/portable/yocto/kirkstone/poky/oe-init-build-env $CUR_DIR/portable/yocto/kirkstone/builds/rpi
bitbake-layers -h
bitbake-layers add-layer \
    $CUR_DIR/portable/yocto/kirkstone/meta-openembedded/meta-oe \
    $CUR_DIR/portable/yocto/kirkstone/meta-openembedded/meta-multimedia \
    $CUR_DIR/portable/yocto/kirkstone/meta-openembedded/meta-networking \
    $CUR_DIR/portable/yocto/kirkstone/meta-openembedded/meta-python \
    $CUR_DIR/portable/yocto/kirkstone/meta-openembedded/meta-perl \
    $CUR_DIR/portable/yocto/kirkstone/meta-openembedded/meta-webserver \
    $CUR_DIR/portable/yocto/kirkstone/meta-openembedded/meta-gnome \
    $CUR_DIR/portable/yocto/kirkstone/meta-openembedded/meta-xfce \
    $CUR_DIR/portable/yocto/kirkstone/meta-security \
    $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi 

bitbake-layers add-layer $CUR_DIR/portable/yocto/kirkstone/meta-openembedded/meta-filesystems
bitbake-layers add-layer $CUR_DIR/portable/yocto/kirkstone/meta-virtualization

echo "##### create custom layer"
bitbake-layers create-layer $CUR_DIR/portable/yocto/kirkstone/meta-jonas
cp -r $CUR_DIR/meta-jonas/* $CUR_DIR/portable/yocto/kirkstone/meta-jonas
bitbake-layers add-layer $CUR_DIR/portable/yocto/kirkstone/meta-jonas

echo "##### update local.conf for rpi4-64"
sed -i '/MACHINE/d' $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf
sed -i '1i\MACHINE = "raspberrypi4-64"' $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf

sed -i '/IMAGE_FSTYPES/d' $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi/conf/machine/include/rpi-base.inc
sed -i '1i\IMAGE_FSTYPES = "rpi-sdimg"' $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi/conf/machine/include/rpi-base.inc

#enable systemd
sed -i '/INIT_MANAGER/d' $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf
sed -i '1i\INIT_MANAGER = "systemd"' $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf

#disable spaslh
sed -i '/DISABLE_SPLASH/d' $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf
sed -i '1i\DISABLE_SPLASH = "1"' $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf

#enable custom package
sed -i '/IMAGE_INSTALL/d' $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi/conf/machine/include/rpi-base.inc
sed -i '1i\IMAGE_INSTALL:append = "packagegroup-core-buildessential packagegroup-core-security packagegroup-docker iptables curl tcpdump net-tools python3 aircrack-ng gptfdisk parted util-linux e2fsprogs-resize2fs xrandr resizefs vim tree git ufw libubootenv openssh"' $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi/conf/machine/include/rpi-base.inc

#remove psplash
sed -i '/IMAGE_FEATURES/d' $CUR_DIR/portable/yocto/kirkstone/poky/meta/recipes-core/images/core-image-base.bb

#updaet hostname
sed -i 's/^hostname = .*/hostname = "kapi"/' $CUR_DIR/portable/yocto/kirkstone/poky/meta/recipes-core/base-files/base-files*.bb

#update distro name
sed -i "s/^DISTRO_NAME = .*/DISTRO_NAME = \"Kapi-v0.0.1-dev-$(date +'%y%m%d-%H%M')\"/" "$CUR_DIR/portable/yocto/kirkstone/poky/meta-poky/conf/distro/poky.conf"

#enable u-boot
echo "PREFERRED_PROVIDER_virtual/bootloader = \"u-boot\"" >> $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi/conf/machine/include/rpi-default-providers.inc
echo "RPI_USE_U_BOOT = \"1\"" >> $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf
echo "ENABLE_UART = \"1\"" >> $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf
echo "DISABLE_RPI_BOOT_LOGO = \"1\"" >> $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf

echo "##### start build sequence"
bitbake core-image-base

