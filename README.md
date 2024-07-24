## Overview

Ubuntu Rockchip is a community project porting Ubuntu to Rockchip hardware with the goal of providing a stable and fully functional environment.

## Highlights

* Available for both Ubuntu 22.04 LTS (with Rockchip Linux 5.10) and Ubuntu 24.04 LTS (with Rockchip Linux 6.1)
* Package management via apt using the official Ubuntu repositories
* Receive all updates and changes through apt
* Desktop first-run wizard for user setup and configuration
* 3D hardware acceleration support via panfork
* Fully working GNOME desktop using wayland
* Chromium browser with smooth 4k youtube video playback
* MPV video player capable of smooth 4k video playback


## Build Ubuntu System Images

### System Requirements:

Debian 12(Bookworm) / Ubuntu 22.04 (Jammy) or above

### Steps

1. Install dependencies

```
sudo apt-get install -y build-essential gcc-aarch64-linux-gnu bison \
qemu-user-static qemu-system-arm qemu-efi u-boot-tools binfmt-support \
debootstrap flex libssl-dev bc rsync kmod cpio xz-utils fakeroot parted \
udev dosfstools uuid-runtime git-lfs device-tree-compiler python2 python3 \
python-is-python3 fdisk bc debhelper python3-pyelftools python3-setuptools \
python3-distutils python3-pkg-resources swig libfdt-dev libpython3-dev
```

2. To checkout the source and build:

```
git clone https://github.com/mixtile-rockchip/ubuntu-rockchip.git
cd ubuntu-rockchip
```

3. All Build

```
sudo ./build.sh -b mixtile-blade3 -s noble -f desktop
```

4. If you only want to compile kernel and uboot, you can use the following command

Only build kernel

```
sudo ./build.sh -b mixtile-blade3 -s noble -f desktop -ko
```

Only build uboot

```
sudo ./build.sh -b mixtile-blade3 -s noble -f desktop -uo
```

Other build options

```
Usage: ./build.sh --board=[mixtile-blade3] --suite=[jammy|noble] --flavor=[server|desktop]

Required arguments:
  -b, --board=BOARD      target board
  -s, --suite=SUITE      ubuntu suite
  -f, --flavor=FLAVOR    ubuntu flavor

Optional arguments:
  -h,  --help            show this help message and exit
  -c,  --clean           clean the build directory
  -ko, --kernel-only     only compile the kernel
  -uo, --uboot-only      only compile uboot
  -ro, --rootfs-only     only build rootfs
  -l,  --launchpad       use kernel and uboot from launchpad repo
  -v,  --verbose         increase the verbosity of the bash script
```

5.The generated image file is in the images folder, including xz compressed packages of the desktop version.

```shell
images/
├── ubuntu-24.04-preinstalled-desktop-arm64-mixtile-blade3-rockchip-format.img.xz
├── ubuntu-24.04-preinstalled-desktop-arm64-mixtile-blade3-rockchip-format.img.xz.sha256
├── ubuntu-24.04-preinstalled-desktop-arm64-mixtile-blade3.img.xz
└── ubuntu-24.04-preinstalled-desktop-arm64-mixtile-blade3.img.xz.sha256
```

ubuntu-24.04-preinstalled-desktop-arm64-mixtile-blade3.img.xz: the compressed disk image file (`img.xz`) for Ubuntu 24.04 preinstalled desktop for the Mixtile Blade3 board.

ubuntu-24.04-preinstalled-desktop-arm64-mixtile-blade3-rockchip-format.img.xz: the compressed disk image file (`img.xz`) for Ubuntu 24.04 preinstalled desktop specifically tailored for the Mixtile Blade3 board with Rockchip format.

## Installation

On Ubuntu

1. Connect Blade 3 Type-C port (near the HDMI port) to your computer with the USB-C cable.

2. Enable Blade 3 to enter MaskROM mode
Turn the position 4 of the SPST four-position dip switch to ON. Then Blade 3 enters MaskROM mode for firmware development.

3. Download the [upgrade tool](https://downloads.mixtile.com/edge2/Linux_Upgrade_Tool.zip) and grant permission to it. Go to the folder Linux_Upgrade_Tool_v1.65 after unzipping the package. Grant permission to the tool by running the sudo chmod u+x upgrade_tool command.

4. Under the folder Linux_Upgrade_Tool_v1.65, you can check whether Blade 3 enters MaskROM mode by running the sudo ./upgrade_tool command. The following is an example:
 ```shell
sudo ./upgrade_tool
Program Data in /media/psf/Home/Downloads/Linux_Upgrade_Tool_v1.65
List of rockusb connected
DevNo=1	Vid=0x2207,Pid=0x350b,LocationID=29	Mode=Maskrom
Found 1 rockusb,Select input DevNo,Rescan press <R>,Quit press <Q>:q
 ```

* Flash Firmware Using Raw Image (Using Raw Image for programming will cause the SN number and MAC in the eMMC to be lost. If you need to keep the SN number and MAC address, please do not use Raw Image format for programming)
```shell
wget https://downloads.mixtile.com/core3588e/image/rk3588_spl_loader_v1.07.111.bin
sudo ./upgrade_tool db rk3588_spl_loader_v1.07.111.bin
sudo ./upgrade_tool wl 0 ubuntu-24.04-preinstalled-desktop-arm64-mixtile-blade3.img
```


* Flash Firmware Using Rockchip Format Image
```shell
sudo ./upgrade_tool uf ubuntu-24.04-preinstalled-desktop-arm64-mixtile-blade3-rockchip-format.img
```



## Boot the System

Mixtile Blade 3 uses USB-C Power Delivery (PD) as its primary power source. However, you may encounter power adapter compatibility issues. Please refer to the [compatibility list](https://www.mixtile.com/docs/compatibility-of-power-supply/) and select an appropriate power adapter to start normally.

## Login Information

For Ubuntu Server and Ubuntu Desktop you will be able to login through HDMI, a serial console connection, or SSH. The predefined user is `mixtile` and the password is `mixtile`.

## Support the Project

There are a few things you can do to support the project:

* Star the repository and follow me on GitHub
* Share and upvote on sites like Twitter, Reddit, and YouTube
* Report any bugs, glitches, or errors that you find (some bugs I may not be able to fix)
* Sponsor me on GitHub; any contribution will be greatly appreciated

These things motivate me to continue development and provide validation that my work is appreciated. Thanks in advance!

---
> Ubuntu is a trademark of Canonical Ltd. Rockchip is a trademark of Fuzhou Rockchip Electronics Co., Ltd. The Ubuntu Rockchip project is not affiliated with Canonical Ltd or Fuzhou Rockchip Electronics Co., Ltd. All other product names, logos, and brands are property of their respective owners. The Ubuntu name is owned by [Canonical Limited](https://ubuntu.com/).
