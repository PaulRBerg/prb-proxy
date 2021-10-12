# PRBProxy [![Coverage Status](https://coveralls.io/repos/github/paulrberg/prb-proxy/badge.svg?branch=main)](https://coveralls.io/github/paulrberg/prb-proxy?branch=main) [![Styled with Prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg)](https://prettier.io) [![Commitizen Friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/) [![license: Unlicense](https://img.shields.io/badge/license-Unlicense-yellow.svg)](https://unlicense.org/)

**Proxy contract to compose Ethereum transactions on behalf of the owner.** You can think of this as a smart wallet
that enables you to execute multiple contract calls in one transaction. Externally owned accounts do not
have this feature; they are limited to interacting with only one contract per transaction.

- Forwards calls with [DELEGATECALL][2]
- Uses [CREATE2][1] to deploy the proxies at deterministic addresses
- Reverts with custom errors instead of reason strings
- Well-documented via NatSpec comments
- Thoroughly tested with Hardhat and Waffle

## Background

The idea of a proxy contract has been popularized by [DappHub](https://github.com/dapphub), a team of developers who helped create
the decentralized stablecoin [DAI](https://makerdao.com). DappHub is the creator of [ds-proxy](https://github.com/dapphub/ds-proxy),
which grew to become the [de facto](https://ethereum.stackexchange.com/a/90304/24693) solution for developers who need to execute multiple contract
calls in one transaction. For example, [Maker](https://makerdao.com), [Balancer](https://balancer.fi), and [DeFi
Saver](https://defisaver.com/) all use DSProxy.

The problem is that it got in years. The Ethereum development ecosystem is much different today compared to 2017,
when DSProxy was originally developed. The Solidity compiler has [improved](https://docs.soliditylang.org/en/v0.8.7/080-breaking-changes.html) a lot,
new OPCODES have been added to the EVM, and development environments like [Hardhat](https://hardhat.org/) make writing smart contracts a breeze.

PRBProxy is a modern version of DSProxy. It still uses `DELEGATECALL` to forwards contract calls, though it employs the
[high-level instruction](https://ethereum.stackexchange.com/q/37601/24693) rather than assembly. There are two major improvements:

1. PRBProxy is more lightweight. It takes [less gas](./README.md#gas-efficiency) to deploy, because it contains only the strictly necessary features.
2. Unlike DSProxy, which uses
   [CREATE](https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed),
   instances of PRBProxy are deployed via [CREATE2][1]. This enables clients to deterministically compute the address of the proxy contract ahead of time.

Talking to the Maker team, I figured that the target contract [caching](https://github.com/dapphub/ds-proxy/blob/e17a2526ad5c9877ba925ff25c1119f519b7369b/src/proxy.sol#L130-L150)
feature of DSProxy didn't really pick up steam. I have thus decided to not include it in PRBProxy, making the bytecode smaller.

A noteworthy knock-on effect of using `CREATE2` is that it eliminates the risk of a [chain
reorg](https://en.bitcoin.it/wiki/Chain_Reorganization) overriding the proxy. With DSProxy, one has to wait for a few blocks to be
mined before one can assume the contract to be safe to use. With PRBProxy, there is no such risk. It is even safe to send funds to the proxy _before_ it is deployed.

I covered a lot here, but I barely scratched the surface. Maker's developer guide [Working with
DSProxy](https://github.com/makerdao/developerguides/blob/master/devtools/working-with-dsproxy/working-with-dsproxy.md)
dives deep into how to compose contract calls. For the reasons mentioned herein, the guide applies to PRBProxy as well;
just keep in mind the differences between the two.

## Install

With yarn:

```bash
$ yarn add prb-proxy
```

Or npm:

```bash
$ npm install prb-proxy
```

## Usage

### Contracts

As an end user, you don't have to deploy the contracts by yourself. To deploy your own proxy, you can use the registry at the address below. In fact, this is the recommended approach.

| Contract         | Address                                    |
| ---------------- | ------------------------------------------ |
| PRBProxyFactory  | 0x031233FDF1A3Fa4316aD0F197987fB975172450E |
| PRBProxyRegistry | 0xB2D4c98DD0CB05C399e3f930Ba37D1f035d3C88A |

### Supported Chains

- [x] Ethereum Mainnet
- [x] Ethereum Goerli Testnet
- [x] Ethereum Kovan Testnet
- [x] Ethereum Rinkeby Testnet
- [x] Ethereum Ropsten Testnet
- [x] Polygon Mainnet
- [x] Binance Smart Chain Mainnet

## Code Snippets

All scripts below are written in TypeScript and assume that they are run in a [Hardhat](https://hardhat.org) project.
Familiarity with [Ethers](https://github.com/ethers-io/ethers.js) and
[TypeChain](https://github.com/ethereum-ts/TypeChain/tree/master/packages/hardhat) is also requisite.

Check out my [solidity-template](https://github.com/paulrberg/solidity-template) for a boilerplate that combines
Hardhat, Ethers and TypeChain.

### Target Contract

You need a "target" contract to do anything meaningful with PRBProxy. This is basically a collection of stateless
scripts. Below is an example for a target that performs a basic ERC-20 transfer.

Note that this is but a dummy example. In the real-world, you would do more complex work, e.g. interacting with a DeFi
protocol.

<details>
<summary>Code Snippet</summary>

```solidity
// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/erc20/IERC20.sol"

contract TargetERC20Transfer {
    function transferTokens(IERC20 token, uint256 amount, address recipient) {
      // Transfer tokens from user to PRBProxy.
      token.transferFrom(msg.sender, amount);

      // Transfer tokens from PRBProxy to specific recipient.
      token.transfer(recipient, amount);
    }
}

```

</details>

### Compute Proxy Address

The `prb-proxy` package exports a helper function called `computeProxyAddress`, which you can use to deterministically
compute the address of your next instance of PRBProxy, before it is deployed. The function takes two arguments:
`deployer` and `salt`. The first is the EOA you sign the Ethereum transaction with. The second requires an explanation.

Neither `PRBProxyFactory` nor `PRBProxyRegistry` lets users provide a custom salt when deploying a proxy. Instead,
the factory contract maintains a mapping between
[tx.origin](https://ethereum.stackexchange.com/questions/109680/is-tx-origin-always-an-externally-owned-account-eoa)
accounts and some `bytes32` salts, each starting at `0x00` and growing linearly from there. If you wonder why `tx.origin`, that's because it
[prevents](https://ethereum.stackexchange.com/questions/109272/how-to-prevent-front-running-the-salt-when-using-create2)
the front-running of the salt.

`PRBProxyFactory` increases the value of the each salt incrementally each time a new proxy is deployed. To get hold of the next
salt that the factory will use, you can query the constant function `getNextSalt`. Putting it all together:

<details>
<summary>Code Snippet</summary>

```ts
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { computeProxyAddress } from "prb-proxy";
import { PRBProxyFactory__factory } from "prb-proxy/typechain/factories/PRBProxyFactory__factory";
import { PRBProxyFactory } from "prb-proxy/typechain/PRBProxyFactory";

task("compute-proxy-address").setAction(async function (_, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();

  // Load PRBProxyFactory as an ethers.js contract.
  const factory: PRBProxyFactory = PRBProxyFactory__factory.connect(addresses.PRBProxyFactory, signers[0]);

  // Load the next salt. "signers[0]" is considered to be a proxy deployer.
  const nextSalt: string = await factory.getNextSalt(signers[0]);

  // Deterministically compute the address of your next instance of PRBProxy.
  const address: string = computeProxyAddress(signers[0].address, nextSalt);
});
```

</details>

### Deploy Proxy

<details>
<summary>Code Snippet</summary>

It is recommended to deploy the proxy via the `PRBProxyRegistry` contract. The registry guarantees that an owner
can have only one proxy at a time.

```ts
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";
import { addresses } from "prb-proxy";
import { PRBProxyRegistry__factory } from "prb-proxy/typechain/factories/PRBProxyRegistry__factory";
import { PRBProxyRegistry } from "prb-proxy/typechain/PRBProxyRegistry";

task("deploy-prb-proxy").setAction(async function (_, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();

  // Load PRBProxyRegistry as an ethers.js contract.
  const registry: PRBProxyRegistry = PRBProxyRegistry__factory.connect(addresses.PRBProxyRegistry, signers[0]);

  // Call contract function "deploy" to deploy an instance of PRBProxy belonging to "msg.sender".
  const tx = await registry.deploy();

  // Wait for a block confirmation.
  await tx.wait(1);
});
```

</details>

### Get Current Proxy

Before deploying a new proxy, you may want to know if the owner has one already.

<details>
<summary>Code Snippet</summary>

```ts
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { computeProxyAddress } from "prb-proxy";
import { PRBProxyRegistry__factory } from "prb-proxy/typechain/factories/PRBProxyRegistry__factory";
import { PRBProxyRegistry } from "prb-proxy/typechain/PRBProxyRegistry";

task("get-current-proxy").setAction(async function (_, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();

  // Load PRBProxyRegistry as an ethers.js contract.
  const registry: PRBProxyRegistry = PRBProxyRegistry__factory.connect(addresses.PRBProxyRegistry, signers[0]);

  // Load the next salt. "signers[0]" is considered to be a proxy owner.
  const currentProxy: string = await registry.getCurrentProxy(signers[0]);

  // Deterministically compute the address of your instance of PRBProxy.
  const address: string = computeProxyAddress(signers[0].address, nextSalt);
});
```

</details>

### Execute Composite Call

This code assumes that you already have an instance of PRBProxy deployed and that you also compiled and deployed the
[TargetERC20Transfer](./README.md#target-contract) contract.

<details>
<summary>Code Snippet</summary>

```ts
import { BigNumber } from "@ethersproject/bignumber";
import { parseUnits } from "@ethersproject/units";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";
import { PRBProxy__factory } from "prb-proxy/typechain/factories/PRBProxy__factory";
import { PRBProxy } from "prb-proxy/typechain/PRBProxy";

import { TargetERC20Transfer__factory } from "../typechain/factories/TargetERC20Transfer__factory";
import { TargetERC20Transfer } from "../typechain/TargetERC20Transfer";

task("execute-composite-call").setAction(async function (_, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();

  // Load the PRBProxy as an ethers.js contract.
  const prbProxyAddress: string = "0x...";
  const prbProxy: PRBProxy = PRBProxy__factory.connect(prbProxyAddress, signers[0]);

  // Load the TargetERC20Transfer as an ethers.js contract.
  const targetAddress: string = "0x...";
  const target: TargetERC20Transfer = TargetERC20Transfer__factory.connect(targetAddress, signers[0]);

  // Encode the target contract call as calldata.
  const tokenAddress: string = "0x...";
  const amount: BigNumber = parseUnits("100");
  const recipient: string = "0x...";
  const data: string = target.interface.encodeFunctionData("transferTokens", [tokenAddress, amount, recipient]);

  // Execute the composite call.
  const receipt = await prbProxy.execute(targetAddress, data);
});
```

</details>

## Gas Efficiency

It costs around 460,442 gas to deploy an instance of PRBProxy, whereas to deploy an instance of DSProxy it costs 596,198
gas. That's a 1.29x reduction in deployment costs.

The `execute` function in PRBProxy may cost a tiny bit more than its equivalent in DSProxy, but that's because I
added an extra sanity check on the function inputs. At any rate, the lion's share of the gas cost when calling `execute`
is due to the target contract.

## Security

While I set a high bar for code quality and test coverage, you shouldn't assume that this project is completely safe to
use. The contracts have not been audited by a security researcher.

### Caveat Emptor

This is experimental software and is provided on an "as is" and "as available" basis. I do not give any warranties and
will not be liable for any loss, direct or indirect through continued use of this codebase.

### Contact

If you discover any security issues, you can report them via [Keybase](https://keybase.io/paulrberg).

## Related Efforts

- [ds-proxy](https://github.com/dapphub/ds-proxy) - DappHub's proxy, which powers the Maker protocol.
- [dsa-contracts](https://github.com/Instadapp/dsa-contracts) - InstaDapp's DeFi Smart Accounts.

## Contributing

Feel free to dive in! [Open](https://github.com/paulrberg/prb-proxy/issues/new) an issue, [start](https://github.com/paulrberg/prb-proxy/discussions/new) a discussion or submit a PR.

### Pre Requisites

You will need the following software on your machine:

- [Git](https://git-scm.com/downloads)
- [Node.Js](https://nodejs.org/en/download/)
- [Yarn](https://yarnpkg.com/getting-started/install)

In addition, familiarity with [Solidity](https://soliditylang.org/), [TypeScript](https://typescriptlang.org/) and [Hardhat](https://hardhat.org) is requisite.

### Set Up

Install the dependencies:

```bash
$ yarn install
```

Then, create a `.env` file and follow the `.env.example` file to add the requisite environment variables. Now you can
start making changes.

## License

[Unlicense](./LICENSE.md) © Paul Razvan Berg

<!-- Links -->

[1]: https://eips.ethereum.org/EIPS/eip-1014
[2]: https://ethereum.stackexchange.com/questions/3667/difference-between-call-callcode-and-delegatecall/3672
