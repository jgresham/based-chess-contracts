## Deploy using script

```shell
# Load environment variables
source .env

# Local dev env
anvil

forge script script/DeployGames.s.sol:DeployGames --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# Deploy to Base Sepolia testnet
forge script script/DeployGames.s.sol:DeployGames --rpc-url https://sepolia.base.org --private-key $PRIVATE_KEY --chain base-sepolia --broadcast --verify

# Base mainnet?
forge script script/DeployGames.s.sol:DeployGames --rpc-url https://mainnet.base.org --private-key $PRIVATE_KEY --chain base --broadcast --verify
```

## Verify if it fails afte deploy

```shell
forge verify-contract <deployed-contract-address> src/Games.sol:Games --chain base-sepolia --etherscan-api-key $ETHERSCAN_API_KEY --watch
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
