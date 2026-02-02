# LENMARX Phase Implementation Guide

**Current Status**: Phases 0-4 complete (genesis.json updated), Phases 5-8 pending implementation  
**Timeline**: Follow in strict order, cannot reorder without breaking chain  

---

## Phase 0: Hard Cap Enforcement ✅ COMPLETE

### What Was Done
- ✅ Updated genesis.json: Added `hard_cap: "1000000000000000ulmx"` to mint.params
- ✅ Documented hard cap enforcement requirement
- ✅ Set mint rate to 0 when supply >= hard cap

### What Needs Code Integration
```go
// In x/mint/module.go BeginBlocker
if app.MintKeeper.GetSupply(ctx, "ulmx") >= app.MintKeeper.GetHardCap(ctx) {
    // Stop all minting
    return nil
}
// Continue normal minting...
```

**Test Case:**
```
When total_supply = 999,999,999,999,999 ulmx:
  - Mint new block: ✓ Allow (increments supply)

When total_supply = 1,000,000,000,000,000 ulmx:
  - Mint new block: ✗ Reject (at hard cap)
  - Inflation rate forced to 0
  - No more tokens ever created
```

---

## Phase 1: Reward Distribution ✅ PARTIAL

### What Was Done
- ✅ Updated genesis.json: distribution.params modified
- ✅ Documented 60-65% staking, 20% community, 10-15% ecosystem rewards

### What Still Needs Implementation

**Burn mechanism for gas fees:**
```go
// In x/bank/keeper.go DeductFees()
gasUsed := tx.GasUsed
gasPrice := app.GetMinGasPrice()  // 0.001 ulmx/gas

fees := gasUsed * gasPrice
burnAmount := fees * 0.40
validatorShare := fees * 0.60

// Burn 40%
app.BankKeeper.BurnCoins(ctx, types.ModuleName, coins.Mul(burnAmount))

// Credit proposer with 60%
proposerAddr := sdk.AccAddress(ctx.BlockHeader().ProposerAddress)
app.BankKeeper.SendCoinsFromModuleToAccount(ctx, types.ModuleName, proposerAddr, 
    coins.Mul(validatorShare))
```

**Test burning mechanism:**
```
Send 1,000 ulmx transaction:
  Fee = 1,000 gas × 0.001 ulmx = 1 ulmx
  Burn = 1 ulmx × 0.40 = 0.4 ulmx
  Validator gets = 1 ulmx × 0.60 = 0.6 ulmx
  
Verify:
  - Total supply decreased by 0.4 ulmx
  - Proposer account increased by 0.6 ulmx
```

---

## Phase 2: Network Defense ✅ PARTIAL

### What Was Done
- ✅ Documented min_gas_prices = 0.001 ulmx requirement
- ✅ Planned burn mechanism (Phase 1)

### What Needs Implementation

**Update app.toml:**
```toml
[tx]
gas_prices = "0.001ulmx"
timeout_propose = "3s"
timeout_prevote = "1s"
timeout_precommit = "1s"
timeout_commit = "5s"
```

**Update CometBFT config (config.toml):**
```toml
[consensus]
timeout_propose = "3s"
timeout_propose_delta = "500ms"
timeout_prevote = "1s"
timeout_prevote_delta = "500ms"
timeout_precommit = "1s"
timeout_precommit_delta = "500ms"
timeout_commit = "5s"
skip_timeout_commit = false
```

**Test minimum gas price:**
```
Try to send transaction with 0 gas price:
  ✗ Should be rejected: "gas prices too low, minimum 0.001ulmx"

Try to send transaction with 0.001 ulmx:
  ✓ Should be accepted: minimum met

Try to send transaction with 0.0001 ulmx:
  ✗ Should be rejected: below minimum
```

---

## Phase 3: Governance Hardening ✅ COMPLETE

### What Was Done
- ✅ Updated genesis.json: Increased min_deposit from 10k to 100k LMX
- ✅ Documented governance security matrix
- ✅ Burn mechanism for rejected proposals (code needed)

### What Needs Code Integration

**Implement burn on rejection:**
```go
// In x/gov/keeper/keeper.go Tally()
result := v1.CalculateTally(votes, keeper.GetDeposits(proposal))

if result.Passes == false {
    // Governance rejected: burn the deposit
    deposit := keeper.GetDeposit(proposal.Id)
    keeper.BankKeeper.BurnCoins(ctx, gov.ModuleName, deposit.Amount)
} else if result.Passes == true {
    // Governance passed: refund the deposit
    keeper.AddDepositRefund(ctx, proposal.Id, deposit.Depositor, deposit.Amount)
}
```

**Test governance burn:**
```
Scenario: Create proposal with 100k LMX deposit

Case 1 - Proposal passes (> 50% yes):
  - Deposit refunded to proposer: ✓ 100k returned
  - Proposal executes: ✓ If applicable

Case 2 - Proposal fails (< 50% yes):
  - Deposit burned: ✓ 100k LMX removed from circulation
  - Total supply decreased by 100k LMX
  - Proposer gets nothing back

Case 3 - Veto threshold exceeded (> 33.4% veto):
  - Deposit burned: ✓ 100k LMX removed
  - Proposal never executes
```

---

## Phase 4: Genesis Transparency & Validator Rules ✅ COMPLETE

### What Was Done
- ✅ Updated genesis.json: Added hard_cap, min_self_delegation
- ✅ Documented complete genesis allocation (GENESIS_ALLOCATION.md)
- ✅ Vesting schedule defined (4-year, 6-month cliff)

### What Needs Vesting Module Integration

**Initialize vesting accounts:**
```go
// In app.go InitChainer()
vestingAccounts := []struct{
    Address string
    Amount sdk.Coins
    VestingStartTime time.Time  // Genesis + 6 months
    VestingEndTime time.Time    // Genesis + 4 years
    VestingPeriod time.Duration // Monthly vesting
}{
    {
        Address: "lenmarx1ecosystem....",
        Amount: sdk.NewCoins(sdk.NewCoin("ulmx", 150000000000000)),
        VestingStartTime: genesisTime.AddDate(0, 6, 0),
        VestingEndTime: genesisTime.AddDate(4, 0, 0),
        VestingPeriod: 30 * 24 * time.Hour,
    },
}

for _, va := range vestingAccounts {
    // Create vesting account through vesting module
    keeper.CreatePeriodicVestingAccount(...)
}
```

**Test vesting enforcement:**
```
Month 0-5: Ecosystem account has 150M LMX but can't transfer
  - Balance: 150M
  - Spendable: 0
  - Try to send 1 LMX: ✗ Fails (vesting cliff)

Month 6: 6-month cliff ends
  - Balance: 150M
  - Spendable: 3.125M (1 month of 48)
  - Can now send: ✓ Up to 3.125M LMX

Month 12: After 6 months of vesting
  - Spendable: 6.25M (2 months of 48)

Month 24: 50% vested
  - Spendable: 75M LMX
  - Can send: ✓ Any amount up to 75M

Month 48: Fully vested
  - Spendable: 150M LMX
  - Can send: ✓ All 150M LMX
```

---

## Phase 5: Market Reality - NOT STARTED

### Liquidity Bootstrapping

**What needs to be done:**

1. **Create DEX pool at genesis:**
   ```
   Pool: USDC/LMX
   Initial liquidity:
     - 5M LMX tokens
     - $5M USDC
     - Implied price: $1 per LMX
   ```

2. **Publish supply unlock calendar:**
   - Month-by-month vesting schedule
   - Quarterly inflation amount
   - Expected circulating supply per month

3. **Set up liquidity monitoring:**
   - Track USDC-LMX pool depth
   - Monitor price impact
   - Alert if pool falls below minimum liquidity

**Implementation:**
```
Week 1 - Bootstrap Phase:
  - Create USDC-LMX pool
  - Add 5M LMX + $5M USDC liquidity
  - Announce on Discord/Twitter
  - Community can start trading

Month 2:
  - Ecosystem vesting starts (18.75M unlock)
  - Monitor pool for absorption of new supply
  - Market price will fluctuate

Month 6+:
  - Continue monthly monitoring
  - Rebalance if needed (but don't pump artificially)
  - Let market find real price
```

**No artificial price support:**
- Don't buy tokens with treasury to prop up price
- Don't restrict selling to prevent price drops
- Let free market work
- Supply schedule public so traders know future dilution

---

## Phase 6: Operational Readiness - NOT STARTED

### Emergency Procedures

**What needs to be coded:**

1. **Emergency halt mechanism:**
   ```go
   // In app.go
   type EmergencyHalt struct {
       Active bool
       Height int64
       Reason string
   }
   
   // In BeginBlocker
   if app.EmergencyHalt.Active && ctx.BlockHeight() > app.EmergencyHalt.Height {
       return errors.New("network under emergency halt")
   }
   ```

2. **Recovery from halt:**
   ```
   Recovery procedure:
   1. Multisig activates halt at block height X
   2. No new blocks produced
   3. Community reviews issue for 12+ hours
   4. Vote on fix/rollback proposal
   5. Validators download update
   6. All validators restart with new code
   7. Network resumes from block height X
   ```

3. **Upgrade procedure:**
   ```
   Process:
   1. Create governance proposal: "Upgrade to v0.2.0"
   2. Link to Git commit, security audit, test results
   3. 14-day voting period
   4. If passed: scheduled halt at block height N
   5. All validators must update binaries before height N
   6. Network resumes with new code
   ```

### Validator Requirements

**What needs documentation:**

1. **Hardware minimum:**
   - CPU: 4+ cores
   - RAM: 16GB+
   - Storage: 200GB SSD (grows ~20GB/year)
   - Network: 100 Mbps stable uplink

2. **Software requirement:**
   - Ubuntu 22.04 LTS / Debian 12 / CentOS 8+
   - NOT: Windows validators, macOS validators
   - Reason: Linux standardization for security

3. **Uptime requirement:**
   - ≥ 95% uptime in signing window
   - < 500ms average latency to peers
   - Weekly restart recommended

**Slashing penalties:**
```
Missed blocks:
  < 100: 0.01% slash (warning)
  500: 0.5% slash
  1,000: 1% slash
  2,000: 5% slash

Double signing: 5% slash (banned from active set)
```

### Monitoring Setup

**What needs to be deployed:**

1. **Block explorer** (Cosmoscan, Mintscan compatible)
   - Show all transactions
   - Show validator set
   - Show slashing events
   - Show supply total

2. **Validator monitoring dashboard**
   - Real-time validator stats
   - Uptime tracking
   - Slashing alerts
   - Commission rates

3. **Supply transparency**
   - Live supply total
   - Burn events
   - Inflation rate
   - Next vesting unlock date

---

## Phase 7: Trust Infrastructure - NOT STARTED

### Block Explorer

**Requirements:**
- Display all transactions
- Show addresses and balances
- Display validator set
- Track slashing events
- Show governance proposals
- Supply transparency view

**Recommended tools:**
- Cosmoscan (built-in support for Cosmos SDK)
- Mintscan (polished Cosmos explorer)
- Custom explorer (if specific needs)

### Supply Dashboard

**Public API endpoint:**
```
GET /api/supply
Returns:
{
  "total_supply": "100000000000000ulmx",
  "circulating_supply": "50000000000000ulmx",
  "supply_cap": "1000000000000000ulmx",
  "inflation_rate": "0.060000000000000000",
  "burned_total": "50000000ulmx",
  "next_vesting_unlock": {
    "date": "2026-03-01T00:00:00Z",
    "amount": "3125000000000ulmx"
  }
}
```

### Validator Dashboard

**Public monitoring:**
- Active validator count
- Average uptime percentage
- Recent slashing events
- Commission rate distribution
- Voting power distribution

**Benefits:**
- Prevents hidden validator issues
- Encourages competition
- Transparency = trust

### IBC Planning

**Year 2 roadmap:**
- Open channels to Cosmos Hub
- Enable token transfers (IBC bridge)
- Plan Ethereum bridge (later)
- Solana bridge (later)

**IBC channels:**
```
LENMARX ←→ Cosmos Hub: Token transfer
LENMARX ←→ Osmosis: Liquidity pools
LENMARX ←→ Juno: Smart contracts

Future:
LENMARX ←→ Ethereum: Gravity Bridge
LENMARX ←→ Solana: Wormhole
```

---

## Phase 8: Narrative - NOT STARTED

### Economic Narrative

**The story to tell:**

1. **Problem:**
   - Most blockchains have bad economics
   - Unlimited inflation (Ethereum originally)
   - Hidden allocations (VC tokens)
   - Governance capture (whales voting for themselves)
   - No emergency procedures

2. **LENMARX Solution:**
   - Hard-capped at 1B LMX (no exceptions)
   - Transparent allocation (150M+ published)
   - Economic incentives aligned (validators earn from fees, not just inflation)
   - Emergency procedures defined (can halt + recover)
   - Public monitoring (everyone can see supply, inflation, burns)

3. **Why hold LMX?**
   - **Staking**: Earn 4-6% annually securing the network
   - **Governance**: Vote on proposals, shape future
   - **Transactions**: Fast, cheap fees with burn mechanism
   - **Scarcity**: Hard cap creates long-term value

### Community Trust Building

**Actions to take:**

1. **Publish everything:**
   - Genesis allocation (✓ done)
   - Supply unlock schedule (quarterly report)
   - Inflation calculations (monthly report)
   - Slashing events (on-chain + dashboard)
   - Governance decisions (all proposals public)

2. **Create education:**
   - "Why 1B cap?" blog post
   - "Understanding LMX tokenomics" guide
   - Validator setup tutorials
   - Developer documentation

3. **Engage community:**
   - Monthly economic report
   - Quarterly AMA (ask us anything)
   - Governance participation incentives
   - Validator operator forums

4. **Show results:**
   - "Governance rejections burned 5M LMX this quarter"
   - "Transaction fees burned 3M LMX this month"
   - "Supply cap enforcement maintained"
   - "No hidden allocations discovered"

---

## Implementation Checklist

### Before Mainnet (Week 1-4)

- [ ] Hard cap enforcement in code (Phase 0)
- [ ] Min gas price = 0.001 ulmx (Phase 2)
- [ ] Gas fee burn mechanism = 40% (Phase 1-2)
- [ ] Min self-delegation = 1B ulmx (Phase 4)
- [ ] Gov deposit = 100k LMX (Phase 3)
- [ ] Gov rejection burns deposit (Phase 3)
- [ ] Vesting module initialized (Phase 4)
- [ ] Vesting schedule locked (Phase 4)
- [ ] Emergency halt code (Phase 6)
- [ ] Genesis allocation documented (✓ Phase 4)

### Week 1-2

- [ ] Deploy block explorer
- [ ] Set up supply dashboard
- [ ] Create validator monitoring
- [ ] Publish supply unlock calendar

### Week 2-4

- [ ] Create documentation site
- [ ] Publish tokenomics guide
- [ ] Set up community Discord
- [ ] Begin validator outreach

### Month 2+

- [ ] Monitor vesting unlock (Month 6)
- [ ] Update supply dashboard monthly
- [ ] Publish economic reports quarterly
- [ ] Engage community in governance

---

**Document Version**: 1.0  
**Status**: Phases 0-4 implementation guide complete  
**Last Updated**: 2026-01-31
