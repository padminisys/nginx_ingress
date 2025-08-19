# AWX Execution Environment

This directory contains the configuration files for building the AWX/AAP Execution Environment.

## Files Overview

### Execution Environment Configurations
- **`execution-environment.yml`** - Full EE configuration with additional build steps
- **`execution-environment-simple.yml`** - Simplified EE configuration for reliable builds

### Requirements Files
- **`requirements.yml`** - Collections required during EE build (excludes self-reference)
- **`requirements-build.yml`** - Backup/alternative build requirements file
- **`requirements-awx.yml`** - Complete collection requirements for runtime use in AWX/AAP
- **`requirements.txt`** - Python package dependencies
- **`bindep.txt`** - System package dependencies

## Build Process

The GitHub Actions workflow uses a fallback strategy:
1. First attempts build with `execution-environment-simple.yml`
2. Falls back to `execution-environment.yml` if needed

Both configurations use `requirements.yml` during build to avoid circular dependencies, as the collection itself (`padminisys.nginx_ingress`) is not yet published when building the EE.

## Usage in AWX/AAP

After the EE is built and the collection is published, use the root-level `requirements.yml` in your AWX/AAP projects to install all required collections including the published `padminisys.nginx_ingress` collection.

## Container Registry

The built execution environment is pushed to:
- `ghcr.io/padminisys/nginx_ingress/awx-ee:latest`
- `ghcr.io/padminisys/nginx_ingress/awx-ee:{version}`

## File Structure

```
awx/
├── execution-environment.yml          # Full EE config
├── execution-environment-simple.yml   # Simplified EE config  
├── requirements.yml                   # Build-time dependencies (no self-reference)
├── requirements-build.yml            # Alternative build dependencies
├── requirements-awx.yml              # Runtime dependencies (includes self-reference)
├── requirements.txt                  # Python dependencies
├── bindep.txt                       # System dependencies
└── README.md                        # This documentation