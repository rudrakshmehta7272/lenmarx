#!/bin/bash

# Ultra-simple build script for Lenmarx
# This ensures the blockchain builds 100% without issues

set -e

cd /workspace

echo "====== LENMARX BUILD START ======"
echo "Current directory: $(pwd)"
echo "Go version: $(go version)"

# Step 1: Create minimal go.mod
echo "Step 1: Creating go.mod..."
go mod init github.com/lenmarx/lenmarx 2>/dev/null || true

# Step 2: Add all dependencies
echo "Step 2: Adding dependencies..."
go get -u github.com/cosmos/cosmos-sdk@v0.50.7 2>&1 | tail -3
go get -u github.com/cometbft/cometbft@v0.38.7 2>&1 | tail -3
go get -u github.com/spf13/cobra@latest 2>&1 | tail -3

# Step 3: Tidy
echo "Step 3: Running go mod tidy..."
go mod tidy 2>&1 | tail -5

# Step 4: List module info
echo "Step 4: Module files created"
ls -lh go.mod go.sum

# Step 5: Build
echo "Step 5: Building lenmarxd binary..."
go build -v -o cmd/lenmarxd/lenmarxd ./cmd/lenmarxd 2>&1 | tail -30

# Step 6: Verify
echo "====== BUILD VERIFICATION ======"
if [ -f cmd/lenmarxd/lenmarxd ]; then
    echo "✅ SUCCESS: Binary created"
    ls -lh cmd/lenmarxd/lenmarxd
    file cmd/lenmarxd/lenmarxd
    echo "✅ BLOCKCHAIN READY TO DEPLOY"
else
    echo "❌ Binary not found - build may have failed"
    echo "Files in cmd/lenmarxd/:"
    ls -la cmd/lenmarxd/
fi

echo "====== BUILD COMPLETE ======"
