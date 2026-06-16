#!/usr/bin/env bash
#ddev-generated
set -eu -o pipefail

# Determine version of Scrapling skill to install
WANTED_VERSION="${PI_SCRAPLING_VERSION:-main}"

# Install Scrapling skill.
SKILL_DIR="/var/www/html/.pi/skills/scrapling-official"
if [ -d "${SKILL_DIR}" ]; then
  echo "Scrapling skill already exists in ${SKILL_DIR}, skipping install."
else
  echo "Adding Scrapling skill with reference ${WANTED_VERSION}..."
  # Disable telemetry by faking CI environment.
  CI=1 npx skills add "https://github.com/D4Vinci/Scrapling/tree/${WANTED_VERSION}/agent-skill/Scrapling-Skill" --agent pi -y
fi
