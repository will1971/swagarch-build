#!/bin/bash

USER="liveuser"
OSNAME="SwagArch"

set -e -u

# Set locales
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Set clock to UTC
hwclock --systohc --utc

# Locale
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf

# Vconsole
echo "KEYMAP=us" > /etc/vconsole.conf
echo "FONT=" >> /etc/vconsole.conf

# Hostname
echo "swagarch" > /etc/hostname


usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

# add groups autologin and nopasswdlogin (for lightdm autologin)
groupadd -r autologin
groupadd -r nopasswdlogin

# add liveuser
id -u $USER &>/dev/null || useradd -m $USER -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,autologin,nopasswdlogin,power,wheel"
passwd -d $USER

echo 'Live User Created'

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

# sys updates, cleanups, etc.
su -c 'pacman -Syyu --noconfirm' root
su -c 'pacman-optimize' root
su -c 'updatedb' root
su -c 'pacman-db-upgrade' root
su -c 'sync' root

#Enable Services
systemctl enable pacman-init.service lightdm.service choose-mirror.service dhcpcd.service
systemctl enable org.cups.cupsd.service
systemctl enable avahi-daemon.service
systemctl enable haveged
systemctl -fq enable NetworkManager
systemctl mask systemd-rfkill@.service
systemctl set-default graphical.target

#Set Default Cursor Theme
rm -rf /usr/share/icons/Default
ln -s /usr/share/icons/mac-rainbow-cursor/ /usr/share/icons/Default

chmod 755 /etc
