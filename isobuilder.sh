#!/bin/bash

while [ -n "$1" ]
do
case "$1" in
-iso) iso="$2"
shift ;;
-source) url="$2"
shift ;;
*) echo "$1 is not an option";;
esac
shift
done

# echo "ISO: $iso"
# echo "SOURCE FROM: $url"

# SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# create output directory
mkdir "./sources/$iso/source" -p
mkdir "./sources/$iso/unpacked" -p
mkdir "./sources/$iso/tmp" -p
mkdir "./sources/$iso/dist" -p
mkdir "./sources/$iso/unpacked/server" -p

iso_source_basename=$(basename $url)
gr_content=$(cat "./grub.rule.cfg")

if [ ! -f "./sources/$iso/source/$iso_source_basename" ]
then
  # GET ORIGIN ISO
  wget $url -O "./sources/$iso/source/$iso_source_basename"

  # UNPACK ISO
  7z -y x "./sources/$iso/source/$iso_source_basename" -o"./sources/$iso/unpacked"

  # MOVE BOOT PARTITION
  mv "./sources/$iso/unpacked/[BOOT]" "./sources/$iso/tmp/BOOT"

  # EDIT grub.cfg
  if [ ! -f "./sources/$iso/tmp/grub.cfg" ]
  then
    cp -rf "./sources/$iso/unpacked/boot/grub/grub.cfg" "./sources/$iso/tmp/grub.cfg"
  fi
fi

sed -e "0,/menuentry/ s//${gr_content}\nmenuentry/" "./sources/$iso/tmp/grub.cfg" > "./sources/$iso/unpacked/boot/grub/grub.cfg"

# exit 0

# COPY CLOUD-CONFIG
cp -rf ./server/$iso/* "./sources/$iso/unpacked/server"

# BUILD ISO
# Shows arguments for iso creation
# xorriso -indev jammy-live-server-amd64.iso -report_el_torito as_mkisofs

# building
cd "./sources/$iso/unpacked"
xorriso -as mkisofs -r \
  -V 'Ubuntu 22.04 LTS AUTO (EFIBIOS)' \
  -o "../dist/$iso.iso" \
  --grub2-mbr "../tmp/BOOT/1-Boot-NoEmul.img" \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b "../tmp/BOOT/2-Boot-NoEmul.img" \
  -appended_part_as_gpt \
  -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
    -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2:::' \
  -no-emul-boot \
  .
cd "../sources/$iso/dist"
md5sum "$iso.iso" > SHA256SUMS
cd ../../
