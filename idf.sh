#!/bin/bash

set -e

source .env

command=$1

case "$command" in
  menuconfig)
    docker run -it --rm -v $PWD/$TARGET_PROJECT:/project -w /project -u $(id -u $USER):$(id -g $USER) -e HOME=/tmp espressif/idf:$IDF_VER idf.py menuconfig
    ;;
  clean)
    rm -r $PWD/$TARGET_PROJECT/build
    ;;
  build)
    docker run --rm \
      -e MY_ENV_VAR="$MY_ENV_VAR" \
      -v $PWD/$TARGET_PROJECT:/project -w /project -u $(id -u $USER):$(id -g $USER) -e HOME=/tmp espressif/idf:$IDF_VER idf.py build
    ;;
  work)
    docker run -it --rm --device=$HOST_USBDEV:/dev/ttyUSB0 -v $PWD/$TARGET_PROJECT:/project -w /project -e HOME=/tmp espressif/idf:$IDF_VER bash
    ;;
  flash)
    #This command is copied from idf build commnad
    #"idf.py -p (PORT) flash" doesn't work...
    cmd="/opt/esp/python_env/idf4.4_py3.8_env/bin/python ../opt/esp/idf/components/esptool_py/esptool/esptool.py -p /dev/ttyUSB0 -b 500000 --before default_reset --after hard_reset --chip esp32  write_flash --flash_mode dio --flash_size detect --flash_freq 80m 0x1000 build/bootloader/bootloader.bin 0x10000 build/partition_table/partition-table.bin 0x20000 build/intdash-esp-camera.bin"
    docker run --rm --device=$HOST_USBDEV:/dev/ttyUSB0 -v $PWD/$TARGET_PROJECT:/project -w /project -e HOME=/tmp --entrypoint="" espressif/idf:$IDF_VER bash -c "$cmd"
    ;;
  monitor)
    docker run -it --rm --device=$HOST_USBDEV:/dev/ttyUSB0 -v $PWD/$TARGET_PROJECT:/project -w /project -e HOME=/tmp espressif/idf:$IDF_VER idf.py monitor
    ;;
  *)
    echo "Command not supported"
    exit 1
    ;;
esac
