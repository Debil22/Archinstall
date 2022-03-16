#!/bin/bash
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
  g # clear the in memory partition table
  n # new partition
  1 # partition number 1
    # default - start at beginning of disk 
  +31M # 31 MB boot parttion
  t # change type of partition
  4 # BIOS boot
  n # new partition
  2 # partion number 2
    # default, start immediately after preceding partition
  +300M # default, extend partition to end of disk
  t # change type of partition
  2 # choose second partition
  1 # EFI System
  n # new partition
  3 # partition number 3
    # First sector
    # Last sector
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF
clear
mkfs.vfat /dev/sda2
mkfs.btrfs -f /dev/sda3
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot
clear
pacstrap -i /mnt base base-devel linux-zen linux-zen-headers linux-firmware dosfstools btrfs-progs intel-ucode iucode-tool nano
clear
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
timedatectl set-ntp yes
cat >  /etc/locale.gen << EOF
en_US.UTF-8 UTF-8
ru_RU.UTF-8 UTF-8
EOF
locale-gen
echo LANG=ru_RU.UTF-8  cat > /etc/locale.conf # LANG=ru_RU.UTF-8
cat > /etc/vconsole.conf << EOF # KEYMAP=ru FONT=cyr-sun16
KEYMAP=ru
FONT=cyr-sun16
EOF
echo arch | cat > /etc/hostname # arch
cat > /etc/hosts << EOF
127.0.0.1  localhost
::1        localhost
127.0.0.1 arch.localdomain  arch
EOF
mkinitcpio -P
passwd
echo y | pacman -S grub efibootmgr dhcpcd dhclient networkmanager
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
exit
umount -R /mnt
reboot
