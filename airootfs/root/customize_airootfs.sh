#!/bin/bash

USER="liveuser"
OSNAME="SwagArch"

function initFunc() {
    set -e -u
    umask 022
}

function localeGenFunc() {
    # Set locales
    sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
    locale-gen
}

function setTimeZoneAndClockFunc() {
    # Timezone
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

    # Set clock to UTC
    hwclock --systohc --utc
}

function setDefaultsFunc() {
    #set default Browser
    export _BROWSER=firefox
    echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/environment
    echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/profile

    #Set Nano Editor
    export _EDITOR=nano
    echo "EDITOR=${_EDITOR}" >> /etc/environment
    echo "EDITOR=${_EDITOR}" >> /etc/profile
}

function initkeysFunc() {
    #Setup Pacman
    pacman-key --init archlinux
    pacman-key --populate archlinux
    pacman-key --init swagarch
    pacman-key --populate swagarch
}

function fixPermissionsFunc() {
    #add missing /media directory
    mkdir -p /media
    chmod 755 -R /media

    #fix permissions
    chown root:root /usr
    chmod 755 /etc
}

function enableServicesFunc() {
    systemctl enable pacman-init.service lightdm.service choose-mirror.service
    systemctl enable org.cups.cupsd.service
    systemctl enable avahi-daemon.service
    systemctl enable vboxservice.service
    systemctl enable haveged
    systemctl enable systemd-networkd.service
    systemctl enable systemd-resolved.service
    systemctl -fq enable NetworkManager
    systemctl mask systemd-rfkill@.service
    systemctl set-default graphical.target
}

function enableSudoFunc() {
    chmod 750 /etc/sudoers.d
    chmod 440 /etc/sudoers.d/g_wheel
    chown -R root /etc/sudoers.d
    chmod -R 755 /etc/sudoers.d
    echo "Enabled Sudo"
}

function enableCalamaresAutostartFunc() {
    #Enable Calamares Autostart
    mkdir -p /home/liveuser/.config/autostart
    ln -s /usr/share/applications/calamares.desktop /home/liveuser/.config/autostart/calamares.desktop
    chmod +rx /home/liveuser/.config/autostart/calamares.desktop
    chown liveuser /home/liveuser/.config/autostart/calamares.desktop
}

function fixWifiFunc() {
    #Wifi not available with networkmanager (BugFix)
    #https://github.com/SwagArch/swagarch-build/issues/8
    su -c 'echo "" >> /etc/NetworkManager/NetworkManager.conf'
    su -c 'echo "[device]" >> /etc/NetworkManager/NetworkManager.conf'
    su -c 'echo "wifi.scan-rand-mac-address=no" >> /etc/NetworkManager/NetworkManager.conf'
}

function setDefaultCursorFunc() {
    #Set Default Cursor Theme
    rm -rf /usr/share/icons/Default
    ln -s /usr/share/icons/mac-rainbow-cursor/ /usr/share/icons/Default
}

function deleteObsoletePackagesFunc() {
    # delete obsolete network packages
    pacman -Rns --noconfirm openresolv netctl dhcpcd zsh
}

function configRootUserFunc() {
    usermod -s /usr/bin/bash root
    echo 'export PROMPT_COMMAND=""' >> /root/.bashrc
    chmod 700 /root
}

function createLiveUserFunc () {
    # add groups autologin and nopasswdlogin (for lightdm autologin)
    groupadd -r autologin
    groupadd -r nopasswdlogin

    # add liveuser
    id -u $USER &>/dev/null || useradd -m $USER -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,autologin,nopasswdlogin,power,sambashare,wheel"
    passwd -d $USER
    echo 'Live User Created'
}

function editOrCreateConfigFilesFunc () {
    # Locale
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo "LC_COLLATE=C" >> /etc/locale.conf

    # Vconsole
    echo "KEYMAP=us" > /etc/vconsole.conf
    echo "FONT=" >> /etc/vconsole.conf

    # Hostname
    echo "swagarch" > /etc/hostname

    sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
    sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
}

function renameOSFunc() {
    #Name SwagArch
    osReleasePath='/usr/lib/os-release'
    rm -rf $osReleasePath
    touch $osReleasePath
    echo 'NAME="'${OSNAME}'"' >> $osReleasePath
    echo 'ID=swagarch' >> $osReleasePath
    echo 'PRETTY_NAME="'${OSNAME}'"' >> $osReleasePath
    echo 'ANSI_COLOR="0;35"' >> $osReleasePath
    echo 'HOME_URL="https://swagarch.github.io"' >> $osReleasePath
    echo 'SUPPORT_URL="https://plus.google.com/u/0/communities/112748817922552005139"' >> $osReleasePath
    echo 'BUG_REPORT_URL="https://github.com/SwagArch/swagarch-build/issues"' >> $osReleasePath
    cp /usr/lib/os-release /etc/os-release
    arch=`uname -m`
}

function doNotDisturbTheLiveUserFunc() {
    #delete old config file
    pathToPerchannel="/home/$USER/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-notifyd.xml"
    rm -rf $pathToPerchannel
    #create a new file
    touch $pathToPerchannel
    echo '<?xml version="1.0" encoding="UTF-8"?>' > $pathToPerchannel
    echo '' > $pathToPerchannel
    echo '<channel name="xfce4-notifyd" version="1.0">' > $pathToPerchannel
    echo '  <property name="notify-location" type="uint" value="3"/>' > $pathToPerchannel
    echo '  <property name="do-not-disturb" type="bool" value="true"/>' > $pathToPerchannel
    echo '</channel>' > $pathToPerchannel
}


initFunc
initkeysFunc
localeGenFunc
setTimeZoneAndClockFunc
editOrCreateConfigFilesFunc
configRootUserFunc
createLiveUserFunc
doNotDisturbTheLiveUserFunc
renameOSFunc
setDefaultsFunc
enableSudoFunc
enableCalamaresAutostartFunc
enableServicesFunc
deleteObsoletePackagesFunc
setDefaultCursorFunc
fixWifiFunc
fixPermissionsFunc
initkeysFunc
