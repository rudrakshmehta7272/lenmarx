module github.com/lenmarx/lenmarx

go 1.22.11

toolchain go1.22.12

require (
	github.com/cometbft/cometbft v0.38.17
	github.com/cosmos/cosmos-sdk v0.50.0
	github.com/spf13/cobra v1.8.1
)

replace (
	cosmossdk.io/x/auth => cosmossdk.io/x/auth v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/authz => cosmossdk.io/x/authz v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/bank => cosmossdk.io/x/bank v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/capability => cosmossdk.io/x/capability v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/distribution => cosmossdk.io/x/distribution v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/evidence => cosmossdk.io/x/evidence v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/feegrant => cosmossdk.io/x/feegrant v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/gov => cosmossdk.io/x/gov v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/mint => cosmossdk.io/x/mint v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/params => cosmossdk.io/x/params v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/slashing => cosmossdk.io/x/slashing v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/staking => cosmossdk.io/x/staking v0.0.0-20240226161413-5c2ab2ecd32b
	cosmossdk.io/x/upgrade => cosmossdk.io/x/upgrade v0.0.0-20240226161413-5c2ab2ecd32b
)
