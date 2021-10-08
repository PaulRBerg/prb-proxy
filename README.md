# PRBProxy [![Coverage Status](https://coveralls.io/repos/github/paulrberg/prb-proxy/badge.svg?branch=main)](https://coveralls.io/github/paulrberg/prb-proxy?branch=main) [![Styled with Prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg)](https://prettier.io) [![Commitizen Friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/) [![license: Unlicense](https://img.shields.io/badge/license-Unlicense-yellow.svg)](https://unlicense.org/)

Monorepo implementing PRBProxy and related packages.

## Packages

PRBProxy is maintained with [yarn workspaces](https://yarnpkg.com/features/workspaces). Check out the README
associated to each package for detailed usage instructions.

| Package                                  | Description                                                            |
| ---------------------------------------- | ---------------------------------------------------------------------- |
| [`prb-proxy`](/packages/prb-proxy)       | Proxy contract to compose Ethereum transactions on behalf of the owner |
| [`prb-proxy.js`](/packages/prb-proxy.js) | JavaScript SDK for PRBProxy                                            |

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
