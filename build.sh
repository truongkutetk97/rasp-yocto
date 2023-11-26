echo "##### install update and necessary package"
sudo apt update
sudo apt install build-essential chrpath gawk git bmap-tools texinfo diffstat tree zstd liblz4-tool -y

echo "##### prepare folder structure"
export "CUR_DIR=$(pwd)"
mkdir -p $CUR_DIR/portable/yocto/kirkstone
mkdir $CUR_DIR/portable/yocto/kirkstone/builds
mkdir $CUR_DIR/portable/yocto/kirkstone/downloads

echo "##### clone source"
git clone -b kirkstone git://git.yoctoproject.org/poky.git $CUR_DIR/portable/yocto/kirkstone/poky
git clone -b kirkstone https://github.com/agherzan/meta-raspberrypi.git $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi
git clone -b kirkstone git://git.openembedded.org/meta-openembedded $CUR_DIR/portable/yocto/kirkstone/meta-openembedded

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
    $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi 

echo "##### update local.conf for rpi4-64"
sed -i '/MACHINE/d' $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf
sed -i '1i\MACHINE = "raspberrypi4-64"' $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf

sed -i '/IMAGE_FSTYPES/d' $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi/conf/machine/include/rpi-base.inc
sed -i '1i\IMAGE_FSTYPES = "rpi-sdimg"' $CUR_DIR/portable/yocto/kirkstone/meta-raspberrypi/conf/machine/include/rpi-base.inc

#enable systemd
sed -i '/INIT_MANAGER/d' $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf
sed -i '1i\INIT_MANAGER = "systemd"' $CUR_DIR/portable/yocto/kirkstone/builds/rpi/conf/local.conf

echo "##### start build sequence"
bitbake core-image-base

echo "#### compress the output image"
cd $CUR_DIR/portable/yocto/kirkstone/builds/rpi/tmp/deploy/images/raspberrypi4-64
zip core-image-base-rpi4-64-$(date '+%y%m%d-%H%M')-rootfs-sdimg.zip  core-image-base-raspberrypi4-64-*.rootfs.rpi-sdimg


