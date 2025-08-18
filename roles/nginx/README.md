# Nginx Ingress Controller Role

This Ansible role installs and configures the Nginx Ingress Controller on a Kubernetes cluster using Helm.

## Requirements

- Ansible 2.9+
- `kubernetes.core` collection
- Access to a Kubernetes cluster
- Helm 3.x (managed by the kubernetes.core.helm module)
- Valid kubeconfig file

## Role Variables

### Default Variables (roles/nginx/defaults/main.yml)

```yaml
nginx_ingress:
  # Helm chart configuration
  chart_name: "ingress-nginx"
  chart_repo: "https://kubernetes.github.io/ingress-nginx"
  release_name: "ingress-nginx"
  namespace: "ingress-nginx"
  create_namespace: true
  
  # Kubeconfig handling
  # If not specified, will use default location (~/.kube/config)
  kubeconfig_path: ""
  
  # Values file path (relative to role templates directory)
  values_file: "values.yaml"
  
  # Service configuration
  service:
    type: "NodePort"
    
  # Additional helm options
  helm:
    wait: true
    timeout: "10m"
    force: false
```

### Variable Customization

You can override any of these variables in your playbook:

```yaml
vars:
  nginx_ingress:
    kubeconfig_path: "/custom/path/to/kubeconfig"
    service:
      type: "LoadBalancer"
    helm:
      timeout: "15m"
```

## Dependencies

This role requires the following Ansible collections:
- `kubernetes.core`

Install with:
```bash
ansible-galaxy collection install kubernetes.core
```

## Example Playbook

### Basic Usage

```yaml
---
- name: Install Nginx Ingress Controller
  hosts: localhost
  connection: local
  gather_facts: true
  roles:
    - nginx
```

### Custom Configuration

```yaml
---
- name: Install Nginx Ingress Controller with Custom Config
  hosts: localhost
  connection: local
  gather_facts: true
  vars:
    nginx_ingress:
      kubeconfig_path: "/home/user/.kube/config"
      service:
        type: "LoadBalancer"
      helm:
        wait: true
        timeout: "15m"
  roles:
    - nginx
```

## Kubeconfig Handling

The role supports two ways to specify the kubeconfig file:

1. **Explicit Path**: Set `nginx_ingress.kubeconfig_path` to the full path of your kubeconfig file
2. **Default Location**: Leave `nginx_ingress.kubeconfig_path` empty (default) to use `~/.kube/config`

## Service Types

The role supports different service types for the Nginx Ingress Controller:

- **NodePort** (default): Exposes the service on each node's IP at a static port
- **LoadBalancer**: Exposes the service externally using a cloud provider's load balancer
- **ClusterIP**: Exposes the service on a cluster-internal IP

## Values File

The role uses a Jinja2 template (`templates/values.yaml.j2`) to generate the Helm values file. This approach allows:

- Dynamic configuration based on Ansible variables
- Separation of concerns (Ansible logic vs Helm configuration)
- Easy customization without modifying Ansible files

### Default NodePort Configuration

When using NodePort service type, the following ports are configured:
- HTTP: 30080
- HTTPS: 30443

## Usage Examples

### Running the Playbook

```bash
# Basic installation
ansible-playbook examples/install-nginx-ingress.yml

# With custom kubeconfig
ansible-playbook examples/install-nginx-ingress.yml -e "nginx_ingress.kubeconfig_path=/path/to/kubeconfig"

# With LoadBalancer service type
ansible-playbook examples/install-nginx-ingress.yml -e "nginx_ingress.service.type=LoadBalancer"
```

### Verifying Installation

After running the playbook, you can verify the installation:

```bash
# Check the deployment
kubectl get deployment -n ingress-nginx

# Check the service
kubectl get service -n ingress-nginx

# Check the pods
kubectl get pods -n ingress-nginx
```

## Troubleshooting

### Common Issues

1. **Kubeconfig not found**: Ensure the kubeconfig file exists and is accessible
2. **Insufficient permissions**: Ensure the kubeconfig has cluster-admin permissions
3. **Helm timeout**: Increase the timeout value in `nginx_ingress.helm.timeout`
4. **Network policies**: Ensure network policies allow communication between components

### Debug Mode

Enable debug output by running with `-v` flag:

```bash
ansible-playbook examples/install-nginx-ingress.yml -v
```

## License

MIT-0

## Author Information

This role was created as part of the padmini ansible collection for Kubernetes infrastructure management.
