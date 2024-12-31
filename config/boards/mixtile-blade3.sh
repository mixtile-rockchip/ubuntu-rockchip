# shellcheck shell=bash

export BOARD_NAME="Mixtile Blade 3"
export BOARD_MAKER="Mixtile"
export BOARD_SOC="Rockchip RK3588"
export BOARD_CPU="ARM Cortex A76 / A55"
export UBOOT_PACKAGE="u-boot-mixtile-rk3588"
export UBOOT_RULES_TARGET="mixtile-blade3-rk3588"
export COMPATIBLE_SUITES=("jammy" "noble")
export COMPATIBLE_FLAVORS=("server" "desktop")

function config_image_hook__mixtile-blade3() {
    local rootfs="$1"
    local overlay="$2"

    # Install panfork
    chroot "${rootfs}" add-apt-repository -y ppa:jjriek/panfork-mesa
    chroot "${rootfs}" apt-get update
    chroot "${rootfs}" apt-get -y install mali-g610-firmware
    chroot "${rootfs}" apt-get -y dist-upgrade

    # Install libmali blobs alongside panfork
    chroot "${rootfs}" apt-get -y install libmali-g610-x11

    # Install the rockchip camera engine
    chroot "${rootfs}" apt-get -y install camera-engine-rkaiq-rk3588


    cp ${overlay_dir}/usr/bin/vendor_storage ${rootfs}/usr/bin/vendor_storage
    cp -r ../packages/adb/rockchip-adbd.deb ${rootfs}/tmp
    chroot "${rootfs}" dpkg -i /tmp/rockchip-adbd.deb
    echo "BUILD_ID=$(date +'%Y-%m-%d')" >> "${rootfs}/etc/os-release"

    chroot "${rootfs}" sed -i '/^menu title/d' /usr/sbin/u-boot-update
    chroot "${rootfs}" sed -i 's/^U_BOOT_PROMPT=.*$/U_BOOT_PROMPT="0"/' /usr/share/u-boot-menu/conf.d/ubuntu.conf
    chroot "${rootfs}" apt-mark hold u-boot-menu

    if [ "$FLAVOR" = "server" ]; then
        chroot "${rootfs}" apt-get -y purge cloud-init
        cp ${overlay_dir}/boot/firmware/network-config ${rootfs}/etc/netplan/default.yaml
    fi

    cat << EOF | chroot "${rootfs}"
export DEBIAN_FRONTEND=noninteractive
export LANG=en_US.UTF-8

/usr/sbin/oem-config-remove
userdel --force --remove oem || true
systemctl set-default graphical.target || true
systemctl disable oem-config.service || true
systemctl disable oem-config.target || true
rm -f /lib/systemd/system/oem-config.* || true

sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/default/locale
dpkg-reconfigure locales

useradd mixtile -m -u 1000 -s /bin/bash -G sudo,netdev,audio,video,disk,tty,users,games,dialout,plugdev,input,bluetooth,systemd-journal,render
(
echo "mixtile"
echo "mixtile"
) | passwd "root" > /dev/null 2>&1

(
echo "mixtile"
echo "mixtile"
) | passwd "mixtile" > /dev/null 2>&1


sed -i -r \
    -e "s/^#[ ]*AutomaticLoginEnable =.*\$/AutomaticLoginEnable=true/" \
    -e "s/^#[ ]*AutomaticLogin =.*\$/AutomaticLogin=mixtile/" \
    /etc/gdm3/custom.conf

ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
echo "Etc/UTC" >/etc/timezone
echo "mixtile-ubuntu" >/etc/hostname

echo "127.0.0.1   localhost
127.0.1.1   mixtile-ubuntu
::1         localhost mixtile-ubuntu ip6-localhost ip6-loopback
fe00::0     ip6-localnet
ff00::0     ip6-mcastprefix
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters" > /etc/hosts

EOF

    # Fix and configure audio device
    mkdir -p "${rootfs}/usr/lib/scripts"
    cp "${overlay}/usr/lib/scripts/alsa-audio-config" "${rootfs}/usr/lib/scripts/alsa-audio-config"
    cp "${overlay}/usr/lib/systemd/system/alsa-audio-config.service" "${rootfs}/usr/lib/systemd/system/alsa-audio-config.service"
    chroot "${rootfs}" systemctl enable alsa-audio-config

    return 0
}
