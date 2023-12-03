REM set the build folder of yocto then the script can do the test to fetch the sdimg.
set CUR_DIR=/home/lenhattruong.tk8/rasp-yocto

ssh gcp1 "cd %CUR_DIR%/portable/yocto/kirkstone/builds/rpi/tmp/deploy/images/raspberrypi4-64 ; rm core-image-base-raspberrypi4-64.rpi-sdimg.zip"

ssh gcp1 "cd %CUR_DIR%/portable/yocto/kirkstone/builds/rpi/tmp/deploy/images/raspberrypi4-64 ; zip core-image-base-raspberrypi4-64.rpi-sdimg.zip  core-image-base-raspberrypi4-64.rpi-sdimg"

del core-image-base-raspberrypi4-64.rpi-sdimg.zip
scp gcp1:/%CUR_DIR%/portable/yocto/kirkstone/builds/rpi/tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.rpi-sdimg.zip .
pause