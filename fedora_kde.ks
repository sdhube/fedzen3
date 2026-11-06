# Fedora 45 Automated Kickstart Configuration
# Optimized for AMD Zen 3 + AMD GPU + KDE Plasma 6 Desktop

# 1. Installation Source and System Initialization
url --url="https://fedoraproject.org"
text
keyboard --vcons-layout=us --xlayouts=us
lang en_US.UTF-8
timezone UTC
reboot

# 2. Storage Partitioning Layout (Tailored for modern NVMe/SSDs)
bootloader --location=mbr
clearpart --all --initlabel
part biosboot --size=1 --fstype=biosboot
part /boot/efi --fstype=efi --size=600 --ondisk=nvme0n1
part /boot --fstype=ext4 --size=1024 --ondisk=nvme0n1
part / --fstype=btrfs --grow --ondisk=nvme0n1

# 3. Microarchitecture Target Performance Repositories
repo --name="fedora-cachyos" --baseurl="https://fedoraproject.org" --priority=10
repo --name="fedora-cachyos-addons" --baseurl="https://fedoraproject.org" --priority=10
repo --name="rpmfusion-free" --mirrorlist="https://rpmfusion.org"
repo --name="rpmfusion-nonfree" --mirrorlist="https://rpmfusion.org"

# 4. Out-of-the-Box Core Package Selection
%packages
@base-x
@kde-desktop-environment
kernel-cachyos
kernel-cachyos-devel-matched
cachyos-settings
ananicy-cpp
scx-scheds
ffmpeg
ffmpeg-libs
libva-utils
openblas-openmp
%end

# 5. Post-Installation Automation Configuration Scripts
%post --log=/root/ks-post-optimization.log
# Ensure we run commands in an active environment path
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

# A. Maximize DNF Package Manager Speed Globally
cat <<EOF > /etc/dnf/dnf.conf
[main]
gpgcheck=True
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
max_parallel_downloads=10
fastestmirror=True
default_vendor_change=False
zstd_clevel=3
EOF

# B. Enforce Global KDE Environment Flags for AMD GPU / Zen 3 Threads
cat <<EOF >> /etc/environment
# Performance flags for KWin and Mesa Drivers
mesa_glthread=true
KWIN_DRM_NO_AMS=0
KWIN_DRM_USE_MODIFIERS=1
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
QT_ENABLE_GLYPH_CACHE_WORKAROUND=0
OPENBLAS_CORETYPE=ZEN
EOF

# C. Set Up High-Priority Ananicy Rules for KDE Desktop Fluidity
mkdir -p /etc/ananicy.d/
cat <<EOF >> /etc/ananicy.d/00-types.rules
{"name": "kwin_wayland", "type": "Realtime"}
{"name": "plasmashell", "type": "Important"}
EOF

# D. Tune AMD P-State Configuration for Systemd First-Boot Startup
cat <<EOF > /etc/systemd/system/amd-pstate-perf.service
[Unit]
Description=Configure AMD P-State Governor to Maximum Performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference && echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# E. Complete Global Microarchitecture User-Space Alignment
dnf distro-sync --refresh -y

# F. Enable Background Latency Services
systemctl enable ananicy-cpp
systemctl enable amd-pstate-perf.service

%end
