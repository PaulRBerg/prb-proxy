# PRBProxy [![Github Actions][gha-badge]][gha] [![Coverage][codecov-badge]][codecov] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gha]: https://github.com/PaulRBerg/prb-proxy/actions
[gha-badge]: https://github.com/PaulRBerg/prb-proxy/actions/workflows/ci.yml/badge.svg
[codecov]: https://codecov.io/gh/PaulRBerg/prb-proxy
[codecov-badge]: https://codecov.io/gh/PaulRBerg/prb-proxy/branch/main/graph/badge.svg?token=4YV6JCTO9R
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

PRBProxy is a **proxy contract that allows for the composition of Ethereum transactions on behalf of the contract owner**, acting as a smart wallet
that enables multiple contract calls within a single transaction. In Ethereum, externally owned accounts (EOAs) do not have this functionality because
they cannot perform delegate calls.

Some key features of PRBProxy include:

- Forwarding calls with [`DELEGATECALL`][se-3667]
- Use of [CREATE2][eip-1014] to deploy the proxies at deterministic addresses.
- A unique registry system ensures that each user has a distinct proxy.
- An access control system that permits third-party accounts (called "envoys") to call target contracts on behalf of the owner.
- A plugin system that enables the proxy to respond to callbacks.
- Reversion with custom errors rather than reason strings for improved error handling.
- Comprehensive documentation via NatSpec comments.
- Development and testing using Foundry.

Overall, PRBProxy is a powerful tool for transaction composition, providing numerous features and benefits not available through EOAs.

## Install

### Foundry

First, run the install step:

```sh
forge install PaulRBerg/prb-proxy@release-v4
```

Your `.gitmodules` file should now contain the following entry:

```toml
[submodule "lib/prb-proxy"]
  branch = "release-v4"
  path = "lib/prb-proxy"
  url = "https://github.com/PaulRBerg/prb-proxy"
```

Finally, add this to your `remappings.txt` file:

```text
prb-proxy/=lib/prb-proxy/src/
```

### Hardhat

PRBProxy is available as an npm package:

```sh
pnpm add @prb/proxy
```

## Background

The concept of a forwarding proxy has gained popularity thanks to DappHub, the developer team behind the decentralized stablecoin
[DAI](https://makerdao.com). DappHub created [DSProxy](https://github.com/dapphub/ds-proxy), a widely used tool that allows for the execution of
multiple contract calls in a single transaction. Major DeFi players like Maker, Balancer, and DeFi Saver all rely on DSProxy.

However, as the Ethereum ecosystem has evolved since DSProxy's launch in 2017, the tool has become outdated. With significant improvements to the
Solidity compiler and new EVM OPCODES, as well as the introduction of more user-friendly development environments like
[Foundry](https://book.getfoundry.sh/), it was time for an update.

Enter PRBProxy, the modern successor to DSProxy; a "DSProxy 2.0", if you will. It improves upon DSProxy in several ways:

1. PRBProxy is deployed with [CREATE2][eip-1014], which allows clients to pre-compute the proxy contract's address.
2. The `CREATE2` salts are generated in a way that eliminates the risk of front-running.
3. The proxy owner is immutable, and so it cannot be changed during any `DELEGATECALL`.
4. PRBProxy uses high-level Solidity code that is easier to comprehend and less prone to errors.
5. PRBProxy offers more features than DSProxy.

Using CREATE2 eliminates the risk of a [chain reorg](https://en.bitcoin.it/wiki/Chain_Reorganization) overriding the proxy contract owner, making
PRBProxy a more secure alternative to DSProxy. With DSProxy, users must wait for several blocks to be mined before assuming the contract is secure.
However, PRBProxy eliminates this risk entirely, making it possible to safely send funds to the proxy before it is deployed.

## Deployments

PRBProxyRegistry is deployed on all chains at 0xD42a2bB59775694c9Df4c7822BfFAb150e6c699D. A sortable, searchable list of all chains it's deployed on
can be found at https://prbproxy.com/deployments. To request a deployment to a new chain, please open a GitHub issue. You can speed up the new deploy
by sending funds to cover the deploy cost to the deployer account: 0x3Afb8fEDaC6429E2165E84CC43EeA7e42e6440fF.

### ABIs

The ABIs can be found on https://prbproxy.com/abi, where they can be downloaded or copied to the clipboard in various formats, including:

- Solidity interface
- JSON ABIs, prettified
- JSON ABIs, minified
- ethers.js human readable ABIs
- viem human readable ABIs

Alternatively, you can:

- Download the ABIs from the releases page.
- Copy the ABIs from [Etherscan](https://etherscan.io/address/0xD42a2bB59775694c9Df4c7822BfFAb150e6c699D).
- Install [Foundry](https://getfoundry.sh/) and run `cast interface 0xD42a2bB59775694c9Df4c7822BfFAb150e6c699D`.

## Usage

Proxies are deployed via PRBProxyRegistry. There are multiple deploy functions available:

| Function                     | Description                                                                                              |
| ---------------------------- | -------------------------------------------------------------------------------------------------------- |
| `deploy`                     | Deploy a proxy for `msg.sender`                                                                          |
| `deployFor`                  | Deploy a proxy for the provided `owner`                                                                  |
| `deployAndExecute`           | Deploy a proxy for `msg.sender`, and delegate calls to the provided target                               |
| `deployAndInstallPlugin`     | Deploy a proxy for `msg.sender`, and installs the provided plugin                                        |
| `deployAndExecuteAndInstall` | Deploy a proxy for `msg.sender`, delegate calls to the provided target, and installs the provided plugin |

Once the proxy is deployed, you can start interacting with target contracts by calling the `execute` function on the proxy by passing the ABI-encoding
function signatures and data.

### Documentation

See this repository's [wiki](https://github.com/PaulRBerg/prb-proxy/wiki) page for guidance on how to write plugins, targets, and front-end
integrations.

### Frontends

Integrating PRBProxy into a front-end app would work something like this:

1. Begin by calling the `getProxy` function on the registry to determine if the user already has a proxy.
2. If the user does not have a proxy, deploy one for them using one of the deploy methods outlined above.
3. Interact with your desired target contract using the `execute` function.
4. Install relevant plugins, which can make the proxy react to your protocol events.
5. Going forward, treat the proxy address as the user of your system.

However, this is just scratching the surface. For more examples of how to use PRBProxy in a frontend environment, check out the [Frontends][frontends]
wiki. Additionally, Maker's developer guide, [Working with DSProxy][dsproxy-guide], provides an in-depth exploration of the proxy concept that can
also help you understand how to use PRBProxy. Just be sure to keep in mind the differences outlined throughout this document.

## Security

While I have strict standards for code quality and test coverage, and the code has been audited by third-party security researchers, using PRBProxy
may not be entirely risk-free.

### Caveat Emptor

Please be aware that this software is experimental and is provided on an "as is" and "as available" basis. I do not offer any warranties, and I cannot
be held responsible for any direct or indirect loss resulting from the continued use of this codebase.

### Contact

If you discover any bugs or security issues, please report them via [Telegram](https://t.me/PaulRBerg).

## License

This project is licensed under MIT.

<!-- Links -->

[eip-1014]: https://eips.ethereum.org/EIPS/eip-1014
[frontends]: https://github.com/PaulRBerg/prb-proxy/wiki/Frontends
[se-3667]: https://ethereum.stackexchange.com/questions/3667/difference-between-call-callcode-and-delegatecall/3672
[dsproxy-guide]:
  https://github.com/makerdao/developerguides/blob/9ded1b68228e6cd70885f1326349c6bf087b9573/devtools/working-with-dsproxy/working-with-dsproxy.md
