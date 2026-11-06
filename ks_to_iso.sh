# Create mount and working directories
mkdir -p /tmp/mount /tmp/iso_workspace

# Mount the original Fedora ISO
sudo mount -o loop Fedora-Server-netinst-x86_64-42.iso /tmp/mount

# Copy all contents to your workspace (preserving permissions)
cp -a /tmp/mount/. /tmp/iso_workspace/

# Unmount the original ISO
sudo umount /tmp/mount


cp /path/to/your/ks.cfg /tmp/iso_workspace/ks.cfg


linux /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Fedora-Server-netinst-42 quiet inst.ks=hd:LABEL=Fedora-Server-netinst-42::/ks.cfg


xorrisofs -clickable-addiv -V "Fedora-Server-netinst-42" \
  -J -r -joliet-long \
  -b isolinux/isolinux.bin -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e images/efiboot.img -no-emul-boot \
  -isohybrid-mbr /usr/share/syslinux/isohdpfx.bin \
  -o /tmp/Fedora-Unattended.iso /tmp/iso_workspace

