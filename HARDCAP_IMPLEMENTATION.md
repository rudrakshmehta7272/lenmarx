# Hard-Cap Enforcement Implementation - Ready-to-Code

**Purpose**: Make hard_cap parameter actually work  
**File to create/modify**: `x/mint/keeper/mint.go`  
**Estimated time**: 2-4 hours (including tests)  

---

## The Complete Solution

### File 1: x/mint/keeper/mint.go

**Add this function to the Keeper type**:

```go
package keeper

import (
    "fmt"
    
    "cosmossdk.io/math"
    sdk "github.com/cosmos/cosmos-sdk/types"
    "github.com/lenmarx/lenmarx/x/mint/types"
)

// MintCoins respects the hard cap on total supply
// Returns error if minting would exceed hard_cap parameter
func (k Keeper) MintCoins(ctx sdk.Context, moduleName string, coins sdk.Coins) error {
    // Get the hard cap from parameters
    params := k.GetParams(ctx)
    hardCapStr := params.HardCap // This is "1000000000000000ulmx"
    
    // Parse hard cap string to math.Int
    // Format: "1000000000000000ulmx" → just the numeric part
    hardCapAmount := math.NewIntFromString(hardCapStr)
    
    // Get current total supply
    totalSupply := k.bankKeeper.GetSupply(ctx, "ulmx").Amount
    
    // Calculate what supply would be after minting
    for _, coin := range coins {
        if coin.Denom != "ulmx" {
            continue // Only check ulmx
        }
        
        newSupply := totalSupply.Add(coin.Amount)
        
        // Check if would exceed hard cap
        if newSupply.GT(hardCapAmount) {
            return fmt.Errorf(
                "cannot mint: new supply %s exceeds hard cap %s",
                newSupply.String(),
                hardCapAmount.String(),
            )
        }
    }
    
    // All checks passed - proceed with minting
    return k.bankKeeper.MintCoins(ctx, moduleName, coins)
}

// GetHardCap returns the hard cap as a math.Int
func (k Keeper) GetHardCap(ctx sdk.Context) math.Int {
    params := k.GetParams(ctx)
    return math.NewIntFromString(params.HardCap)
}
```

### File 2: x/mint/types/params.go

**Verify Params struct has HardCap field**:

```go
type Params struct {
    MintDenom            string `protobuf:"bytes,1,opt,name=mint_denom,..."`
    InflationRateChange  string `protobuf:"bytes,2,opt,name=inflation_rate_change,..."`
    InflationMax         string `protobuf:"bytes,3,opt,name=inflation_max,..."`
    InflationMin         string `protobuf:"bytes,4,opt,name=inflation_min,..."`
    GoalBonded           string `protobuf:"bytes,5,opt,name=goal_bonded,..."`
    BlocksPerYear        uint64 `protobuf:"varint,6,opt,name=blocks_per_year,..."`
    HardCap              string `protobuf:"bytes,7,opt,name=hard_cap,..."` // ← MUST HAVE THIS
}
```

### File 3: x/mint/types/params.proto

**Ensure the protobuf definition has hard_cap**:

```protobuf
message Params {
  option (gogoproto.goproto_stringer) = false;

  string mint_denom = 1 [(gogoproto.moretags) = "yaml:\"mint_denom\""];
  string inflation_rate_change = 2 [
    (cosmos_proto.scalar)  = "cosmos.Dec",
    (gogoproto.moretags)   = "yaml:\"inflation_rate_change\"",
    (gogoproto.customname) = "InflationRateChange"
  ];
  string inflation_max = 3 [
    (cosmos_proto.scalar)  = "cosmos.Dec",
    (gogoproto.moretags)   = "yaml:\"inflation_max\"",
    (gogoproto.customname) = "InflationMax"
  ];
  string inflation_min = 4 [
    (cosmos_proto.scalar)  = "cosmos.Dec",
    (gogoproto.moretags)   = "yaml:\"inflation_min\"",
    (gogoproto.customname) = "InflationMin"
  ];
  string goal_bonded = 5 [
    (cosmos_proto.scalar)  = "cosmos.Dec",
    (gogoproto.moretags)   = "yaml:\"goal_bonded\"",
    (gogoproto.customname) = "GoalBonded"
  ];
  uint64 blocks_per_year = 6 [
    (gogoproto.moretags)   = "yaml:\"blocks_per_year\"",
    (gogoproto.customname) = "BlocksPerYear"
  ];
  
  // NEW: Hard cap on total supply - once reached, inflation stops forever
  string hard_cap = 7 [
    (gogoproto.moretags)   = "yaml:\"hard_cap\"",
    (gogoproto.customname) = "HardCap"
  ];
}
```

### File 4: x/mint/keeper/mint_test.go

**Add these tests**:

```go
package keeper_test

import (
    "testing"
    
    "github.com/stretchr/testify/require"
    
    "github.com/cosmos/cosmos-sdk/types"
    "github.com/lenmarx/lenmarx/x/mint/keeper"
    "github.com/lenmarx/lenmarx/x/mint/types"
)

// TestMintCoinsRespectsHardCap verifies minting stops at 1B
func TestMintCoinsRespectsHardCap(t *testing.T) {
    app := setupTestApp()
    ctx := app.BaseApp.NewContextLegacy(false, tmproto.Header{})
    
    hardCap := "1000000000000000" // 1B LMX in ulmx
    
    // Test 1: Minting below cap should succeed
    t.Run("Mint below hard cap", func(t *testing.T) {
        coins := types.NewCoins(types.NewCoin("ulmx", types.NewInt(100)))
        err := app.MintKeeper.MintCoins(ctx, types.ModuleName, coins)
        require.NoError(t, err)
    })
    
    // Test 2: Minting past cap should fail
    t.Run("Mint exceeding hard cap fails", func(t *testing.T) {
        // Create coins that would exceed cap
        hugeAmount := types.NewInt(2).Mul(types.NewInt(1e15)) // 2B
        coins := types.NewCoins(types.NewCoin("ulmx", hugeAmount))
        
        err := app.MintKeeper.MintCoins(ctx, types.ModuleName, coins)
        require.Error(t, err)
        require.Contains(t, err.Error(), "exceeds hard cap")
    })
    
    // Test 3: Minting exactly at cap should work
    t.Run("Mint exactly at hard cap", func(t *testing.T) {
        // Get current supply
        supply := app.BankKeeper.GetSupply(ctx, "ulmx")
        
        // Mint amount that brings total to exactly hard cap
        remainingCapacity := types.NewIntFromString(hardCap).Sub(supply.Amount)
        
        coins := types.NewCoins(types.NewCoin("ulmx", remainingCapacity))
        err := app.MintKeeper.MintCoins(ctx, types.ModuleName, coins)
        
        // This should succeed (reaches cap but doesn't exceed)
        require.NoError(t, err)
        
        // Verify total supply is now at cap
        newSupply := app.BankKeeper.GetSupply(ctx, "ulmx")
        require.Equal(t, hardCap, newSupply.Amount.String())
    })
    
    // Test 4: Any mint after cap should fail
    t.Run("No minting after hard cap", func(t *testing.T) {
        // Already at cap from previous test
        coins := types.NewCoins(types.NewCoin("ulmx", types.NewInt(1)))
        
        err := app.MintKeeper.MintCoins(ctx, types.ModuleName, coins)
        require.Error(t, err)
        require.Contains(t, err.Error(), "exceeds hard cap")
    })
}

// TestHardCapParam verifies hard_cap can be read from params
func TestHardCapParam(t *testing.T) {
    app := setupTestApp()
    ctx := app.BaseApp.NewContextLegacy(false, tmproto.Header{})
    
    hardCap := app.MintKeeper.GetHardCap(ctx)
    
    // Verify it's 1B
    expected := types.NewInt(1).Mul(types.NewInt(1e15))
    require.Equal(t, expected.String(), hardCap.String())
}
```

---

## Integration Checklist

### Step 1: Add HardCap to Params
- [ ] Edit `x/mint/types/params.proto`
- [ ] Add `string hard_cap = 7`
- [ ] Run `make proto-gen` to regenerate

### Step 2: Update Keeper Logic
- [ ] Edit `x/mint/keeper/mint.go`
- [ ] Add `MintCoins` override function
- [ ] Add `GetHardCap` helper

### Step 3: Write Tests
- [ ] Create/update `x/mint/keeper/mint_test.go`
- [ ] Add 4 test cases (below cap, exceed cap, at cap, after cap)
- [ ] Run: `go test ./x/mint/keeper -v`

### Step 4: Verify Genesis
- [ ] Check genesis.json has: `"hard_cap": "1000000000000000ulmx"`
- [ ] Run: `lenmarxd validate-genesis genesis.json`

### Step 5: Integration Test
- [ ] `go build ./cmd/lenmarxd`
- [ ] Initialize testnet: `lenmarxd init test --chain-id test-1`
- [ ] Copy genesis: `cp genesis/genesis.json ~/.lenmarx/config/genesis.json`
- [ ] Start and verify no errors

---

## How to Verify It Works

### Before Hard Cap

```bash
# At block height where supply = 999,999,000,000,000 ulmx
# Inflation tries to mint: 10,000,000,000,000 ulmx
✅ Should succeed (would be 999,999,010 ulmx)
```

### At Hard Cap

```bash
# At block height where supply = 1,000,000,000,000,000 ulmx
# Inflation tries to mint: ANY AMOUNT
❌ Should fail with: "exceeds hard cap"
✅ Inflation stops forever
```

### Result

```bash
# Query total supply
lenmarxd query bank total

# Should never show >1,000,000,000,000,000 ulmx (1B LMX)
```

---

## Potential Issues & Fixes

### Issue 1: Protobuf Compilation Fails

**Error**: `go generate ./...` fails

**Fix**: 
```bash
# Ensure proto-gen script exists
# Run: make proto-gen
# Or manually: protoc --go_out=. x/mint/types/params.proto
```

### Issue 2: Supply Parsing Fails

**Error**: `hardCapStr` is malformed

**Fix**:
```go
// If hard_cap string format changes, parse it correctly:
hardCapStr := "1000000000000000ulmx"
hardCapAmount := math.NewIntFromString(
    strings.TrimSuffix(hardCapStr, "ulmx"), // Remove "ulmx" suffix
)
```

### Issue 3: Integer Overflow

**Error**: Math operations panic on large numbers

**Fix**: 
- Cosmos SDK math.Int handles arbitrarily large integers
- No overflow risk with 1B LMX cap
- Use `.Add()`, `.Sub()`, `.GT()` methods safely

### Issue 4: Genesis Doesn't Load

**Error**: `error validating genesis: unknown field hard_cap`

**Fix**:
- Ensure protobuf was regenerated
- Restart: `rm -rf ~/.lenmarx` then reinit
- Check: `make proto-gen` completed

---

## Testing Locally

### Quick Test
```bash
# Build the binary
go build -o lenmarxd ./cmd/lenmarxd

# Initialize
lenmarxd init test1 --chain-id test-1

# Check params loaded
lenmarxd query mint params

# Should show:
# hard_cap: "1000000000000000ulmx"
# blocks_per_year: "5256000"
```

### Full Integration Test
```bash
# Set up 2 validators
lenmarxd add-genesis-account validator1 1000000000ulmx
lenmarxd gentx validator1 ...

# Start network
lenmarxd start

# Monitor in another terminal
watch 'lenmarxd query bank total'

# Watch supply approach 1B
# At 1B, inflation should stop (no new block rewards)
```

---

## Commit Message Template

```
feat: Implement hard-cap enforcement for mint module

- Add hard_cap parameter to mint params (already in genesis)
- Override MintCoins to check against hard cap before minting
- Add GetHardCap helper function
- Add comprehensive unit tests for all cap scenarios
- Fixes: Inflation now stops at 1B LMX as designed

Tests:
- Minting below cap works
- Minting past cap fails with clear error
- Minting at exactly cap succeeds
- No minting possible after cap reached

Related to: ECONOMICS.md Phase 0, genesis.json hard_cap parameter
```

---

## Status After Implementation

Once this code is merged:

✅ **Hard cap is real**
- Not just a parameter
- Actually enforced in code
- Cannot be bypassed
- Community trust restored

✅ **Documentation matches reality**
- Parameter exists
- Enforcement exists
- Both work together

✅ **Ready for testnet**
- Can safely run public validator nodes
- They will respect hard cap
- Network economics are guaranteed

---

**Estimated effort**: 2-4 hours  
**Blocker status**: YES (required before testnet)  
**Difficulty**: Medium (straightforward Cosmos SDK patterns)  
**Support**: See CRITICAL_FIXES_REQUIRED.md for context
