[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/mxr576/ddev-pi-scrapling/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/mxr576/ddev-pi-scrapling/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/mxr576/ddev-pi-scrapling)](https://github.com/mxr576/ddev-pi-scrapling/commits)
[![release](https://img.shields.io/github/v/release/mxr576/ddev-pi-scrapling)](https://github.com/mxr576/ddev-pi-scrapling/releases/latest)

# DDEV Pi Scrapling

## Overview

This add-on integrates Pi Scrapling into your [DDEV](https://ddev.com/) project.

## Installation

```bash
ddev add-on get mxr576/ddev-pi-scrapling
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev describe` | View service status and used ports for Pi Scrapling |
| `ddev logs -s pi-scrapling` | Check Pi Scrapling logs |

## Advanced Customization

To change the Docker image:

```bash
ddev dotenv set .ddev/.env.pi-scrapling --pi-scrapling-docker-image="ddev/ddev-utilities:latest"
ddev add-on get mxr576/ddev-pi-scrapling
ddev restart
```

Make sure to commit the `.ddev/.env.pi-scrapling` file to version control.

All customization options (use with caution):

| Variable | Flag | Default |
| -------- | ---- | ------- |
| `PI_SCRAPLING_DOCKER_IMAGE` | `--pi-scrapling-docker-image` | `ddev/ddev-utilities:latest` |

## Credits

**Contributed and maintained by [@mxr576](https://github.com/mxr576)**
