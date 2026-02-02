# LENMARX - Critical Items Checklist

**Date**: 2026-01-31 (After Review)  
**Purpose**: Clear action items to fix before testnet/mainnet

---

## 🔴 CRITICAL - MUST FIX BEFORE TESTNET

### [ ] 1. Implement Hard-Cap Enforcement Code
**File**: `x/mint/keeper/mint.go`  
**What**: Add MintCoins override that checks against hard_cap  
**Why**: Without this, inflation continues past 1B LMX  
**Effort**: 2-4 hours  
**Reference**: HARDCAP_IMPLEMENTATION.md  
**Status**: Ready-to-code template provided  

### [ ] 2. Write Hard-Cap Unit Tests
**File**: `x/mint/keeper/mint_test.go`  
**Tests needed**:
- [ ] Minting below cap works
- [ ] Minting past cap fails
- [ ] Minting at exact cap works
- [ ] No minting after cap reached

**Effort**: 1 hour  
**Reference**: HARDCAP_IMPLEMENTATION.md (test cases provided)  

### [ ] 3. Verify genesis.json is Correct
**Checklist**:
- [ ] hard_cap: "1000000000000000ulmx" ✓
- [ ] min_deposit: "100000000000" (100k LMX) ✓
- [ ] min_self_delegation: "1000000000ulmx" (1k LMX) ✓
- [ ] community_tax: "0.200000000000000000" ✓
- [ ] total supply: "1000000000000000" ✓

**Effort**: 15 minutes  
**How to verify**: 
```bash
cat genesis/genesis.json | jq '.app_state.mint.params'
cat genesis/genesis.json | jq '.app_state.staking.params.min_self_delegation'
```

---

## 🟡 IMPORTANT - FIX BEFORE MAINNET

### [ ] 4. Implement Burn Mechanisms
**What's needed**:
- [ ] 40% of gas fees → burned
- [ ] Governance rejections → deposit burned
- [ ] Slashing events → partial burn

**Files**: `x/bank/keeper`, `x/gov/keeper`  
**Effort**: 6 hours  
**Why**: Creates long-term deflationary dynamics  
**Deadline**: Before mainnet  

### [ ] 5. Wire Vesting Module
**What's needed**:
- [ ] Vesting accounts initialized in app.go
- [ ] 4-year vesting schedule enforced
- [ ] 6-month cliff working

**Files**: `app/app.go`, `x/vesting/module.go`  
**Effort**: 3 hours  
**Why**: Prevents ecosystem token dumps  
**Deadline**: Before mainnet  

### [ ] 6. Update Documentation Status
**What to do**:
- [ ] Mark ECONOMICS.md with implementation status
- [ ] Add "⏳ NOT YET IMPLEMENTED" tags
- [ ] Link to HARDCAP_IMPLEMENTATION.md
- [ ] Remove "COMPLETE" from unfinished features

**Effort**: 1 hour  
**Why**: Avoid community confusion  
**Deadline**: Before public announcements  

---

## 🟢 GOOD TO HAVE - BEFORE TESTNET

### [ ] 7. Create Integration Test
**What**: Deploy testnet with all parameters, verify behavior  
**Steps**:
- [ ] Build: `go build ./cmd/lenmarxd`
- [ ] Init: `lenmarxd init test-1 --chain-id test-1`
- [ ] Copy genesis: `cp genesis/genesis.json ~/.lenmarx/config/genesis.json`
- [ ] Start: `lenmarxd start`
- [ ] Verify: No errors, parameters load correctly

**Effort**: 1 hour  
**Deadline**: After hard-cap code is done  

### [ ] 8. Testnet Validator Setup
**What**: Document how to run a validator  
**Content**:
- [ ] Hardware requirements
- [ ] Software (Linux-only)
- [ ] Minimum stake (1k LMX)
- [ ] Commission rates
- [ ] Uptime requirements

**Effort**: 2 hours  
**Deadline**: Before validator recruitment  

### [ ] 9. Create Supply Dashboard Spec
**What**: Document what supply monitoring dashboard should show  
**Items**:
- [ ] Total supply at each block
- [ ] Inflation rate
- [ ] Burned coins total
- [ ] Vesting schedule next unlock
- [ ] Time to hard cap

**Effort**: 1 hour  
**Reference**: PHASES_IMPLEMENTATION.md Phase 7  

---

## 📋 VERIFICATION CHECKLIST

### Before Testnet Launch
- [ ] Hard-cap code implemented ← CRITICAL
- [ ] Hard-cap tests passing ← CRITICAL
- [ ] genesis.json all values correct
- [ ] Binary compiles: `go build ./cmd/lenmarxd`
- [ ] Binary runs: `lenmarxd version`
- [ ] Genesis validates: `lenmarxd validate-genesis`
- [ ] Documentation updated with status
- [ ] No "COMPLETE" claims for incomplete features

### Before Validator Recruitment
- [ ] Testnet running successfully
- [ ] 3+ validators online
- [ ] Hard cap enforcement tested
- [ ] Inflation parameters working
- [ ] Min self-delegation enforced
- [ ] Governance working (proposal deposits enforced)

### Before Mainnet
- [ ] Security audit completed (external)
- [ ] All burn mechanisms working
- [ ] Vesting schedule enforced
- [ ] Supply dashboard live
- [ ] Community education complete
- [ ] Validator handbook published

---

## 🚨 ISSUES FIXED

### ❌ FIXED: min_self_delegation Math Error
**Was**: `1000000000000ulmx` = 1,000,000 LMX (wrong)  
**Now**: `1000000000ulmx` = 1,000 LMX (correct)  
**Status**: ✅ FIXED in genesis.json  

### ❌ IDENTIFIED: Hard-Cap Only a Parameter
**Issue**: Hard cap added to genesis but code doesn't enforce it  
**Status**: ✅ IDENTIFIED, ready-to-code template provided  
**Action**: Implement this week  

### ❌ IDENTIFIED: Documentation is Incomplete
**Issue**: Claimed "complete" for unimplemented features  
**Status**: ✅ IDENTIFIED, will update ECONOMICS.md  
**Action**: Mark as "⏳ IMPLEMENTATION PENDING"  

---

## TIMELINE

| Week | Task | Blocker |
|------|------|---------|
| W1 (Now) | Hard-cap code + tests | ✅ CRITICAL |
| W1 (Now) | Fix min_self_delegation | ✅ FIXED |
| W1 (Now) | Update documentation | ⏳ IMPORTANT |
| W2 | Testnet deployment | ✅ AFTER W1 |
| W2 | 3+ validators online | ⏳ AFTER W1 |
| W3-4 | Burn mechanisms + vesting | ⏳ IMPORTANT |
| W4-5 | Security audit | ⏳ BEFORE MAINNET |
| W5+ | Mainnet launch | ✅ WHEN READY |

---

## SUCCESS CRITERIA

✅ **Hard cap is not just documented, it's enforced in code**

✅ **Parameters in genesis match code logic**

✅ **Math is correct** (min_self_delegation = 1k LMX)

✅ **Documentation clearly labels what's not yet implemented**

✅ **Ready for validators to trust the network**

✅ **Community can verify every claim on GitHub**

---

## Communication Strategy

**To validators** (when recruiting for testnet):
> "Hard-cap code is implemented and tested. Min stake is 1,000 LMX per validator. Inflation will stop at 1B LMX. This is code-enforced."

**To community** (when launching):
> "LENMARX economics are enforced by code, not policy. Here's the GitHub repo proving it."

**To auditors** (before security review):
> "Here's exactly what's implemented. Here's what's planned. Here's our code. Find the bugs."

---

## Responsible Person Tracking

| Task | Who | Deadline | Status |
|------|-----|----------|--------|
| Hard-cap code | [Name] | This week | ⏳ START |
| Unit tests | [Name] | This week | ⏳ START |
| Burn mechanisms | [Name] | Next week | ⏳ PLANNED |
| Vesting module | [Name] | Next week | ⏳ PLANNED |
| Documentation | [Name] | This week | ⏳ START |
| Testnet deploy | [Name] | Week 2 | ⏳ PLANNED |
| Security audit | [External] | Week 4 | ⏳ PLANNED |

---

## Success Metrics

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Economic design quality | ✅ Excellent | ✅ Maintain | PASS |
| Genesis parameter correctness | ⚠️ Fixed | ✅ 100% | PASS (after fix) |
| Code enforcement | ❌ Missing | ✅ Complete | IN PROGRESS |
| Documentation accuracy | ⚠️ Mixed | ✅ Clear | IN PROGRESS |
| Community trust | ⚠️ Depends on transparency | ✅ High | TO BE EARNED |

---

## Questions To Answer Before Testnet

- [ ] Is hard-cap code deployed? **YES / NO**
- [ ] Do we have unit test coverage? **YES / NO**
- [ ] Do we have integration test passing? **YES / NO**
- [ ] Is all documentation updated? **YES / NO**
- [ ] Can community audit the code? **YES / NO**
- [ ] Are validator requirements documented? **YES / NO**
- [ ] Do we have security audit scheduled? **YES / NO**

---

**Print this checklist, post it on your wall, work through it systematically.**

**When everything is checked, you're ready.**

---

**Prepared by**: Critical Review Process  
**Date**: 2026-01-31  
**Status**: Action items identified, ready to execute
