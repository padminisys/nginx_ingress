#!/bin/bash
# SPDX-License-Identifier: MIT-0
# Development Environment Setup Script for Nginx Ingress Collection

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

print_status "Setting up development environment for nginx ingress collection..."

# Check if we're in the right directory
if [[ ! -f "galaxy.yml" ]]; then
    print_error "galaxy.yml not found. Please run this script from the collection root directory."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [[ ! -d ".venv" ]]; then
    print_status "Creating Python virtual environment..."
    python3 -m venv .venv
    print_success "Virtual environment created"
else
    print_status "Virtual environment already exists"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
python -m pip install --upgrade pip

# Install requirements
print_status "Installing Python requirements..."
if [[ -f "requirements.txt" ]]; then
    pip install -r requirements.txt
    print_success "Requirements installed successfully"
else
    print_error "requirements.txt not found"
    exit 1
fi

# Install required collections
print_status "Installing required Ansible collections..."
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install ansible.posix
print_success "Collections installed successfully"

# Verify installation
print_status "Verifying installation..."
python -c "import kubernetes; print(f'✅ kubernetes library version: {kubernetes.__version__}')"
ansible --version | head -n 1
print_success "Environment setup completed successfully!"

echo
print_status "🚀 Development environment is ready!"
print_status "To activate the environment in future sessions, run:"
print_status "  source .venv/bin/activate"
echo
print_status "To test the collection, run:"
print_status "  ./test-nginx-ingress.sh"