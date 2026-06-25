#!/usr/bin/env bash
#ddev-generated
set -eu -o pipefail

# Fallback to defaults if not set (for backwards compatibility with < 1.0.0-alpha6)
USERNAME="${USERNAME:-pi}"
USER_HOME="${USER_HOME:-/home/pi}"

echo "Installing Scrapling and uv globally via pip..."
python3 -m pip install --break-system-packages "scrapling[all]" uv

echo "Downloading Playwright/Scrapling browsers..."
scrapling install --force

echo "Setting up Playwright cache under ${USER_HOME}/.cache for non-root runtime access..."
mkdir -p "${USER_HOME}/.cache"
if [ -d /root/.cache/ms-playwright ]; then
  mv /root/.cache/ms-playwright "${USER_HOME}/.cache/"
fi
chown -R "${USERNAME}" "${USER_HOME}/.cache"

echo "Creating google-chrome-stable executable wrapper..."
cat << EOF > /usr/bin/google-chrome-stable
#!/bin/sh
exec \$(find "${USER_HOME}/.cache/ms-playwright" -name 'chrome' -path '*/chrome-linux*/*' | head -1) --no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu --no-zygote "\$@"
EOF
chmod +x /usr/bin/google-chrome-stable
