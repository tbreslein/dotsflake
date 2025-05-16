# archinstall

## Setup: kain (desktop arch) and raziel (laptop arch)

### part 0: prep

```sh
iwctl device list # from now on, assume wlan0 is the wifi device
iwctl station wlan0 scan
iwctl station wlan0 get-networks # grab your network SSID
iwctl station wlan0 connect "YOUR WIFI SSID" -P "wifi passphrase"

timedatectl set-ntp true
timedatectl set-timezone Europe/Berlin

export disk=/dev/nvme0n1 # or whatever your device is

# if you are reinstalling, wipe the disk and fill with random data
wipefs -af $disk
sgdisk --zap-all --clear $disk
partprobe $disk # should return errorcode 0
cryptsetup open --type plain -d /dev/urandom $disk target
# NOTE: cryptsetup already provided the randomness, so dd can just read from /dev/zero
dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct
cryptsetup close target
```

### partitioning / formatting

```sh
# create a 512MB efi partition, and a luks partition for the rest of the system
sgdisk -n 0:0:+1G -t 0:ef00 -c 0:esp $disk
sgdisk -n 0:0:0 -t 0:8309 -c 0:luks $disk
partprobe $disk

# check the partition table
sgdisk -p $disk

# open the crypt
# NOTE: the p2 only works on NVME devices, otherwise you need to use ${disk}2
cryptsetup --type luks1 -v -y luksFormat ${disk}p2

# format
cryptsetup open ${disk}p2 crypt
mkfs.vfat -F32 -n ESP ${disk}p1
mkfs.btrfs -L archlinux /dev/mapper/crypt

mount /dev/mapper/crypt /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@swap
umount -R /mnt

export sv_opts="rw,noatime,nodiratime,ssd,compress-force=zstd:1,space_cache=v2"

mount -o ${sv_opts},subvol=@ /dev/mapper/crypt /mnt
mkdir -p /mnt/{boot,home,swap,.snapshots,nix,var/{cache,log,tmp,lib/libvirt}}
mount -o ${sv_opts},subvol=@home /dev/mapper/crypt /mnt/home
mount -o ${sv_opts},subvol=@swap /dev/mapper/crypt /mnt/swap
mount -o ${sv_opts},subvol=@snapshots /dev/mapper/crypt /mnt/.snapshots
mount -o ${sv_opts},subvol=@nix /dev/mapper/crypt /mnt/nix
mount -o ${sv_opts},subvol=@cache /dev/mapper/crypt /mnt/var/cache
mount -o ${sv_opts},subvol=@log /dev/mapper/crypt /mnt/var/log
mount -o ${sv_opts},subvol=@tmp /dev/mapper/crypt /mnt/var/tmp
mount -o ${sv_opts},subvol=@libvirt /dev/mapper/crypt /mnt/var/lib/libvirt
mount ${disk}p1 /mnt/boot

# the size should be 1.5x of the ram size
btrfs filesystem mkswapfile --size 48g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile
```

### system bootstrap

```sh
pacman -Syy
export microcode="amd-ucode" # or intel-ucode respectively
reflector --verbose --protocol https --latest 15 --sort rate --country Germany --country France --save /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel $microcode btrfs-progs linux-lts linux-firmware cryptsetup man-db vim networkmanager openssh pacman-contrib pkgfile reflector sudo zsh
genfstab -U -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash
```

in the chroot:

```sh
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --hctosys # when you don't need to install windows, to --systohc instead?

# assume "foobar" is the name you want your machine to have
echo "foobar" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 foobar.localdomain foobar
EOF

vim /etc/systemd/timesyncd.conf
# [TIME]
# NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
# FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
systemctl enable systemd-timesyncd.service

export locale="en_US.UTF-8"
sed -i "s/^#\(${locale}\)/\1/" /etc/locale.gen
grep "$locale" /etc/locale.gen # check that you didn't typo the sed command
echo "LANG=${locale}" > /etc/locale.conf
locale-gen

echo "EDITOR=nvim" > /etc/environment && echo "VISUAL=nvim" >> /etc/environment

passwd # root password
useradd -m -G wheel -s /bin/zsh tommy
passwd tommy

sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

systemctl enable NetworkManager

vim /etc/mkinitcpio.conf
# # first, add btrfs to MODULES
# MODULES=(btrfs vfat)
# # then, add encrypt hook before filesystems, and resume after it; remove fsck
# HOOKS=(base udev keyboard autodetect microcode modconf keymap consolefont block encrypt filesystems resume)
mkinitcpio -P

vim /etc/pacman.conf # enable verbosepkgslist, paralleldownloads, color, and multilib
pacman -Syu
vim /etc/xdg/reflector/reflector.conf # set countries to France,Germany, --latest 15, --sort rate
systemctl enable reflector.service
systemctl enable reflector.timer
systemctl enable paccache.timer

pacman -S efibootmgr
__blkid=$(blkid -s UUID -o value ${disk}p2)
# this should go into a bash script
efibootmgr --create --disk ${disk} --part 1 --label 'Arch-LTS' --load /vmlinuz-linux-lts --unicode "cryptdevice=UUID=${__blkid}:crypt root=/dev/mapper/crypt rw rootflags=noatime,nodiratime,ssd,compress-force=zstd:1,space_cache=v2,subvol=@ initrd=\amd-ucode.img initrd=\initramfs-linux-lts.img" --verbose

# make sure the bootorder is correct

exit
swapoff -a
umount -R /mnt
reboot
```

### first boot

login into user

```sh
nmtui # setup wifi, if necessary

sudo pacman -S ufw syncthing
sudo ufw enable
sudo ufw allow syncthing
systemctl --user enable --now syncthing

sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay linux-cachyos

# add another boot entry for cachy kernel:
efibootmgr --create --disk ${disk} --part 1 --label 'Arch-Cachy' --load /vmlinuz-linux-cachyos --unicode "cryptdevice=UUID=${__blkid}:crypt root=/dev/mapper/crypt rw rootflags=noatime,nodiratime,ssd,compress-force=zstd:1,space_cache=v2,subvol=@ initrd=\amd-ucode.img initrd=\initramfs-linux-cachyos.img" --verbose

# make sure the bootorder is correct
```

nvidia specific:

```sh
sudo pacman -S linux-lts-headers
yay linux-cachyos-headers
sudo pacman -S nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings
sudo vim /etc/mkinitcpio.conf
# add to MODULES: nvidia nvidia_modeset nvidia_uvm nvidia_drm
# remove from HOOKS: kms
sudo mkinitcpio -P

reboot # just see that everything works and that wifi connects automatically
```

```sh
# install nix
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

## packages

```sh
#base
base
base-devel
btrfs-progs
linux-lts
linux-firmware
cryptsetup
man-db
vim
networkmanager
openssh
pacman-contrib
pkgfile
reflector
sudo
zsh
efibootmgr
git
ufw

#base-aur
linux-cachyos

#amd
amd-ucode

#nvidia
linux-lts-headers
nvidia-open-dkms
nvidia-utils
lib32-nvidia-utils
nvidia-settings

#nvidia-aur
linux-cachyos-headers

#desktop
hyprland
hyprpolkitagent
xdg-desktop-portal-hyprland
qt5-wayland
qt6-wayland
greetd
pipewire
pipewire-alsa
pipewire-pulse
wireplumber
egl-wayland
xorg-xwayland
wayland-protocols
alacritty
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
ttf-liberation
ttf-roboto

#desktop-aur
brave-bin
```
