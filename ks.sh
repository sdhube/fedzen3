
# 1. Clear out the failed target files
rm -rf iso_extracted/*

# 2. Force read/copy as root using sudo (ignoring ISO permissions)
sudo cp -rT iso_mount/ iso_extracted/

# 3. Change ownership of all extracted files back to your regular user
sudo chown -R $USER:$USER iso_extracted/

# 4. Explicitly make all extracted files writable by you
chmod -R u+w iso_extracted/



# 1. Update UEFI Boot (grub.cfg)
sed -i '/linuxefi \/images\/pxeboot\/vmlinuz/ s/$/ inst.ks=hd:LABEL=Fedora-Zen3:\/ks.cfg/' iso_extracted/EFI/BOOT/grub.cfg
sed -i '/linux \/images\/pxeboot\/vmlinuz/ s/$/ inst.ks=hd:LABEL=Fedora-Zen3:\/ks.cfg/' iso_extracted/EFI/BOOT/grub.cfg




# 1. Move into the extracted directory
cd iso_extracted

# 2. Compile the new image out to the parent folder
xorriso -as mkisofs \
  -V "Fedora-Zen3" \
  -J -r -v \
  -b images/eltorito.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e images/eltorito.img \
  -no-emul-boot \
  -o ../Fedora-Everything-Zen3-Custom.iso . 
   
# 3. Move back out to your parent workspace folder
cd ..


isohybrid --uefi Fedora-Everything-Zen3-Custom.iso






# xorriso -as mkisofs   -V "Fedora-Zen3"   -J -r -v   -b images/eltorito.img   -no-emul-boot -boot-load-size 4 -boot-info-table   -eltorito-alt-boot   -e images/eltorito.img   -no-emul-boot   -o ../Fedora-Everything-Zen3-Custom.iso . 
cd ..
isohybrid --uefi Fedora-Everything-Zen3-Custom.iso
