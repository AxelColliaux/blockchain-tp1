Ce projet contient une implémentation pédagogique d'un token ERC-20 en Solidity 0.8.24. Le contrat prend en charge les transferts, les autorisations, `transferFrom`, le mint, le burn et le transfert de propriété. Il est testé avec Hardhat en TypeScript et avec Foundry en Solidity

Le contrat est déployé et vérifié sur [Ethereum Sepolia](https://sepolia.etherscan.io/address/0x0B15633d0Ad24237E5FF5681ebFAd976680091Af#code).

## Installation

Prérequis : Node.js 20 ou supérieur, npm et Foundry.

```bash
git clone git@github.com:AxelColliaux/blockchain-tp1.git
cd blockchain-tp1/tp1-erc20
npm install
```

Créer ensuite un fichier `.env` dans `tp1-erc20` :

```dotenv
RPC_URL_SEPOLIA=https://eth-sepolia.g.alchemy.com/v2/VOTRE_CLE
PRIVATE_KEY=0xVOTRE_CLE_PRIVEE_DE_TEST
ETHERSCAN_API_KEY=VOTRE_CLE_ETHERSCAN
```

## Tests

Tests TypeScript avec Hardhat :
```bash
npx hardhat test
```

Tests Solidity avec Foundry :
```bash
forge test -vv
```

Fuzzing avec 1 000 exécutions :
```bash
forge test --fuzz-runs 1000
```

Couverture et mesure du gas :
```bash
forge coverage --report summary
forge snapshot
```