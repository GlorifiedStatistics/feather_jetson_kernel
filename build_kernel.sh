#!/bin/bash
set -euo pipefail

##################
# Download/Setup #
##################

# Download jetson kernel
axel -n 10 https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v3.0/toolchain/aarch64--glibc--stable-2022.08-1.tar.bz2
axel -n 10 https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/release/Jetson_Linux_R36.4.0_aarch64.tbz2
axel -n 10 https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/release/Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2
axel -n 10 https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/sources/public_sources.tbz2

# Untar the files and assemble the rootfs
tar xvf Jetson_Linux_R36.4.0_aarch64.tbz2 --use-compress-program=lbzip2
sudo tar xpvf Tegra_Linux_Sample-Root-Filesystem_R36.4.0_aarch64.tbz2 -C Linux_for_Tegra/rootfs/ --use-compress-program=lbzip2

# Don't install netcat when building kernel (not sure why we do this, haven't tested without it)
sed -i 's/ netcat//g' "./Linux_for_Tegra/tools/l4t_flash_prerequisites.sh"

# Install prerequisite libraries, then do whatever ./apply_binaries.sh does
cd Linux_for_Tegra/
sudo ./tools/l4t_flash_prerequisites.sh && ./apply_binaries.sh
cd ..

# Expand the Kernel Sources
tar xvf public_sources.tbz2 -C Linux_for_Tegra/.. --use-compress-program=lbzip2
cd Linux_for_Tegra/source

tar xvf kernel_src.tbz2 --use-compress-program=lbzip2
tar xvf kernel_oot_modules_src.tbz2 --use-compress-program=lbzip2
tar xvf nvidia_kernel_display_driver_source.tbz2 --use-compress-program=lbzip2
cd ../..

# Expand the Jetson Linux Toolchain
mkdir -p l4t-gcc
tar xvf aarch64--glibc--stable-2022.08-1.tar.bz2 -C l4t-gcc --use-compress-program=lbzip2

#################
# Apply Changes #
#################

# Enable kernel modules (wireguard/iptables)
cp config/defconfig_wireguard Linux_for_Tegra/source/kernel/kernel-jammy-src/arch/arm64/configs/defconfig

# Enable GPIO control
cp src/pinctrl-tegra.c Linux_for_Tegra/source/kernel/kernel-jammy-src/drivers/pinctrl/tegra/pinctrl-tegra.c
cp src/pinctrl-tegra.h Linux_for_Tegra/source/kernel/kernel-jammy-src/drivers/pinctrl/tegra/pinctrl-tegra.h
cp dtsi/tegra234-mb1-bct-gpio-p3767-dp-a03.dtsi Linux_for_Tegra/bootloader/tegra234-mb1-bct-gpio-p3767-dp-a03.dtsi
cp dtsi/tegra234-mb1-bct-gpio-p3767-hdmi-a03.dtsi Linux_for_Tegra/bootloader/tegra234-mb1-bct-gpio-p3767-hdmi-a03.dtsi
cp dtsi/tegra234-mb1-bct-pinmux-p3767-dp-a03.dtsi Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb1-bct-pinmux-p3767-dp-a03.dtsi
cp dtsi/tegra234-mb1-bct-pinmux-p3767-hdmi-a03.dtsi Linux_for_Tegra/bootloader/generic/BCT/tegra234-mb1-bct-pinmux-p3767-hdmi-a03.dtsi

##################
# Compile Kernel #
##################

# Environment variables
PROJ_BASE=$(pwd)
export CROSS_COMPILE=${PROJ_BASE}/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
export INSTALL_MOD_PATH=${PROJ_BASE}/Linux_for_Tegra/rootfs/
export KERNEL_HEADERS=${PROJ_BASE}/Linux_for_Tegra/source/kernel/kernel-jammy-src

# Building the Jetson Linux Kernel
cd Linux_for_Tegra/source
./generic_rt_build.sh "disable"
make -C kernel
sudo -E make install -C kernel
cp kernel/kernel-jammy-src/arch/arm64/boot/Image ../kernel/Image

# Building the NVIDIA Out-of-Tree Modules
make modules
sudo -E make modules_install
cd ..
sudo ./tools/l4t_update_initrd.sh

# Building the DTBs
cd source
make dtbs
cp kernel-devicetree/generic-dts/dtbs/* ../kernel/dtb/
cd ../..
