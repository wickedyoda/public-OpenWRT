# 1) Make sure HTTPS downloads work (only needed once)
opkg update
opkg install ca-bundle ca-certificates wget-ssl

# 2) Choose a safe location for the script
mkdir -p /usr/local/bin
cd /usr/local/bin

# 3) (Optional) backup any old copy
[ -f update-tailscale.sh ] && cp -a update-tailscale.sh update-tailscale.sh.bak.$(date +%F-%H%M%S)

# 4) Download the latest script from GitHub (raw)
wget -O update-tailscale.sh \
  https://raw.githubusercontent.com/Admonstrator/glinet-tailscale-updater/main/update-tailscale.sh

# 5) Make it executable and do a quick syntax check
chmod +x update-tailscale.sh
sh -n update-tailscale.sh

# 6) Run it (add VERBOSE=1 for more output if the script supports it)
sh /usr/local/bin/update-tailscale.sh