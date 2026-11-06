# Fedora KDE Plasma Automated Installation Kickstart
# Target: Zen 3 AMD CPU + AMD Radeon RX 6600

# Required basic setup (Adjust localization as needed)
keyboard us
lang en_US.UTF-8
timezone America/New_York --utc

# Use graphical or text installation
graphical

# Setup initial user accounts
rootpw --lock
user --name=fedora --groups=wheel --password=changeme --gecos="Fedora User"

# Partitioning (Clears disk and auto-allocates default Btrfs structure)
ignoredisk --only-use=sda
clearpart --all --initlabel
autopart --type=btrfs

# Media and Reboot setup
reboot

# --- Package Selection ---
%packages
@kde-desktop-environment
tuned
nano
git
%end

# --- Post-Installation Configuration Script ---
%post --log=/root/ks-post-install.log
#!/bin/bash

echo "Starting hardware optimization script for Zen 3 and RX 6600..."

# 1. Optimize DNF5 configuration
cat <<EOF >> /etc/dnf/dnf.conf
max_parallel_downloads=10
fastestmirror=True
EOF

# 2. Add RPM Fusion Free and Nonfree repositories using DNF5 config-manager
dnf config-manager addrepo --from-repofile=https://rpmfusion.org
dnf config-manager addrepo --from-repofile=https://rpmfusion.org

# Refresh metadata to acknowledge new repos
dnf clean all
dnf makecache

# 3. Swap to full multimedia stack & install Mesa freeworld hardware decoding
dnf swap -y ffmpeg-free ffmpeg --allowerasing
dnf install -y mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld

# 4. Configure Tuned for low latency Zen 3 CPU profile
systemctl enable tuned
echo "latency-performance" > /etc/tuned/active_profile

# 5. Global KDE System Tweaks (Applied for all new users via skeleton profile)
SKEL_KDE="/etc/skel/.config"
mkdir -p "$SKEL_KDE"

# Disable Baloo file indexing to save background Zen 3 cycles
cat <<EOF > "$SKEL_KDE/baloofilerc"
[Basic Settings]
Indexing-Enabled=false
EOF

# Speed up desktop animations for a snappier interface response
cat <<EOF > "$SKEL_KDE/kdeglobals"
[KDE]
AnimationDurationFactor=0.75
EOF

echo "Post-install optimization complete."
%end
