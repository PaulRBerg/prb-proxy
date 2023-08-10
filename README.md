# PRBProxy [![Github Actions][gha-badge]][gha] [![Coverage][codecov-badge]][codecov] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gha]: https://github.com/PaulRBerg/prb-proxy/actions
[gha-badge]: https://github.com/PaulRBerg/prb-proxy/actions/workflows/ci.yml/badge.svg
[codecov]: https://codecov.io/gh/PaulRBerg/prb-proxy
[codecov-badge]: https://codecov.io/gh/PaulRBerg/prb-proxy/branch/main/graph/badge.svg?token=4YV6JCTO9R
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

PRBProxy is a **forwarding proxy that allows for the composition of Ethereum transactions on behalf of the contract owner**, acting as a smart wallet
that enables multiple contract calls within a single transaction. In Ethereum, externally owned accounts (EOAs) do not have this functionality because
they cannot perform delegate calls.

Some key features of PRBProxy include:

- Forwards calls with [`DELEGATECALL`][se-3667].
- Uses [CREATE2][eip-1014] to deploy the proxies at deterministic addresses.
- A unique registry system ensures that each user has a distinct proxy.
- A plugin system enables the proxy to respond to callbacks.
- An access control system permits third-party accounts (called "envoys") to call target contracts on behalf of the owner.
- Reverts with custom errors rather than reason strings for more efficient error handling.
- Comprehensive documentation via NatSpec comments.
- Developed and tested using Foundry.

Overall, PRBProxy is a powerful tool for transaction composition, providing numerous features and benefits not available through EOAs:

1. **Fewer interactions**: bundling multiple actions together lowers the number of protocol interactions required.
2. **Modularity**: establishing a clear distinction between the core business logic of your protocol and the potentially more intricate, peripheral
   higher-level logic.
3. **Extensibility without upgradeability**: users can delegate call to any arbitrary contracts, including those not even written yet.

## Background

The concept of a forwarding proxy has gained popularity thanks to DappHub, the developer team behind the decentralized stablecoin
[DAI](https://makerdao.com). DappHub created [DSProxy](https://github.com/dapphub/ds-proxy), a widely used tool that allows for the execution of
multiple contract calls in a single transaction. Major DeFi players like Maker, Balancer, and DeFi Saver all rely on DSProxy.

However, as the Ethereum ecosystem has evolved since DSProxy's launch in 2017, the tool has become outdated. With significant improvements to the
Solidity compiler and new EVM OPCODES, as well as the introduction of more user-friendly development environments like
[Foundry](https://book.getfoundry.sh/), it was time for an update.

Enter PRBProxy, the modern successor to DSProxy; a "DSProxy 2.0", if you will. It improves upon DSProxy in several ways:

1. PRBProxy is deployed with [CREATE2][eip-1014], which allows clients to pre-compute the proxy contract's address.
2. Front-running is not possible.
3. The proxy contract itself has no storage, which reduces the risk of storage collisions and malicious attacks.
4. The proxy owner is immutable, and so it cannot be changed during any `DELEGATECALL`.
5. PRBProxy uses high-level Solidity code that is easier to comprehend and less prone to errors.
6. PRBProxy offers more features than DSProxy, such as plugins.

Using CREATE2 eliminates the risk of a [chain reorg](https://en.bitcoin.it/wiki/Chain_Reorganization) overriding the proxy contract owner, making
PRBProxy a more secure alternative to DSProxy. With DSProxy, users must wait for several blocks to be mined before assuming the contract is secure.
However, PRBProxy eliminates this risk entirely, making it possible to safely send funds to the proxy before it is deployed.

## Deployments

PRBProxyRegistry is deployed on 10+ chains at 0x584009E9eDe26e212182c9745F5c000191296a78. A sortable, searchable list of all available chains can be
found at https://prbproxy.com/deployments. To request a deployment to a new chain, please open a GitHub issue. You can speed up the process by sending
funds to cover the deploy cost to the deployer account: 0x3Afb8fEDaC6429E2165E84CC43EeA7e42e6440fF.

### ABIs

The ABIs can be found on https://prbproxy.com/abi, where they can be downloaded or copied to the clipboard in various formats, including:

- Solidity interfaces
- JSON ABIs, prettified
- viem human readable ABIs

Alternatively, you can:

- Download the ABIs from the [releases](https://github.com/PaulRBerg/prb-proxy/releases) page.
- Copy the ABIs from [Etherscan](https://etherscan.io/address/0x584009E9eDe26e212182c9745F5c000191296a78).
- Install [Foundry](https://getfoundry.sh/) and run `cast interface 0x584009E9eDe26e212182c9745F5c000191296a78`.
- Use one of the programmatic methods described below.

## Install

You can get access to the Solidity code and the ABIs programmatically.

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

### No Upgradeability

For the avoidance of doubt, PRBProxy is not an upgradeable proxy[^1]. It is a "forwarding" proxy whose sole purpose is to delegate calls to target and
plugin contracts.

Both PRBProxyRegistry and PRBProxy are immutable contracts. Their source code cannot be changed once deployed.

### Targets and Plugins

See this repository's [wiki](https://github.com/PaulRBerg/prb-proxy/wiki) page for guidance on how to write targets and plugins.

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

<!-- Footnotes -->

[^1]:
    The term "proxy" can refer to different concepts in Ethereum, most notably upgradeable proxies, a design popularized by
    [OpenZeppelin](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies) that enables contract owners to upgrade the contract's logic. It's
    critical to note that PRBProxy does not fall under this category of upgradeable proxies.
