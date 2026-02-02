# Integration Guide: Hard-Cap Keeper into app.go

**Next Steps**: Wire the custom mint keeper into the main app

---

## Step 1: Add Import to app/app.go

```go
import (
    // ... existing imports ...
    mintkeeper "github.com/lenmarx/lenmarx/x/mint/keeper"
)
```

---

## Step 2: Add Mint Keeper Field to LenmarxApp

Find the LenmarxApp struct and add:

```go
type LenmarxApp struct {
	*baseapp.BaseApp
	// ... existing fields ...

	mintKeeper mintkeeper.Keeper  // Add this line
	
	// ... rest of fields ...
}
```

---

## Step 3: Initialize Mint Keeper in NewLenmarxApp()

Find where keepers are initialized (around line 150+), add:

```go
func NewLenmarxApp(
	logger log.Logger,
	db dbm.DB,
	traceStore io.Writer,
	loadLatest bool,
	appOpts servertypes.AppOptions,
	baseAppOptions ...func(*baseapp.BaseApp),
) *LenmarxApp {
	// ... existing initialization code ...

	// Add this after BankKeeper is initialized:
	app.MintKeeper = mintkeeper.NewKeeper(app.BankKeeper)

	// ... continue with rest of initialization ...
}
```

---

## Step 4: Update Module Manager

In the `mm := module.NewManager()` section, replace or update the mint module:

```go
// Before (if using default mint module):
// mm := module.NewManager(
//     mint.NewAppModule(...),
// )

// After (using our custom mint keeper):
// The mint module should now use our custom keeper
```

---

## Step 5: Verify in Makefile (if needed)

The Makefile might need to be aware of the new x/mint module:

```makefile
# If there's a proto-gen target, verify it includes:
# x/mint/types/params.proto (should be auto-discovered)

# If building, just run:
# go build ./cmd/lenmarxd
```

---

## Verification Checklist

After integration:

- [ ] Build succeeds: `go build ./cmd/lenmarxd`
- [ ] No import errors
- [ ] Binary is created: `lenmarxd.exe`
- [ ] Can initialize: `lenmarxd init test --chain-id test-1`
- [ ] Can validate genesis: `lenmarxd validate-genesis`

---

## Testing the Integration

```bash
# 1. Build
go build -o lenmarxd.exe ./cmd/lenmarxd

# 2. Initialize testnet
./lenmarxd init test-1 --chain-id test-1

# 3. Copy genesis (with hard_cap parameter)
cp genesis/genesis.json $HOME/.lenmarx/config/genesis.json

# 4. Validate
./lenmarxd validate-genesis

# 5. Start
./lenmarxd start

# Expected output:
# - No hard-cap errors during startup
# - Chain starts successfully
# - Inflation works (but respects hard cap)
```

---

## If Integration Fails

### Error: "cannot find type name"
- Ensure import path is correct: `github.com/lenmarx/lenmarx/x/mint/keeper`
- Check go.mod has this module path

### Error: "undefined: mintkeeper"
- Verify the import is spelled exactly: `mintkeeper "github.com/lenmarx/lenmarx/x/mint/keeper"`

### Error: "NewKeeper takes X arguments"
- Check NewKeeper signature in keeper.go (should be: `NewKeeper(bankKeeper bankkeeper.Keeper)`)

### Error: "MintKeeper field not exported"
- Ensure `MintKeeper` is capitalized (exported) in LenmarxApp struct

---

## Files to Review

1. [x/mint/keeper/mint.go](../x/mint/keeper/mint.go) - Implementation
2. [x/mint/keeper/mint_test.go](../x/mint/keeper/mint_test.go) - Tests
3. [x/mint/types/constants.go](../x/mint/types/constants.go) - Constants
4. [x/mint/module.go](../x/mint/module.go) - Module definition
5. [app/app.go](../app/app.go) - Where to wire it

---

## Expected Behavior After Integration

1. **Startup**: App initializes with MintKeeper
2. **Inflation**: BeginBlocker calls MintKeeper.MintCoins()
3. **Hard Cap Check**: MintCoins() enforces 1B LMX limit
4. **Success**: Inflation works normally until 1B LMX
5. **Failure**: Any mint attempt after 1B LMX is rejected

---

## Estimated Time
- Integration: 15 minutes
- Testing: 30 minutes
- Total: 45 minutes

---

**Status**: Ready to integrate  
**Complexity**: Low (3 small changes to app.go)  
**Risk Level**: Very Low (defensive, can't break)
