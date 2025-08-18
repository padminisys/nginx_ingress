#!/bin/bash
# SPDX-License-Identifier: MIT-0
# Quick test script for nginx ingress collection

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [[ ! -f "galaxy.yml" ]]; then
    print_error "galaxy.yml not found. Please run this script from the collection root directory."
    exit 1
fi

# Check if virtual environment exists
if [[ ! -d ".venv" ]]; then
    print_warning "Virtual environment not found. Setting up development environment first..."
    if [[ -f "setup-dev-env.sh" ]]; then
        ./setup-dev-env.sh
    else
        print_error "setup-dev-env.sh not found. Please run setup manually."
        exit 1
    fi
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source .venv/bin/activate

# Verify Python environment
print_status "Verifying Python environment..."
python -c "import kubernetes; print(f'✅ kubernetes library available: {kubernetes.__version__}')" || {
    print_error "kubernetes library not found. Please run ./setup-dev-env.sh first"
    exit 1
}

print_status "Starting nginx ingress collection test workflow..."

# Step 1: Build the collection
print_status "Step 1: Building the collection..."
if ansible-galaxy collection build --force; then
    print_success "Collection built successfully"
else
    print_error "Failed to build collection"
    exit 1
fi

# Step 2: Install the collection
print_status "Step 2: Installing the collection..."
COLLECTION_FILE=$(ls padminisys-nginx_ingress-*.tar.gz | head -n1)
if [[ -f "$COLLECTION_FILE" ]]; then
    print_status "Installing $COLLECTION_FILE"
    if ansible-galaxy collection install "$COLLECTION_FILE" --force; then
        print_success "Collection installed successfully"
    else
        print_error "Failed to install collection"
        exit 1
    fi
else
    print_error "Collection tarball not found"
    exit 1
fi

# Step 3: Verify collection installation
print_status "Step 3: Verifying collection installation..."
if ansible-galaxy collection list padminisys.nginx_ingress >/dev/null 2>&1; then
    print_success "Collection verification successful"
    ansible-galaxy collection list padminisys.nginx_ingress
else
    print_warning "Collection verification failed, but continuing..."
fi

# Step 4: Test connectivity
print_status "Step 4: Testing connectivity to target node..."
cd tests
if ansible -i inventory kubernetes_nodes -m ping; then
    print_success "Connectivity test successful"
else
    print_error "Connectivity test failed"
    print_error "Please check:"
    print_error "  - Target node is accessible"
    print_error "  - SSH credentials are correct"
    print_error "  - Inventory file is properly configured"
    exit 1
fi

# Step 5: Run the test playbook
print_status "Step 5: Running nginx ingress installation test..."
print_warning "This may take several minutes..."

if ansible-playbook -i inventory nginx.yml -v; then
    print_success "🎉 Nginx ingress installation test completed successfully!"
    echo
    print_status "Access URLs:"
    print_status "  HTTP:  http://TARGET_NODE_IP:30080"
    print_status "  HTTPS: https://TARGET_NODE_IP:30443"
    print_status "  Health: http://TARGET_NODE_IP:30080/healthz"
    echo
    print_status "To verify installation manually:"
    print_status "  ssh USER@TARGET_NODE_IP 'kubectl get all -n ingress-nginx'"
    print_status "  (Replace TARGET_NODE_IP with your actual node IP address)"
else
    print_error "Test playbook execution failed"
    print_error "Check the output above for details"
    exit 1
fi

print_success "All tests completed successfully! 🚀"