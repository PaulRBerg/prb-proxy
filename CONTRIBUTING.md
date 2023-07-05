# Contributing

Feel free to dive in! [Open](https://github.com/PaulRBerg/prb-proxy/issues/new) an issue,
[start](https://github.com/PaulRBerg/prb-proxy/discussions/new) a discussion, or submit a PR.

## Pre Requisites

You will need the following software on your machine:

- [Git](https://git-scm.com/downloads)
- [Foundry](https://github.com/foundry-rs/foundry)
- [Node.Js](https://nodejs.org/en/download/)
- [Pnpm](https://pnpm.io)

In addition, familiarity with [Solidity](https://soliditylang.org/) is requisite.

## Set Up

Clone this repository including submodules:

```sh
$ git clone --recurse-submodules -j8 git@github.com:PaulRBerg/prb-proxy.git
```

Then, inside the project's directory, run this to install the Node.js dependencies:

```sh
$ pnpm install
```

Now you can start making changes.

## Development

This repo uses Foundry for development and testing and git submodules for dependency management.

You can run the tests with the following command:

```sh
$ forge test
```

Forge will automatically install any missing dependencies.

## Syntax Highlighting

You will need the following VSCode extensions:

- [hardhat-solidity](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity)
- [vscode-tree-language](https://marketplace.visualstudio.com/items?itemName=CTC.vscode-tree-extension)
