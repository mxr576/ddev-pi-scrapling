#!/usr/bin/env bash
#ddev-generated
set -eu -o pipefail

echo "Installing Scrapling and uv globally via pip..."
python3 -m pip install --break-system-packages "scrapling[all]" uv

echo "Downloading Playwright/Scrapling browsers..."
scrapling install --force

echo "Setting up Playwright cache under /home/pi/.cache for non-root runtime access..."
mkdir -p /home/pi/.cache
if [ -d /root/.cache/ms-playwright ]; then
  mv /root/.cache/ms-playwright /home/pi/.cache/
fi
chown -R pi:pi /home/pi/.cache

echo "Creating google-chrome-stable executable wrapper..."
cat << 'EOF' > /usr/bin/google-chrome-stable
#!/bin/sh
exec $(find /home/pi/.cache/ms-playwright -name 'chrome' -path '*/chrome-linux*/*' | head -1) --no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu --no-zygote "$@"
EOF
chmod +x /usr/bin/google-chrome-stable
