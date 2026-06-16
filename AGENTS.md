# Agent Guidelines

This document provides architectural context and rules for AI coding agents.

## 1. Project Context & Architecture

This repository is a **DDEV addon** that extends the [ddev-pi DDEV addon](https://github.com/mxr576/ddev-pi) via its [Extension API](https://github.com/mxr576/ddev-pi/blob/main/docs/extensions.md).

Files under the `pi/` directory are mapped into the `pi` service container using the following mount points:

- **`pi/global/agent/extensions/`**: Global pi agent extensions.
- **`pi/entrypoint.d/`**: Container startup hook scripts (for installations, config, etc.).
- **`pi/bashrc.d/`**: Interactive shell initialization hooks.

## 2. Rules of Engagement

Strictly adhere to these rules during all development, editing, and testing.

### The `.ddev` Directory
- **Do not modify the `.ddev` directory.** It contains the installed addon used for testing.
- All work must be on source files **outside** this directory.

### Command Execution
- This is a DDEV environment. If `IS_DDEV_PROJECT` is set or the `ddev` command is unavailable, you are inside the container.
- When inside the container, **never prefix commands with `ddev`**, for example, run `pi` instead of `ddev pi`.

### New Packages or Extensions
When adding a new global PI package/extension:
1.  **Add Version Env Var**: Create a `PI_<NAME>_VERSION` environment variable.
2.  **Allow Overrides**: The variable must be customizable by users in `.ddev/.env.pi`.
3.  **Set Default**: Define a fallback default version in the installer script.
4.  **Auto-initialize**: The variable must be auto-added to `.ddev/.env.pi` on new installs.
5.  **Add Tests**: Cover the new version and its behavior in `tests/test.bats`.

### BATS Testing for the `pi` Service
- The `pi` service is gated by a Docker Compose profile and **is not started by a plain `ddev restart`**.
- Tests needing the `pi` container **must** use this command to start it:
  ```bash
  ddev restart && ddev start --profiles=pi
  ```
- **Rebuilding Note**: `ddev utility rebuild -s <service>` is broken for profile-gated services (see [ddev/ddev#8463](https://github.com/ddev/ddev/pull/8463)). Until fixed, the command above is the only reliable way to force an image rebuild.
