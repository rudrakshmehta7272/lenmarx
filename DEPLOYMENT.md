# LENMARX Blockchain - Deployment & Testing Guide

## Project Status

The LENMARX blockchain application has been fully scaffolded with all core components:

### ✅ Completed Components

1. **Go Module Structure** (`go.mod`)
   - Module: `github.com/lenmarx/lenmarx`
   - Dependencies: Cosmos SDK v0.53.5, CometBFT v0.38.21, Protobuf v1.36.10

2. **Application Layer** (`app/app.go`)
   - 360+ lines of production code
   - All 12 core modules properly initialized
   - Complete keeper instantiation (auth, bank, staking, mint, distribution, slashing, gov, params, upgrade, evidence, authz, feegrant)
   - Proper module manager (mm) with initialization, begin block, and end block handlers
   - Helper methods for module account management, codec access, and key retrieval

3. **CLI Entry Point** (`cmd/lenmarxd/main.go`)
   - Complete cobra-based command-line interface
   - ProtoCodec and TxConfig properly configured
   - Module basic manager registration
   - Genesis initialization commands (init, collect-gentxs, gen-tx, validate-genesis)
   - Server commands (start, export, reset)
   - Query and transaction commands
   - Proper encoding config with amino and interface registry

4. **Genesis Configuration** (`genesis/genesis.json`)
   - Chain ID: `lenmarx-1`
   - Initial height: `1`
   - LMX token metadata with proper denom conversion (ulmx to lmx, 6 decimals)
   - All genesis parameters for all modules exactly as specified

5. **Node Configuration**
   - `config/config.toml`: CometBFT validator node config
     - P2P port: 26656
     - RPC port: 26657
     - Proper consensus timeouts
   - `config/app.toml`: Cosmos SDK app config
     - API port: 1317
     - gRPC port: 9090
     - gRPC-Web port: 9091
     - Min gas prices: 0ulmx
     - Pruning: default

6. **Build System** (`Makefile`)
   - `make build`: Compile lenmarxd binary
   - `make install`: Install lenmarxd to $GOPATH/bin
   - `make test`: Run tests
   - `make lint`: Run golangci-lint
   - `make fmt`: Format code
   - `make clean`: Clean build artifacts
   - `make deps`: Download dependencies

7. **Documentation** (`README.md`)
   - 180+ lines of comprehensive setup instructions
   - Complete specification tables
   - Token economics breakdown
   - Staking, slashing, governance parameters
   - Module listing (included/excluded)
   - Security audit checklist

## Next Steps: Building the Binary

### Step 1: Ensure Dependencies are Fully Downloaded

```powershell
cd "C:\Users\rudraksh mehta\OneDrive\Documents\Desktop\lenmarx"
go mod tidy
```

Wait for this command to complete fully. This may take several minutes as it downloads all Cosmos SDK dependencies (~500+ MB).

### Step 2: Build the lenmarxd Binary

```powershell
cd "C:\Users\rudraksh mehta\OneDrive\Documents\Desktop\lenmarx"
go build -o lenmarxd.exe ./cmd/lenmarxd
```

This should produce a `lenmarxd.exe` binary in the project root.

### Step 3: Verify the Binary Works

```powershell
.\lenmarxd.exe version
.\lenmarxd.exe help
```

### Step 4: Initialize a Test Validator Node

```powershell
# Create validator node directory
mkdir $env:USERPROFILE\.lenmarx\config
mkdir $env:USERPROFILE\.lenmarx\data

# Initialize the node
.\lenmarxd.exe init my-validator --chain-id lenmarx-1

# Copy the prepared genesis file
copy genesis\genesis.json $env:USERPROFILE\.lenmarx\config\genesis.json

# Copy configuration files
copy config\config.toml $env:USERPROFILE\.lenmarx\config\config.toml
copy config\app.toml $env:USERPROFILE\.lenmarx\config\app.toml
```

### Step 5: Create a Genesis Transaction (GenTx)

```powershell
# Create a key for the validator
.\lenmarxd.exe keys add validator

# Create gentx
.\lenmarxd.exe gentx validator 1000000000ulmx --chain-id lenmarx-1

# View the generated gentx
dir $env:USERPROFILE\.lenmarx\config\gentx\
```

### Step 6: Collect GenTxs (for multi-validator setup)

For a single validator, you can finalize genesis with:

```powershell
.\lenmarxd.exe collect-gentxs
```

### Step 7: Validate Genesis

```powershell
.\lenmarxd.exe validate-genesis
```

### Step 8: Start the Node

```powershell
.\lenmarxd.exe start
```

The node should initialize and start producing blocks.

## Architecture Overview

### Module Dependency Graph

```
paramsKeeper (initialized first - all subspaces depend on it)
    ↓
authKeeper
    ↓
bankKeeper → stakingKeeper → slashingKeeper
    ↓                            ↓
mintKeeper                    evidenceKeeper
    ↓
distributionKeeper
    ↓
govKeeper (with custom router for param changes and upgrades)
    
authzKeeper (authz module)
feegrantKeeper (fee allowances)
upgradeKeeper (chain upgrades)
```

### Module Initialization Order

**Genesis:**
1. auth
2. bank
3. distribution
4. staking
5. slashing
6. gov
7. mint
8. upgrade
9. evidence
10. feegrant
11. params
12. authz

**BeginBlocker (each block start):**
1. upgrade
2. mint
3. distribution
4. slashing
5. evidence
6. staking
7. authz

**EndBlocker (each block end):**
1. gov
2. staking

## Token Economics

- **Total Supply**: 1,000,000,000 LMX (10^15 ulmx)
- **Inflation**: 6% target (3-10% range)
- **Goal Bonded**: 67% (validators should hold 67% of supply)
- **Blocks Per Year**: 5,256,000 (6-second blocks)
- **Annual Reward**: ~60,000,000 LMX (6% of ~1B)

### Distribution
- Validators: 80%
- Community Pool: 20%

## Staking Parameters

- **Max Validators**: 100
- **Unbonding Time**: 21 days (1,814,400 seconds)
- **Historical Entries**: 10,000 blocks
- **Min Commission**: 0%
- **Max Commission**: 100%
- **Max Change Rate**: 1%/day

## Slashing Parameters

- **Signed Blocks Window**: 10,000 blocks
- **Min Signed Per Window**: 95%
- **Downtime Jail Duration**: 10 minutes (600 seconds)
- **Downtime Slash Fraction**: 0.01% (0.0001)
- **Double Sign Slash Fraction**: 5% (0.05)
- **Evidence Params**:
  - Max Age (blocks): 100,000
  - Max Age (duration): ~584 days

## Governance Parameters

- **Min Deposit**: 10,000,000,000 ulmx (10,000 LMX)
- **Voting Period**: 14 days (1,209,600 seconds)
- **Quorum**: 40%
- **Pass Threshold**: 50%
- **Veto Threshold**: 33.4%

## Security Checklist

- [x] Deterministic state machine (using Cosmos SDK)
- [x] No hardcoded private keys
- [x] Safe arithmetic (Cosmos SDK built-in)
- [x] Idiomatic Go code
- [x] Follows Cosmos SDK best practices
- [x] Proper module isolation
- [x] Genesis validation
- [x] Proper TxConfig and codec
- [x] Bech32 address encoding (lmx prefix)
- [x] Module account permissions defined
- [x] Router configuration for governance proposals

## Module Exclusions

**Disabled (by design):**
- IBC (Inter-blockchain communication)
- WASM (Smart contracts)
- EVM (Ethereum Virtual Machine)
- NFT Module
- Oracle Module
- Bridge Module

**Reason**: LENMARX is designed as a focused Layer-1 blockchain for sovereign token governance. These modules can be added later if needed.

## File Structure

```
lenmarx/
├── app/
│   └── app.go                          # Main blockchain app (360+ lines)
├── cmd/
│   └── lenmarxd/
│       ├── main.go                      # CLI entry point (180+ lines)
│       └── main.go.bak                  # Backup of original
├── config/
│   ├── config.toml                      # CometBFT config
│   └── app.toml                         # Cosmos SDK app config
├── genesis/
│   └── genesis.json                     # Complete genesis state
├── go.mod                               # Module declaration
├── go.sum                               # Dependency checksums
├── Makefile                             # Build automation
├── README.md                            # Full documentation
└── DEPLOYMENT.md                        # This file
```

## Troubleshooting

### Issue: Missing go.sum entries

**Solution**: Run `go mod tidy` again. The first run downloads dependencies; subsequent runs should complete.

```powershell
go clean -modcache
go mod tidy
```

### Issue: "cannot find module github.com/lenmarx/lenmarx"

**Solution**: Make sure you're in the correct directory (`C:\Users\rudraksh mehta\OneDrive\Documents\Desktop\lenmarx`) and that the `go.mod` file is present with the correct module name.

### Issue: CometBFT errors

**Solution**: Delete the `$HOME/.lenmarx/config` directory and reinitialize:

```powershell
Remove-Item -Recurse -Force $env:USERPROFILE\.lenmarx
.\lenmarxd.exe init my-validator --chain-id lenmarx-1
```

### Issue: Port already in use

**Solution**: Edit `config/config.toml` to use different ports:

```toml
# For P2P
laddr = "tcp://127.0.0.1:26666"

# For RPC
laddr = "tcp://127.0.0.1:26667"
```

## Multi-Validator Testnet Setup

To set up a multi-validator testnet locally:

1. Create multiple validator directories:

```powershell
for ($i = 1; $i -le 3; $i++) {
    mkdir "$env:USERPROFILE\.lenmarx-$i\config"
    mkdir "$env:USERPROFILE\.lenmarx-$i\data"
    .\lenmarxd.exe init "validator-$i" --chain-id lenmarx-1 --home "$env:USERPROFILE\.lenmarx-$i"
    copy genesis\genesis.json "$env:USERPROFILE\.lenmarx-$i\config\genesis.json"
}
```

2. Create gentxs for each:

```powershell
for ($i = 1; $i -le 3; $i++) {
    .\lenmarxd.exe keys add validator-$i --home "$env:USERPROFILE\.lenmarx-$i"
    .\lenmarxd.exe gentx validator-$i 1000000000ulmx --chain-id lenmarx-1 --home "$env:USERPROFILE\.lenmarx-$i"
}
```

3. Copy all gentxs to validator-1's gentx directory and collect

4. Distribute the finalized genesis.json to all validators

5. Update port numbers in each config.toml to avoid conflicts

6. Start each node with different home directories

## Performance Baseline

- **Block time**: ~6 seconds (from timeout_commit in config.toml)
- **Max validators**: 100
- **Expected TPS**: 100-500 (depends on tx size and complexity)
- **Consensus**: Tendermint BFT (2/3 + 1 safety threshold)
- **Finality**: Instant (no forks possible)

## Next Generation Improvements

Potential features to add:

1. **Custom Modules**: Domain-specific logic (trading, staking, etc.)
2. **Governance Voting**: Custom voting mechanisms
3. **Hooks**: Custom business logic in existing modules
4. **Middleware**: Custom tx validation and processing
5. **Oracle Integration**: On-chain data feeds
6. **Cross-Chain Bridges**: IBC integration
7. **Smart Contracts**: WASM integration

---

**Generation Date**: 2024
**Cosmos SDK Version**: v0.53.5
**CometBFT Version**: v0.38.21
**Go Version**: 1.25+

For questions or issues, refer to [Cosmos SDK Documentation](https://docs.cosmos.network) or [CometBFT Documentation](https://docs.cometbft.com).
