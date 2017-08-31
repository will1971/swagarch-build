#!/bin/bash
# This file is part of the SwagArch GNU/Linux distribution
# Copyright (c) 2017 Mike Krüger
# 
# This program is free software: you can redistribute it and/or modify  
# it under the terms of the GNU General Public License as published by  
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

USER="memoryleakx"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

ISO="swagarch-$(date +%y%m)_x86_64.iso"
SIG="swagarch-$(date +%y%m)_x86_64.iso.sig"
MD5SUM="md5sum"

#Build ISO File
package=archiso
if pacman -Qs $package > /dev/null ; then
    echo "The package $package is installed"
else
    echo "Installing package $package"
    pacman -S $package --noconfirm
fi

source build.sh -v

chown $USER out/
cd out/

#create md5sum and signature file
echo "create MD5 Checksum"
sudo -u $USER md5sum $ISO >> md5sum
echo "Signing ISO Image..."
sudo -u $USER gpg --detach-sign --no-armor $ISO

