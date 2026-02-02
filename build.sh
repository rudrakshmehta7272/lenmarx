#!/bin/bash
set -e

cd /workspace

# Create go.mod
cat > go.mod << 'EOF'
module github.com/lenmarx/lenmarx

go 1.23

require (
	cosmossdk.io/api v0.7.4
	cosmossdk.io/core v0.12.1
	cosmossdk.io/depinject v1.0.0
	cosmossdk.io/errors v1.0.1
	cosmossdk.io/log v1.5.0
	cosmossdk.io/math v1.5.0
	cosmossdk.io/store v1.1.1
	cosmossdk.io/x/auth v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/authz v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/bank v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/capability v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/distribution v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/evidence v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/feegrant v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/gov v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/mint v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/params v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/slashing v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/staking v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/tx v0.13.0
	cosmossdk.io/x/upgrade v0.0.0-20240226161413-5c2ab2ecd32b
	github.com/cometbft/cometbft v0.38.7
	github.com/cometbft/cometbft-db v0.14.0
	github.com/cosmos/cosmos-proto v1.0.0-beta.5
	github.com/cosmos/cosmos-sdk v0.50.7
	github.com/spf13/cobra v1.8.1
)
EOF

echo "go.mod created"

# Download dependencies
go mod download
echo "Dependencies downloaded"

# Run tidy
go mod tidy
echo "go.mod tidied"

# List contents to verify
echo "=== Files in /workspace ==="
find /workspace -type f -name "*.go" | head -20

echo "=== go.mod size ==="
ls -lh go.mod

echo "=== go.sum size ==="
ls -lh go.sum

# Try to build
echo "=== Starting build ==="
go build -v -o cmd/lenmarxd/lenmarxd ./cmd/lenmarxd 2>&1 || echo "Build attempt completed"

# Check if binary exists
if [ -f cmd/lenmarxd/lenmarxd ]; then
    echo "✅ BINARY CREATED SUCCESSFULLY"
    ls -lh cmd/lenmarxd/lenmarxd
    file cmd/lenmarxd/lenmarxd
else
    echo "❌ Binary not found"
fi
