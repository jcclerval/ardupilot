#!/bin/bash
set -e

CWD=$(pwd)
OPT="/opt"

BASE_PKGS="gawk make git arduino-core curl"
SITL_PKGS="g++ python-pip python-matplotlib python-serial python-scipy python-opencv python-numpy python-pyparsing ccache"
PYTHON_PKGS="pymavlink MAVProxy droneapi"
PX4_PKGS="python-serial python-argparse openocd flex bison libncurses5-dev \
          autoconf texinfo build-essential libftdi-dev libtool zlib1g-dev \
          zip genromfs"
UBUNTU64_PKGS="libc6:i386 libgcc1:i386 libstdc++5:i386 libstdc++6:i386"
ASSUME_YES=false

# GNU Tools for ARM Embedded Processors
# (see https://launchpad.net/gcc-arm-embedded/)
AVR_URL = "http://ww1.microchip.com/downloads/archive/avr8-gnu-toolchain-3.4.3.1072-linux.any.x86_64.tar.gz"
ARM_ROOT="gcc-arm-none-eabi-6-2017-q2"
ARM_TARBALL="$ARM_ROOT-update-linux.tar.bz2"
ARM_TARBALL_URL="https://firmware.ardupilot.org/Tools/PX4-tools/$ARM_TARBALL"

# Ardupilot Tools
ARDUPILOT_TOOLS="ArduPlane/Tools/autotest"

function maybe_prompt_user() {
    if $ASSUME_YES; then
        return 0
    else
        read -p "$1"
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        else
            return 1
        fi
    fi
}


OPTIND=1  # Reset in case getopts has been used previously in the shell.
while getopts "y" opt; do
    case "$opt" in
        \?)
            exit 1
            ;;
        y)  ASSUME_YES=true
            ;;
    esac
done

if $ASSUME_YES; then
    APT_GET="sudo apt-get -qq --assume-yes"
else
    APT_GET="sudo apt-get"
fi

sudo usermod -a -G dialout $USER

$APT_GET remove modemmanager
$APT_GET update
$APT_GET install $BASE_PKGS $SITL_PKGS $PX4_PKGS $UBUNTU64_PKGS
sudo python -m pip -q install future
sudo python -m pip -q install $PYTHON_PKGS


if [ ! -d PX4Firmware ]; then
    git clone https://github.com/diydrones/PX4Firmware.git
fi

if [ ! -d PX4NuttX ]; then
    git clone https://github.com/diydrones/PX4NuttX.git
fi

if [ ! -d VRNuttX ]; then
    git clone https://github.com/virtualrobotix/vrbrain_nuttx.git VRNuttX
fi

if [ ! -d $OPT/$ARM_ROOT ]; then
    (
        cd $OPT;
        sudo wget $ARM_TARBALL_URL;
        sudo tar xjf ${ARM_TARBALL};
        sudo rm ${ARM_TARBALL};
    )
fi

exportline="export PATH=$OPT/$ARM_ROOT/bin:\$PATH";
if ! grep -Fxq "$exportline" ~/.profile ; then
    if maybe_prompt_user "Add $OPT/$ARM_ROOT/bin to your PATH [Y/n]?" ; then
        echo $exportline >> ~/.profile
        $exportline
    else
        echo "Skipping adding $OPT/$ARM_ROOT/bin to PATH."
    fi
fi

exportline2="export PATH=$CWD/$ARDUPILOT_TOOLS:\$PATH";
if ! grep -Fxq "$exportline2" ~/.profile ; then
    if maybe_prompt_user "Add $CWD/$ARDUPILOT_TOOLS to your PATH [Y/n]?" ; then
        echo $exportline2 >> ~/.profile
        $exportline2
    else
        echo "Skipping adding $CWD/$ARDUPILOT_TOOLS to PATH."
    fi
fi

