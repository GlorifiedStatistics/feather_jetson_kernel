# Jetpack 6.1 L4T 36.4

Fork of: https://github.com/otischung/jetson_linux_36.4

Rebuild and flash the jetson nano kernel for Feather robots.

## Requirements

This is built to be run within a docker container running ubuntu.

Assumes the following have already been installed:

    flex bison libssl-dev axel lbzip2

## Building Kernel

```bash
./build_kernel.sh.
```

## Current Fixes

- Enabling ExFAT filesystem
- Building Wireguard and iptables kernel objects
- Enabling GPIO pin control

## Flash to Jetson Orin Nano Dev. Kit

Before you flash, you have to disable the USB auto-suspend of your host OS. Edit `/etc/default/grub` and add `usbcore.autosuspend=-1` to `GRUB_CMDLINE_LINUX_DEFAULT`. Update your `grub` by `update-grub` and then reboot your computer.

Reference: 

- https://forums.developer.nvidia.com/t/error-might-be-timeout-in-usb-write/284646
- https://unix.stackexchange.com/questions/91027/how-to-disable-usb-autosuspend-on-kernel-3-7-10-or-above

Then you can start flashing your Jetson board.

```bash
./flash_board.sh
```

### Rev.1 Update: MAXN Power Mode

```bash
sudo rm /etc/nvpmodel.conf
sudo ln -s /etc/nvpmodel/nvpmodel_p3767_0001.conf /etc/nvpmodel.conf
```

[Reference Page](https://developer.nvidia.com/embedded/learn/get-started-jetson-orin-nano-devkit#maxn)
