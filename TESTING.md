# Testing Guide for Nginx Ingress Collection

This guide provides step-by-step instructions for testing the nginx ingress collection.

## Prerequisites

### On Control Node (Your Machine)
- Ansible 2.9+
- `kubernetes.core` collection installed
- Access to target Kubernetes node

### On Target Node (kubenext - 45.248.67.9)
- Kubernetes cluster running
- kubectl configured with valid kubeconfig at `~/.kube/config`
- Python 3 with kubernetes library
- User: `ramanuj` with sudo privileges (if needed)

## Testing Workflow

### Step 1: Build the Collection

```bash
# Navigate to collection root directory
cd /home/ramanuj/git_repos/padmini/padmini/ansible/nginx_ingress

# Build the collection
ansible-galaxy collection build
```

Expected output:
```
Created collection for padminisys.nginx_ingress at /path/to/padminisys-nginx_ingress-1.0.0.tar.gz
```

### Step 2: Install the Collection

```bash
# Install the built collection (force reinstall if exists)
ansible-galaxy collection install padminisys-nginx_ingress-*.tar.gz --force
```

Expected output:
```
Process install dependency map
Starting collection install process
Installing 'padminisys.nginx_ingress:1.0.0' to '/home/user/.ansible/collections/ansible_collections/padminisys/nginx_ingress'
```

### Step 3: Verify Collection Installation

```bash
# List installed collections
ansible-galaxy collection list padminisys.nginx_ingress

# Verify role is available
ansible-doc -l | grep nginx
```

### Step 4: Test Connectivity to Target Node

```bash
# Navigate to tests directory
cd tests

# Test basic connectivity
ansible -i inventory kubernetes_nodes -m ping

# Test sudo access (if needed)
ansible -i inventory kubernetes_nodes -m setup -a "gather_subset=system"
```

Expected output:
```
kubenext | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Step 5: Run the Test Playbook

```bash
# Run the nginx ingress installation test
ansible-playbook -i inventory nginx.yml -v
```

## Test Playbook Features

The test playbook ([`tests/nginx.yml`](tests/nginx.yml)) includes:

### Pre-flight Checks
- ✅ Target node connectivity
- ✅ System information gathering
- ✅ Kubeconfig file existence
- ✅ kubectl cluster connectivity

### Installation Process
- ✅ Nginx ingress controller installation via Helm
- ✅ NodePort service configuration
- ✅ Deployment status verification

### Post-installation Validation
- ✅ Pod status verification
- ✅ Service endpoint testing
- ✅ Health check validation
- ✅ Access URL generation

## Expected Test Results

### Successful Installation Output

```yaml
TASK [Display installation results] ****
ok: [kubenext] => {
    "msg": "🎉 Nginx Ingress Controller Installation Complete!\n\n📊 Deployment Status:\n- Name: ingress-nginx-controller\n- Namespace: ingress-nginx\n- Ready Replicas: 1\n- Available Replicas: 1\n\n🚀 Running Pods:\n- ingress-nginx-controller-xxx: Running\n\n🌐 Service Details:\n- Name: ingress-nginx-controller\n- Type: NodePort\n- Cluster IP: 10.96.xxx.xxx\n- NodePorts:\n  - http: 80:30080/TCP\n  - https: 443:30443/TCP\n\n✅ Access URLs (NodePort):\n- HTTP: http://45.248.67.9:30080\n- HTTPS: https://45.248.67.9:30443"
}
```

### Health Check Validation

```yaml
TASK [Display health check result] ****
ok: [kubenext] => {
    "msg": "🏥 Health Check:\n- Status: HEALTHY\n- Response Code: 200"
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Connection Issues
```bash
# Test SSH connectivity
ssh -o StrictHostKeyChecking=no ramanuj@45.248.67.9

# Verify inventory configuration
ansible-inventory -i inventory --list
```

#### 2. Kubeconfig Issues
```bash
# Check kubeconfig on target node
ansible -i inventory kubernetes_nodes -a "ls -la ~/.kube/config"
ansible -i inventory kubernetes_nodes -a "kubectl cluster-info"
```

#### 3. Permission Issues
```bash
# Check user permissions
ansible -i inventory kubernetes_nodes -a "whoami"
ansible -i inventory kubernetes_nodes -a "kubectl auth can-i '*' '*' --all-namespaces"
```

#### 4. Collection Not Found
```bash
# Reinstall collection
ansible-galaxy collection install padminisys-nginx_ingress-*.tar.gz --force

# Verify installation path
ansible-galaxy collection list
```

## Manual Verification

After successful installation, you can manually verify:

### 1. Check Kubernetes Resources
```bash
# On target node
kubectl get all -n ingress-nginx
kubectl get ingress -A
```

### 2. Test Ingress Controller
```bash
# Create a test ingress
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
  namespace: default
spec:
  ingressClassName: nginx
  rules:
  - host: test.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: test-service
            port:
              number: 80
EOF
```

### 3. Access Nginx Ingress
```bash
# Test HTTP endpoint
curl -I http://45.248.67.9:30080/healthz

# Test with custom host header
curl -H "Host: test.local" http://45.248.67.9:30080
```

## Cleanup

To remove the nginx ingress controller:

```bash
# Using kubectl
kubectl delete namespace ingress-nginx

# Or using Helm (if helm is installed)
helm uninstall ingress-nginx -n ingress-nginx
```

## File Structure

```
tests/
├── ansible.cfg          # Ansible configuration for testing
├── inventory           # Target node inventory
└── nginx.yml          # Main test playbook
```

## Support

For issues or questions:
- Check the main [README.md](README.md)
- Review role documentation: [roles/nginx/README.md](roles/nginx/README.md)
- Create an issue in the project repository