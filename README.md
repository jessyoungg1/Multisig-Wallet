# Hardhat Template
This is a SushiSwap MasterChef Test.

It tests the use of the contracts functions.

## Getting started
Clone the repo into your project directory:
```bash
git clone https://github.com/jessyoungg1/Multisig-Wallet.git
```

## Chnage Directory to the new file
```bash
cd Multisig-Wallet
```

## Then,
```bash
npm i
```

Enter your Etherscan key, private key and alchemy key into .env file 

## Test
```bash
npx hardhat node --fork https://eth-mainnet.alchemyapi.io/v2/***ALCHEMY_KEY***** --fork-block-number RECENT_BLOCK_NUMBER
```
## Open another terminal window and run
```bash
npx hardhat node --network localhost
```
