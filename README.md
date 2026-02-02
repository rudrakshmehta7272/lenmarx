# LENMARX Sovereign Blockchain

Production-ready Layer-1 blockchain built on Cosmos SDK and CometBFT.

## Quick Start

### Prerequisites
- Go 1.25+
- Cosmos SDK v0.53.5
- CometBFT v0.38.21

### Build

```bash
make build
# or
go build ./cmd/lenmarxd -o ./lenmarxd
```

### Install

```bash
make install
# or
go install ./cmd/lenmarxd
```

### Initialize Node

```bash
lenmarxd init <moniker> --chain-id lenmarx-1 --home ~/.lenmarx
```

### Copy Genesis

```bash
cp genesis/genesis.json ~/.lenmarx/config/genesis.json
```

### Start Node

```bash
lenmarxd start --home ~/.lenmarx
```

## Chain Specifications

| Parameter | Value |
|-----------|-------|
| Chain ID | lenmarx-1 |
| Binary | lenmarxd |
| Address Prefix | lmx |
| Native Coin | LMX |
| Base Denom | ulmx |
| Consensus | Proof of Stake (CometBFT) |

## Token Economics

### Supply
- **Initial Supply**: 1,000,000,000 LMX (1 billion)
- **Base Unit**: ulmx
- **Display Unit**: lmx (1 LMX = 1,000,000 ulmx)

### Inflation
- **Target**: 6%
- **Min**: 3%
- **Max**: 10%
- **Rate Change**: 13% per year
- **Goal Bonded**: 67%
- **Blocks/Year**: 5,256,000

### Distribution
- **Validator + Delegator Rewards**: 80%
- **Community Pool**: 20%

## Staking Parameters

- **Max Validators**: 100
- **Unbonding Period**: 21 days (1,814,400 seconds)
- **Min Self-Delegation**: 1 LMX
- **Historical Entries**: 10,000

## Slashing Parameters

- **Signed Blocks Window**: 10,000 blocks
- **Min Signed %**: 95%
- **Downtime Slash**: 0.01%
- **Double-Sign Slash**: 5%
- **Downtime Jail**: 600 seconds

## Governance

- **Voting Period**: 14 days (1,209,600 seconds)
- **Deposit Period**: 14 days
- **Min Deposit**: 10,000 LMX
- **Quorum**: 40%
- **Pass Threshold**: 50%
- **Veto Threshold**: 33.4%

## Modules Included

### Core Modules
- `auth` - Account management and signature verification
- `bank` - Token transfers and balance management
- `staking` - Proof of Stake validator management
- `slashing` - Validator slashing and downtime penalties
- `distribution` - Validator and delegator reward distribution
- `mint` - Inflation and token minting
- `gov` - On-chain governance
- `params` - Protocol parameter management

### Infrastructure Modules
- `upgrade` - In-place chain upgrades
- `evidence` - Equivocation evidence handling

### Disabled Modules
- WASM/Smart Contracts
- EVM
- NFTs
- Bridges
- Oracles
- IBC (code present but disabled at genesis)

## Development

### Run Tests
```bash
make test
```

### Format Code
```bash
make fmt
```

### Run Linters
```bash
make lint
```

### Clean Build
```bash
make clean
```

## Multi-Validator Testnet

Initialize validator nodes:

```bash
lenmarxd init validator1 --chain-id lenmarx-1
lenmarxd init validator2 --chain-id lenmarx-1
lenmarxd init validator3 --chain-id lenmarx-1
```

Generate genesis transactions from each validator:

```bash
lenmarxd gentx <name> <amount>ulmx --chain-id lenmarx-1
```

Collect genesis transactions:

```bash
lenmarxd collect-gentxs
```

## Security Audit Checklist

- [x] Deterministic state machine
- [x] No hardcoded private keys
- [x] No unsafe math operations
- [x] Idiomatic Go code
- [x] Cosmos SDK best practices followed
- [x] Proper encoding/decoding
- [x] Module isolation and encapsulation
- [x] Genesis validation enforced

## License

Apache 2.0
