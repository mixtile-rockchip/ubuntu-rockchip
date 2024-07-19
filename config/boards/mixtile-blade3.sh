# shellcheck shell=bash

export BOARD_NAME="Mixtile Blade 3"
export BOARD_MAKER="Mixtile"
export UBOOT_PACKAGE="u-boot-mixtile-rk3588"
export UBOOT_RULES_TARGET="mixtile-blade3-rk3588"

function config_image_hook__mixtile-blade3() {
    local rootfs="$1"
    local overlay="$2"

    # Install panfork
    chroot "${rootfs}" add-apt-repository -y ppa:jjriek/panfork-mesa
    chroot "${rootfs}" apt-get update
    chroot "${rootfs}" apt-get -y install mali-g610-firmware
    chroot "${rootfs}" apt-get -y dist-upgrade

    cp ${overlay_dir}/usr/bin/vendor_storage ${rootfs}/usr/bin/vendor_storage
    cp -r ../packages/adb/rockchip-adbd.deb ${rootfs}/tmp
    chroot "${rootfs}" dpkg -i /tmp/rockchip-adbd.deb
    echo "BUILD_ID=$(date +'%Y-%m-%d')" >> "${rootfs}/etc/os-release"

    chroot "${rootfs}" sed -i '/^menu title/d' /usr/sbin/u-boot-update
    chroot "${rootfs}" apt-mark hold u-boot-menu

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
EOF

    # Fix and configure audio device
    mkdir -p "${rootfs}/usr/lib/scripts"
    cp "${overlay}/usr/lib/scripts/alsa-audio-config" "${rootfs}/usr/lib/scripts/alsa-audio-config"
    cp "${overlay}/usr/lib/systemd/system/alsa-audio-config.service" "${rootfs}/usr/lib/systemd/system/alsa-audio-config.service"
    chroot "${rootfs}" systemctl enable alsa-audio-config

    return 0
}
