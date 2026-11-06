# Base Fedora Installation Configuration
url --url="https://fedoraproject.org"
text
keyboard --vcons-layout=us --xlayouts=us
lang en_US.UTF-8
timezone UTC

# 1. Map the Zen 3 Hardware Performance Repositories
repo --name="fedora-cachyos" --baseurl="https://fedoraproject.org"
repo --name="fedora-cachyos-addons" --baseurl="https://fedoraproject.org"

# 2. Package Instruction Set Selection
%packages
@base-x
@workstation-product-environment
kernel-cachyos
kernel-cachyos-devel-matched
cachyos-settings
ananicy-cpp
scx-scheds
%end

# 3. Post-Install Automation Scripts
%post --log=/root/ks-post.log
# Maximize DNF speed immediately
cat <<EOF >> /etc/dnf/dnf.conf
max_parallel_downloads=10
fastestmirror=True
default_vendor_change=False
zstd_clevel=3
EOF

# Force system-wide x86_64_v3 synchronization
dnf distro-sync --refresh -y

# Enable low-latency scheduler engines
systemctl enable --now ananicy-cpp
%end



# user command
# Enroll the newly installed repository MOK keys into NVRAM
#sudo mokutil --import /etc/pki/akmods/certs/public_key.der

