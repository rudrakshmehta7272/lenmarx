# LENMARX Genesis Allocation - Transparency Report

**Prepared**: 2026-01-31  
**Total Supply**: 1,000,000,000 LMX (1 billion)  
**Hard Cap**: Enforced by mint module (no exceptions)

---

## Complete Allocation Breakdown

### Total: 1,000,000,000 LMX

```
1,000,000,000 LMX
│
├─ 100,000,000 LMX  (10%) ─ Validator Self-Bond Pool
│  └─ Locked: min 1B ulmx per active validator
│  └─ 100+ validators possible (total stake distributed)
│
├─ 50,000,000 LMX   (5%)  ─ Early Delegators
│  └─ Freely transferable
│  └─ Available Week 1
│
├─ 150,000,000 LMX  (15%) ─ Community Treasury
│  └─ Governed through proposals
│  └─ Available Week 1 (community pool module)
│
├─ 150,000,000 LMX  (15%) ─ Ecosystem Dev Grants
│  └─ Vesting: 4 years, 6-month cliff, linear monthly
│  └─ Unlocks start Month 6
│
├─ 100,000,000 LMX  (10%) ─ Treasury Reserve
│  └─ Multisig controlled (3-of-5)
│  └─ Emergency fund for upgrades, security
│
└─ 450,000,000 LMX  (45%) ─ Inflation Pool
   └─ Distributed to network over 3-7 years
   └─ As validators secure the network
   └─ 60-65% staking rewards, 20% community, 10-15% vesting
```

---

## Allocation by Use Case

### For Network Security (150M tokens)

**Validator Self-Bonds: 100M LMX**
- Purpose: Economic security, skin-in-the-game
- Requirement: Each validator stakes ≥ 1B ulmx (1,000 LMX)
- Lock period: Tied to validator, unbond takes 21 days
- Slashing: 1-5% for misbehavior
- Rewards: Earn 4-6% annually from network

**Example validator economics:**
```
Validator stakes: 10,000 LMX
Commission rate: 5%
Delegated to validator: 100,000 LMX
Total: 110,000 LMX active

Annual network inflation: 60M LMX
Validator share: 60M × 110k / 650M total = 10,154 LMX
Validator keeps: 10,154 × 5% commission = 507.7 LMX
Delegators share: 10,154 × 95% = 9,646 LMX

Validator net: 507.7 LMX from commission
         + 9,500 LMX from own staked share = 10,007.7 LMX
         = 10% APY on 10,000 LMX stake
```

### For Community & Development (300M tokens)

**Community Treasury: 150M LMX**
- Purpose: Public goods, development bounties, marketing
- Control: Governance proposals (community vote)
- Spending: Requires >50% voter approval
- Timeline: Spent over 3-7 years

**Example use cases:**
- Block explorer development: 1M LMX
- Developer documentation: 500k LMX
- Marketing & conferences: 2M LMX annually
- Security audit bounties: 1M LMX
- Ecosystem grants (retroactive): 5M LMX

**Ecosystem Dev Grants: 150M LMX**
- Purpose: Early developer team, strategic partnerships
- Vesting: 4-year schedule, 6-month cliff
- Control: Multisig (vesting accounts controlled by team)
- Risk: Founders might dump after cliff (but discouraged by price impact)

**Vesting schedule detail:**
```
Total: 150M LMX
Period: 48 months (4 years)
Cliff: 6 months (no unlock)

Month 0-6: 0 LMX unlocked
Month 6: 18.75M LMX (3.125M/month × 6)
Month 12: 37.5M LMX (50%)
Month 18: 56.25M LMX
Month 24: 75M LMX (50%)
Month 30: 93.75M LMX
Month 36: 112.5M LMX (75%)
Month 42: 131.25M LMX
Month 48: 150M LMX (100%)
```

### For Emergency & Governance (100M tokens)

**Treasury Reserve: 100M LMX**
- Purpose: Emergency response, upgrades, multisig operations
- Control: 3-of-5 multisig (emergency team)
- Spending: Only for network-critical needs
- Transparency: All spends published on-chain

---

## Supply Timeline

### Genesis (Week 1, 2026)
```
Circulating: 200M LMX
├─ Validator self-bonds: 100M
├─ Early delegators: 50M
├─ Community treasury accessible: 50M
└─ Still locked/vesting: 800M

Burn pool: 0 LMX
Inflation pool: 0 LMX (accrues daily)
```

### Month 6
```
Circulating: 235M LMX
├─ Original: 200M
├─ Inflation since genesis: 30M (6% ÷ 12 × 6)
└─ Ecosystem vesting unlock: 18.75M (6-month cliff ends)

Burned: 2M LMX (from governance rejections, fee burns)
Remaining inflation pool: 420M - 30M = 390M
```

### Year 1
```
Circulating: 380M LMX
├─ Original: 200M
├─ Inflation added: 60M
└─ Vesting unlocks: 120M (6 months × 3.125M/month after cliff)

Burned: 8M LMX
Remaining inflation pool: 390M
```

### Year 2
```
Circulating: 450M LMX
├─ Year 1: 380M
├─ Inflation: 60M more
└─ Vesting: 30M more (partial unlock)

Burned: 20M LMX
Remaining inflation pool: 330M - 60M = 270M
```

### Year 4+
```
Circulating: 700M+ LMX
├─ Vesting fully unlocked: 150M reached
├─ Inflation pool almost depleted
└─ Approaching hard cap

Network state:
  - 67% bonded in validators
  - Inflation rate stabilizes at ~3-6%
  - Transaction fees become primary validator revenue
  - Burn mechanisms active (deflationary period)
```

### Year 8+ (Hard Cap Reached)
```
Circulating: 1,000M LMX
├─ Hard cap enforcement: inflation_rate = 0
├─ No new tokens minted
└─ Network fully stable

Revenue for validators:
  - 100% from transaction fees
  - 60% of fees to validators, 40% burned
  - Deflationary: each transaction reduces total supply

Long-term:
  - Decreased supply
  - Increased scarcity
  - Validator incentives align with transaction fees
```

---

## Comparison to Other Blockchains

### LENMARX vs Bitcoin
| Feature | LENMARX | Bitcoin |
|---------|---------|---------|
| Max Supply | 1B LMX | 21M BTC |
| Issuance | 3-7 years | 12 years |
| Current % Minted | 20% at genesis | 93% today |
| Validator Reward | 4-6% APY | ~1% APY today |
| Fee Burn | 40% | ~0% |

### LENMARX vs Ethereum
| Feature | LENMARX | Ethereum |
|---------|---------|----------|
| Max Supply | Hard cap at 1B | Unlimited |
| Inflation Model | Predictable 6% | Variable |
| Fee Burn | 40% | ~100% (post-merge) |
| Validator Min Stake | 1B ulmx | 32 ETH |
| Supply Transparency | Public dashboard | In Etherscan |

### LENMARX vs Cosmos
| Feature | LENMARX | Cosmos |
|---------|---------|--------|
| Max Supply | Hard cap 1B | Unlimited (can change via vote) |
| Validator Min | 1B ulmx | 0 |
| Gas Fee Burn | 40% | 0% |
| Governance Deposit | 100k LMX | 10k ATOM (similar) |
| IBC Ready | Year 2 | Day 1 |

---

## Allocation Verification Checklist

Before genesis launch, verify:

- [ ] Total supply sums to exactly 1,000,000,000 LMX
- [ ] Validator pool initialized with 100M
- [ ] Delegator accounts funded with 50M
- [ ] Community pool account created with 150M accessible
- [ ] Vesting accounts set up for 150M ecosystem grants
- [ ] Treasury multisig configured (3-of-5) with 100M
- [ ] Inflation pool ready (450M to be minted over time)
- [ ] Hard cap parameter set in mint module
- [ ] Min self-delegation = 1B ulmx in staking params
- [ ] All addresses published on website
- [ ] Vesting schedule documented
- [ ] Burn mechanisms ready to activate

---

## Governance of Allocations

### Community Treasury (150M) - Governance Decisions

**How to propose spending:**
```
1. Draft proposal (1M LMX example = 0.67% of treasury)
2. Gather co-sponsors (100k LMX deposit)
3. 14-day deposit period
4. 14-day voting period
5. >50% approval to pass
6. Execute transaction
```

**Rejected proposals:**
- 100k LMX deposit is BURNED
- Proposal is removed
- Proposer can try again

**Example governance vote:**
```
Proposal: "Grant 5M LMX for protocol research"
Deposit: 100k LMX (from proposer)
Voting period: 14 days

Vote results:
  Yes: 400M LMX (61%)
  No: 180M LMX (27%)
  Abstain: 70M LMX (11%)
  Veto: 5M LMX (< 33.4%)

PASSED ✓
→ 5M LMX transferred from community pool
→ Remaining: 145M in community pool
→ 100k LMX deposit goes to proposer (FAILED) or burned (FAILED vote)
```

### Emergency Procedures

**Treasury Reserve (100M) - Multisig Control**

Used only for:
1. Network emergency (under attack, needs fix)
2. Critical upgrade (security patch required)
3. Infrastructure (must-have public goods)

Requires:
- 3-of-5 multisig signatures
- All transactions on-chain
- 1-week public review before execution

---

## Long-term Economics

### Inflation Stops - Year 8+

When supply reaches 1B LMX:
```
Block reward = 0 (no inflation)
Validator revenue = 100% from transaction fees

Fee model:
  - 60% to validator (current block proposer)
  - 40% burned (removed from circulation)

With 1M transactions/day:
  - Average 5,000 gas/tx
  - 5M transactions = 5B gas
  - Fee: 5B gas × 0.001 ulmx/gas = 5M ulmx (~5 LMX)
  - Burn: 2M ulmx (0.002 LMX)
  - Validators earn: 3M ulmx (0.003 LMX) + transaction inclusion fees
```

### Deflationary Dynamics

**Key insight**: Once supply cap is reached, network becomes deflationary:

- Transaction fees → 40% burned
- Slashing penalties → tokens removed
- Governance rejections → deposits burned
- Net result: Supply decreases each day

This creates:
1. **Scarcity** - Real reduction in supply
2. **Value** - Fewer tokens means more per token (if demand stays constant)
3. **Incentive alignment** - Validators profit from network health (fees)

---

**Document Version**: 1.0  
**Status**: Final  
**Verified**: 2026-01-31
