#!/bin/bash

USER="liveuser"
OSNAME="SwagArch"

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

id -u $USER &>/dev/null || useradd -m "liveuser" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel"
passwd -d $USER

echo 'Live User Created'


pushd /home/$USER
echo "exec startxfce4" >> .xinitrc
popd

#Name SwagArch
sed -i.bak 's/Arch Linux/'${OSNAME}'/g' /usr/lib/os-release
sed -i.bak 's/arch/'${OSNAME,,}'/g' /usr/lib/os-release
sed -i.bak 's/www.archlinux.org/www.archlinux.com/g' /usr/lib/os-release
sed -i.bak 's/bbs.archlinux.org/bbs.archlinux.com/g' /usr/lib/os-release
sed -i.bak 's/bugs.archlinux.org/bugs.archlinux.com/g' /usr/lib/os-release
cp /usr/lib/os-release /etc/os-release
arch=`uname -m`


sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

#set default Browser
export _BROWSER=firefox
echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/environment
echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/profile

#Set Nano Editor
export _EDITOR=nano
echo "EDITOR=${_EDITOR}" >> /etc/environment
echo "EDITOR=${_EDITOR}" >> /etc/profile

#Enable Sudo
chmod 750 /etc/sudoers.d
chmod 440 /etc/sudoers.d/g_wheel
chown -R root /etc/sudoers.d
echo "Enabled Sudo"

#Enable Calamares Autostart
mkdir -p /home/liveuser/.config/autostart
ln -s /usr/share/applications/calamares.desktop /home/liveuser/.config/autostart/calamares.desktop
chmod +rx /home/liveuser/.config/autostart/calamares.desktop
chown liveuser /home/liveuser/.config/autostart/calamares.desktop

#Setup Pacman
pacman-key --init archlinux swagarch
pacman-key --populate archlinux swagarch
pacman-key --refresh-keys

#Enable Services
systemctl enable pacman-init.service lightdm.service choose-mirror.service dhcpcd.service
systemctl enable org.cups.cupsd.service
systemctl enable avahi-daemon.service
systemctl -fq enable NetworkManager
systemctl mask systemd-rfkill@.service
systemctl set-default graphical.target

#Set Default Cursor Theme
rm -rf /usr/share/icons/Default
ln -s /usr/share/icons/mac-rainbow-cursor/ /usr/share/icons/Default

#Setup Su
sed -i /etc/pam.d/su -e 's/auth      sufficient  pam_wheel.so trust use_uid/#auth        sufficient  pam_wheel.so trust use_uid/'

chmod -R 755 /etc/sudoers.d
