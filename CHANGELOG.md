# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[4.0.0-beta.3]: https://github.com/PaulRBerg/prb-proxy/compare/v4.0.0-beta.2...v4.0.0-beta.3
[4.0.0-beta.2]: https://github.com/PaulRBerg/prb-proxy/compare/v4.0.0-beta.1...v4.0.0-beta.2
[4.0.0-beta.1]: https://github.com/PaulRBerg/prb-proxy/compare/v2.0.0...v4.0.0-beta.1
[2.0.0]: https://github.com/PaulRBerg/prb-proxy/compare/v1.0.1...v2.0.0
[1.0.1]: https://github.com/PaulRBerg/prb-proxy/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/PaulRBerg/prb-proxy/releases/tag/v1.0.0

## [4.0.0-beta.3] - 2023-03-08

### Changed

- Improve documentation (@PaulRBerg)
- Make `permissions` and `plugins` mappings public ([#84](https://github.com/PaulRBerg/prb-proxy/pull/84)) (@andreivladbrg)
- Reorder storage variables ([`d86514`](https://github.com/PaulRBerg/prb-proxy/commit/d86514)) (@PaulRBerg)

### Added

- Add `IRPProxyStorage` interface ([#84](https://github.com/PaulRBerg/prb-proxy/pull/84)) (@andreivladbrg)

### Removed

- Remove getters `getPermission` and `getPluginForMethod` ([#84](https://github.com/PaulRBerg/prb-proxy/pull/84)) (@andreivladbrg)

## [4.0.0-beta.2] - 2023-03-03

### Changed

- Merge the registry and the factory ([#81](https://github.com/PaulRBerg/prb-proxy/pull/81)) (@PaulRBerg)
- Rename `deployer` to `operator` ([#81](https://github.com/PaulRBerg/prb-proxy/pull/81)) (@PaulRBerg)
- Set the owner via the `transientProxyOwner` storage variable ([#81](https://github.com/PaulRBerg/prb-proxy/pull/81)) (@PaulRBerg)
- Transfer ownership via the registry ([#81](https://github.com/PaulRBerg/prb-proxy/pull/81)) (@PaulRBerg)
- Bump submodules (@PaulRBerg)
- Improve documentation (@PaulRBerg)
- Make `VERSION` a string ([699f76](https://github.com/PaulRBerg/prb-proxy/commit/699f76)) (@PaulRBerg)

### Added

- Add `OpenZeppelin/openzeppelin-contracts` submodule

### Removed

- **Breaking**: Remove `PRBProxyFactory` contract ([#81](https://github.com/PaulRBerg/prb-proxy/pull/81)) (@PaulRBerg)
- Remove `PaulRBerg/prb-contracts` submodule

## [4.0.0-beta.1] - 2023-02-25

_Version 3 has been skipped to keep the package version in sync with the contract version_

### Changed

- Change license to MIT ([#49](https://github.com/PaulRBerg/prb-proxy/issues/49)) (@PaulRBerg)
- Format contracts with Forge Formatter (@PaulRBerg)
- Improve documentation (@PaulRBerg)
- Improve formatting (@PaulRBerg)
- Improve names of custom errors, events, and functions (@PaulRBerg)
- Lower pragma to `>=0.8.4` in interface files ([46a34c](https://github.com/PaulRBerg/prb-proxy/commit/46a34c)) (@PaulRBerg)
- Mark factory as immutable ([bcc8aa](https://github.com/PaulRBerg/prb-proxy/commit/bcc8aa)) (@PaulRBerg)
- Move interface files in a nested directory ([b954b5](https://github.com/PaulRBerg/prb-proxy/commit/b954b5)) (@PaulRBerg)
- Move the `setPermission` function to an enshrined target contract ([3f5794](https://github.com/PaulRBerg/prb-proxy/commit/3f5794)) (@PaulRBerg)
- Reduce deployment size by setting optimizer runs to 200 ([c2f955](https://github.com/PaulRBerg/prb-proxy/commit/c2f955)) (@PaulRBerg)
- Rename custom errors to use single underscore ([b954b5](https://github.com/PaulRBerg/prb-proxy/commit/b954b5)) (@PaulRBerg)
- Simplify the envoy permission system ([#72](https://github.com/PaulRBerg/prb-proxy/issues/73)) (@PaulRBerg)
- Update pragmas (@PaulRBerg)
- Use named arguments in function calls (@PaulRBerg)

### Added

- Add `deployAndExecute` functions ([ce9d29](https://github.com/PaulRBerg/prb-proxy/commit/ce9d29)) (@PaulRBerg)
- Add enshrined target contract `PRBProxyHelpers` ([4ca1c9](https://github.com/PaulRBerg/prb-proxy/commit/4ca1c9)) (@PaulRBerg)
- Add plugin system and fallback function ([#53](https://github.com/PaulRBerg/prb-proxy/pull/53)) (@cleanunicorn, @PaulRBerg)
- Add storage contract that replicates the storage layout of the proxy ([1449da](https://github.com/PaulRBerg/prb-proxy/commit/1449da)) (@PaulRBerg)
- Emit event in `setPermission` ([b277fd](https://github.com/PaulRBerg/prb-proxy/commit/b277fd)) (@PaulRBerg)
- Re-implement the `setMinGasReserve` function in the enshrined target ([e6fdfb](https://github.com/PaulRBerg/prb-proxy/commit/e6fdfb)) (@PaulRBerg)

### Fixed

- Fix bug that permitted unintentional calls to fallback functions ([#50](https://github.com/PaulRBerg/prb-proxy/issues/50)) (@PaulRBerg)

## [2.0.0] - 2022-03-10

### Changed

- Change the package name from `prb-proxy` to `@prb/proxy` (@PaulRBerg)
- Change the extension for types from `.d.ts` to `.ts` (@PaulRBerg)
- Upgrade to latest versions of `ethers` (@PaulRBerg)
- Upgrade to Solidity v0.8.12 (@PaulRBerg)
- Use modern Solidity `create2` instead of inline assembly ([#20](https://github.com/PaulRBerg/prb-proxy/pull/20)) (@transmissions11)
- Use modern Solidity `target.code.length` instead of inline assembly (@PaulRBerg) ([#19](https://github.com/PaulRBerg/prb-proxy/pull/19))
  (@transmissions11)

### Added

- Add support for Avalanche (@PaulRBerg)

### Fixed

- Fix old owner address in `TransferOwnership` ([#29](https://github.com/PaulRBerg/prb-proxy/pull/29) (@PaulRBerg)

### Removed

- Remove the `setMinGasReserve` function (@PaulRBerg)

## [1.0.1] - 2021-10-18

### Added

- Include contracts in npm package (@PaulRBerg)

### Fixed

- Add `override` modifiers so that contacts can be imported in Solidity v0.8.7 and lower (@PaulRBerg)

## [1.0.0] - 2021-10-18

### Added

- First release (@PaulRBerg)
