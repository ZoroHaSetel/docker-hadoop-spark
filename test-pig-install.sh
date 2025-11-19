#!/bin/bash
# Test script to verify Pig installation on Hadoop cluster

set -e

echo "=========================================="
echo "Pig Installation Verification Script"
echo "=========================================="
echo ""

# Check if docker is running
echo "[1/6] Checking Docker..."
if docker ps > /dev/null 2>&1; then
    echo "✓ Docker is running"
else
    echo "✗ Docker is not running"
    exit 1
fi

echo ""
echo "[2/6] Checking if Pig container exists..."
if docker ps -a | grep -q "pig"; then
    echo "✓ Pig container found"
else
    echo "✗ Pig container not found. Run 'docker compose up -d' first"
    exit 1
fi

echo ""
echo "[3/6] Checking Pig version..."
PIG_VERSION=$(docker exec pig pig -version 2>&1 | head -1)
if [[ $PIG_VERSION == *"Pig version"* ]]; then
    echo "✓ Pig is installed: $PIG_VERSION"
else
    echo "✗ Pig command failed"
    exit 1
fi

echo ""
echo "[4/6] Checking Hadoop connectivity..."
HDFS_TEST=$(docker exec pig hdfs dfs -ls hdfs://namenode:9000/ 2>&1)
if [[ $HDFS_TEST != *"cannot access"* ]]; then
    echo "✓ HDFS is accessible from Pig container"
else
    echo "✗ HDFS is not accessible"
    exit 1
fi

echo ""
echo "[5/6] Checking YARN connectivity..."
YARN_TEST=$(docker exec pig yarn node -list 2>&1)
if [[ $YARN_TEST != *"Error"* ]]; then
    echo "✓ YARN is accessible from Pig container"
else
    echo "⚠ YARN may not be fully initialized yet (this is normal during startup)"
fi

echo ""
echo "[6/6] Checking if sample script exists..."
if [ -f "scripts/breweries_by_state.pig" ]; then
    echo "✓ Sample Pig script found at scripts/breweries_by_state.pig"
else
    echo "⚠ Sample script not found"
fi

echo ""
echo "=========================================="
echo "Installation Verification Complete!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo "1. Run a test in local mode:"
echo "   make pig-local"
echo ""
echo "2. Or enter the Pig shell:"
echo "   make pig-shell"
echo ""
echo "3. For full documentation, see:"
echo "   - PIG_SETUP.md (comprehensive guide)"
echo "   - PIG_QUICK_REFERENCE.md (quick reference)"
echo "   - pig/README.md (container-specific info)"
echo ""
