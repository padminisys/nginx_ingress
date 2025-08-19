# Nginx Ingress Controller Role

[![Ansible Role](https://img.shields.io/badge/role-nginx-blue.svg)](https://galaxy.ansible.com/padminisys/nginx_ingress)

This Ansible role installs and configures the Nginx Ingress Controller on a Kubernetes cluster using Helm Chart **Version 4.13.1** (App Version 1.13.1).

## 🎯 Key Features

- **Fixed Chart Version**: Uses Helm Chart 4.13.1 for reproducibility and idempotency
- **Comprehensive Configuration**: Full variable structure mirroring official Helm chart values
- **Easy Overrides**: Override any Helm chart value using Ansible variables
- **Multiple Service Types**: Support for NodePort, LoadBalancer, and ClusterIP
- **Production Ready**: Sensible defaults with enterprise-grade customization options

## 📋 Requirements

- Ansible 2.9+
- `kubernetes.core` collection
- Access to a Kubernetes cluster
- Valid kubeconfig file on target node
- Python 3 with `kubernetes` library on target node

## 🚀 Quick Start

### Basic Installation (NodePort - Default)

```yaml
---
- name: Install Nginx Ingress Controller
  hosts: kubernetes_nodes
  roles:
    - nginx
```

This installs nginx ingress with:
- **Service Type**: NodePort (HTTP: 30080, HTTPS: 30443)
- **Chart Version**: 4.13.1 (fixed for reproducibility)
- **Replicas**: 1
- **Resources**: CPU 100m, Memory 90Mi

## 📊 Variable Structure

The role uses a comprehensive variable structure that mirrors the official Helm chart values:

### Chart Configuration (Fixed Versions)
```yaml
nginx_ingress_chart:
  name: "ingress-nginx"
  repo: "https://kubernetes.github.io/ingress-nginx"
  version: "4.13.1"      # Fixed for reproducibility
  app_version: "1.13.1"  # Corresponding app version
```

### Release Configuration
```yaml
nginx_ingress_release:
  name: "ingress-nginx"
  namespace: "ingress-nginx"
  create_namespace: true
```

### Kubeconfig Configuration
```yaml
nginx_ingress_kubeconfig:
  path: ""  # Empty = use ~/.kube/config
```

### Helm Operation Configuration
```yaml
nginx_ingress_helm:
  wait: true
  timeout: "10m"
  force: false
```

### Values Configuration (Main Customization Point)
```yaml
nginx_ingress_values:
  controller:
    service:
      type: "NodePort"  # NodePort, LoadBalancer, ClusterIP
      nodePorts:
        http: 30080
        https: 30443
    replicaCount: 1
    resources:
      limits:
        cpu: "100m"
        memory: "90Mi"
    # ... and many more options
```

## 🔧 Configuration Examples

### Example 1: LoadBalancer Service Type

```yaml
---
- name: Install Nginx Ingress with LoadBalancer
  hosts: kubernetes_nodes
  vars:
    nginx_ingress_values:
      controller:
        service:
          type: "LoadBalancer"
          loadBalancerSourceRanges:
            - "10.0.0.0/8"
            - "192.168.0.0/16"
  roles:
    - nginx
```

### Example 2: ClusterIP with Custom Configuration

```yaml
---
- name: Install Nginx Ingress with ClusterIP
  hosts: kubernetes_nodes
  vars:
    nginx_ingress_values:
      controller:
        service:
          type: "ClusterIP"
        replicaCount: 3
        resources:
          limits:
            cpu: "200m"
            memory: "256Mi"
          requests:
            cpu: "100m"
            memory: "128Mi"
        config:
          use-forwarded-headers: "true"
          compute-full-forwarded-for: "true"
          use-proxy-protocol: "false"
  roles:
    - nginx
```

### Example 3: High Availability with Autoscaling

```yaml
---
- name: Install HA Nginx Ingress with Autoscaling
  hosts: kubernetes_nodes
  vars:
    nginx_ingress_values:
      controller:
        service:
          type: "LoadBalancer"
        replicaCount: 2
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "250m"
            memory: "256Mi"
        nodeSelector:
          node-role.kubernetes.io/worker: "true"
        tolerations:
          - key: "dedicated"
            operator: "Equal"
            value: "ingress"
            effect: "NoSchedule"
        affinity:
          podAntiAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
              - weight: 100
                podAffinityTerm:
                  labelSelector:
                    matchExpressions:
                      - key: app.kubernetes.io/name
                        operator: In
                        values:
                          - ingress-nginx
                  topologyKey: kubernetes.io/hostname
      autoscaling:
        enabled: true
        minReplicas: 2
        maxReplicas: 10
        targetCPUUtilizationPercentage: 70
        targetMemoryUtilizationPercentage: 80
      podDisruptionBudget:
        enabled: true
        minAvailable: 1
  roles:
    - nginx
```

### Example 4: Custom Kubeconfig Path

```yaml
---
- name: Install with Custom Kubeconfig
  hosts: kubernetes_nodes
  vars:
    nginx_ingress_kubeconfig:
      path: "/etc/kubernetes/admin.conf"
    nginx_ingress_helm:
      timeout: "15m"
  roles:
    - nginx
```

### Example 5: NodePort with Custom Ports

```yaml
---
- name: Install with Custom NodePort Ports
  hosts: kubernetes_nodes
  vars:
    nginx_ingress_values:
      controller:
        service:
          type: "NodePort"
          nodePorts:
            http: 32080
            https: 32443
            tcp:
              8080: 32808
              9000: 32900
        config:
          server-tokens: "false"
          ssl-protocols: "TLSv1.2 TLSv1.3"
          ssl-ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
  roles:
    - nginx
```

## 🔍 Available Override Options

You can override any section of the Helm chart values by using the `nginx_ingress_values` variable. Here are the main sections:

### Controller Configuration
- `controller.image.*` - Container image settings
- `controller.service.*` - Service configuration
- `controller.resources.*` - CPU/Memory limits and requests
- `controller.nodeSelector` - Node selection constraints
- `controller.tolerations` - Pod tolerations
- `controller.affinity` - Pod affinity rules
- `controller.config.*` - Nginx configuration options
- `controller.metrics.*` - Metrics and monitoring
- `controller.admissionWebhooks.*` - Admission webhook settings

### Other Components
- `defaultBackend.*` - Default backend configuration
- `rbac.*` - RBAC settings
- `serviceAccount.*` - Service account configuration
- `podDisruptionBudget.*` - PDB settings
- `autoscaling.*` - HPA configuration

## 📚 Common Configuration Patterns

### SSL/TLS Configuration
```yaml
nginx_ingress_values:
  controller:
    config:
      ssl-protocols: "TLSv1.2 TLSv1.3"
      ssl-ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
      ssl-prefer-server-ciphers: "true"
      hsts: "true"
      hsts-max-age: "31536000"
```

### Performance Tuning
```yaml
nginx_ingress_values:
  controller:
    config:
      worker-processes: "auto"
      worker-connections: "16384"
      max-worker-open-files: "65536"
      upstream-keepalive-connections: "320"
      upstream-keepalive-requests: "10000"
```

### Logging Configuration
```yaml
nginx_ingress_values:
  controller:
    config:
      log-format-json: "true"
      access-log-path: "/var/log/nginx/access.log"
      error-log-path: "/var/log/nginx/error.log"
      error-log-level: "warn"
```

## 🧪 Testing

Run the test playbook to validate your installation:

```bash
# Build and install collection
ansible-galaxy collection build
ansible-galaxy collection install padminisys-nginx_ingress-*.tar.gz --force

# Run tests
cd tests
ansible-playbook -i inventory nginx.yml -v
```

## 📖 Version Information

- **Helm Chart Version**: 4.13.1 (fixed for reproducibility)
- **App Version**: 1.13.1
- **Chart Repository**: https://kubernetes.github.io/ingress-nginx
- **Official Documentation**: https://kubernetes.github.io/ingress-nginx/

## 🔧 Troubleshooting

### Common Issues

1. **Chart Version Conflicts**: This role uses a fixed chart version (4.13.1) for reproducibility
2. **Service Type Changes**: When changing service types, consider the implications for your network setup
3. **Resource Constraints**: Adjust resource limits based on your cluster capacity
4. **Node Selection**: Use nodeSelector and tolerations for proper pod placement

### Debug Commands

```bash
# Check deployment status
kubectl get deployment -n ingress-nginx

# Check service configuration
kubectl get service -n ingress-nginx

# Check pod logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Describe ingress controller
kubectl describe deployment -n ingress-nginx ingress-nginx-controller
```

## 📄 License

MIT-0

## 👥 Author Information

This role was created as part of the [padminisys.nginx_ingress](https://galaxy.ansible.com/padminisys/nginx_ingress) ansible collection for Kubernetes infrastructure management.

## 🔗 Related Resources

- [Collection Documentation](../../README.md)
- [Example Playbooks](../../examples/)
- [Official Nginx Ingress Documentation](https://kubernetes.github.io/ingress-nginx/)
- [Helm Chart Repository](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx)
