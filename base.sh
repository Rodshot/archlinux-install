#!/bin/bash

ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
sed -i '178s/.//' /etc/locale.gen
sed -i '404s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "REZZ" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 REZZ.localdomain REZZ" >> /etc/hosts
echo root:password | chpasswd

pacman -S grub grub-btrfs efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers xdg-user-dirs xdg-utils inetutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector os-prober gdm gnome gnome-extra firefox gnome-tweaks vlc ntfs-3g
# pacman -S --noconfirm tlp
# pacman -S --noconfirm xf86-video-intel
# pacman -S --noconfirm xf86-video-amdgpu

grub-install /dev/nvme0n1
grub-mkconfig -o /boot/grub/grub.cfg

#systemctl enable tlp
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable reflector.timer

useradd -m rodshot
echo rodshot:password | chpasswd
usermod -aG libvirt rodshot

echo "rodshot ALL=(ALL) ALL" >> /etc/sudoers.d/rodshot
