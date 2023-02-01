# Arch Basic Install Commands-Script

# btrfs pipewire zswap timeshift encryption

ls /sys/firmware/efi/efivars

# wifi
ip a
rfkill unblock wifi
ip link set wlan0 up
iwctl
station wlan0 connect "wifi name"
exit

#disk
cfdisk /dev/nvme0n1
300M EFi + Linux filesystem
mkfs.vfat -F32 -n "EFI" /dev/nvme0n1p5
cryptsetup --cipher aes-xts-plain64 --hash sha512 --use-random --verify-passphrase luksFormat /dev/nvme0n1p6
cryptsetup luksOpen /dev/nvme0n1p6 cryptroot
mkfs.btrfs /dev/mapper/cryptroot

# 4 - Create and Mount Subvolumes
mount /dev/mapper/root    /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@var
btrfs subvolume list /mnt
umount /mnt

# Mount the subvolumes
mount -o noatime,ssd,compress=zstd:2,space_cache=v2,discard=async,subvol=@ /dev/mapper/root /mnt
mkdir -p /mnt/{boot,home,var}
mount -o noatime,ssd,compress=zstd:2,space_cache=v2,discard=async,subvol=@home /dev/mapper/root /mnt/home
mount -o noatime,ssd,compress=zstd:2,space_cache=v2,discard=async,subvol=@var /dev/mapper/root /mnt/var

# Mount the EFI partition
mkdir /mnt/boot/efi
mount /dev/nvme0n1p5 /mnt/boot/efi
df

# 5 Base System and /etc/fstab
reflector --sort rate --country Russia --latest 5 --save /etc/pacman.d/mirrorlist
pacstrap /mnt base linux-zen linux-firmware btrfs-progs vim git amd-ucode (intel-ucode)
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

arch-chroot /mnt
vim /etc/mkinitcpio.conf
	MODULES=(btrfs)
	HOOKS=(encrypt)
mkinitcpio -p linux-zen


	
	
blkid
vim /etc/default/grub	
	GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=UUID=12345:root root=/dev/mapper/cryptroot"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
	or grub-install /dev/nvme0n1
grub-mkconfig -o /boot/grub/grub.cfg	
exit
umount -a
reboot

# wifi
ip a
nmtui

sudo systemctl enable gdm
reboot

paru -S timeshift-bin timeshift-autosnap

grub-btrfs github overlayfs hoo
