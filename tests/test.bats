#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=mxr576/ddev-pi-scrapling

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  # Start the pi container profile
  echo "# Starting pi container profile..." >&3
  run ddev start --profiles=pi
  assert_success

  # Verify PI_SCRAPLING_VERSION defaults to "main" inside the pi container
  echo "# Checking if PI_SCRAPLING_VERSION defaults to main inside the pi container..." >&3
  run ddev exec -s pi printenv PI_SCRAPLING_VERSION
  assert_success
  assert_output "main"

  # Verify we can override PI_SCRAPLING_VERSION via .ddev/.env.pi
  echo "# Testing override of PI_SCRAPLING_VERSION via .ddev/.env.pi..." >&3
  echo 'PI_SCRAPLING_VERSION="custom-override"' >> .ddev/.env.pi
  run ddev restart
  assert_success
  run ddev start --profiles=pi
  assert_success
  run ddev exec -s pi printenv PI_SCRAPLING_VERSION
  assert_success
  assert_output "custom-override"

  # Verify python package scrapling is installed in the pi container
  echo "# Verifying scrapling python package in container..." >&3
  run ddev exec -s pi python3 -c "import scrapling; print('Scrapling imported successfully')"
  assert_success
  assert_output --partial "Scrapling imported successfully"

  # Verify google-chrome-stable wrapper exists in the pi container
  echo "# Verifying google-chrome-stable executable in container..." >&3
  run ddev exec -s pi which google-chrome-stable
  assert_success
  assert_output --partial "/usr/bin/google-chrome-stable"

  # Verify scrapling-official skill is registered with pi agent
  echo "# Verifying scrapling-official skill registered with pi agent..." >&3
  run ddev exec -s pi npx skills list --agent pi
  assert_success
  assert_output --partial "scrapling-official"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
