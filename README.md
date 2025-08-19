# Ansible Collection - padminisys.nginx_ingress

[![Ansible Galaxy](https://img.shields.io/badge/galaxy-padminisys.nginx__ingress-blue.svg)](https://galaxy.ansible.com/padminisys/nginx_ingress)
[![License](https://img.shields.io/badge/license-GPL--2.0--or--later-green.svg)](LICENSE)

An Ansible collection for deploying and managing Nginx Ingress Controller on Kubernetes clusters using Helm.

## 🎯 Overview

This collection provides a comprehensive Ansible role to install and configure the Nginx Ingress Controller on Kubernetes clusters. It uses the official Helm chart with fixed versioning for reproducibility and supports multiple deployment scenarios.

## 📦 What's Included

### Roles
- **nginx** - Main role for installing and configuring Nginx Ingress Controller

### Examples
- [`nodeport-basic.yml`](examples/nodeport-basic.yml) - Basic NodePort deployment (default)
- [`loadbalancer-production.yml`](examples/loadbalancer-production.yml) - Production LoadBalancer with HA
- [`clusterip-internal.yml`](examples/clusterip-internal.yml) - Internal ClusterIP deployment
- [`install-nginx-ingress.yml`](examples/install-nginx-ingress.yml) - Generic installation example

## 🚀 Quick Start

### Installation

```bash
ansible-galaxy collection install padminisys.nginx_ingress
```

### Basic Usage

```yaml
---
- name: Install Nginx Ingress Controller
  hosts: kubernetes_nodes
  roles:
    - padminisys.nginx_ingress.nginx
```

This installs Nginx Ingress with NodePort service (HTTP: 30080, HTTPS: 30443) using Helm Chart version 4.13.1.

## 📋 Requirements

- Ansible 2.9+
- `kubernetes.core` collection (>=2.4.0)
- `ansible.posix` collection (>=1.5.0)
- Access to a Kubernetes cluster
- Valid kubeconfig file
- Python 3 with `kubernetes` library

## 🔧 Configuration

The role supports three main deployment types:

### NodePort (Default)
```yaml
nginx_ingress_values:
  controller:
    service:
      type: "NodePort"
      nodePorts:
        http: 30080
        https: 30443
```

### LoadBalancer
```yaml
nginx_ingress_values:
  controller:
    service:
      type: "LoadBalancer"
      loadBalancerSourceRanges:
        - "10.0.0.0/8"
```

### ClusterIP
```yaml
nginx_ingress_values:
  controller:
    service:
      type: "ClusterIP"
```

## 📚 Documentation

For detailed configuration options, examples, and troubleshooting, see the [nginx role documentation](roles/nginx/README.md).

## 🧪 Testing

```bash
# Install collection
ansible-galaxy collection install padminisys.nginx_ingress

# Run example
ansible-playbook examples/nodeport-basic.yml
```

## 📖 Version Information

- **Collection Version**: 1.0.6
- **Helm Chart Version**: 4.13.1 (fixed)
- **Nginx App Version**: 1.13.1

## 📄 License

GPL-2.0-or-later

## 👥 Author

Manish <manish@padminisys.com>

## 🔗 Links

- [Documentation](https://padmini.systems/ansible/docs)
- [Homepage](https://padmini.systems/ansible)
- [Issues](https://github.com/padminisys/nginx_ingress/issues)
- [Repository](https://github.com/padminisys/nginx_ingress)
