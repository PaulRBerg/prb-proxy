# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

[4.0.2]: https://github.com/PaulRBerg/prb-proxy/compare/v4.0.1...v4.0.2
[4.0.1]: https://github.com/PaulRBerg/prb-proxy/compare/v4.0.0...v4.0.1
[4.0.0]: https://github.com/PaulRBerg/prb-proxy/compare/v2.0.0...v4.0.0
[2.0.0]: https://github.com/PaulRBerg/prb-proxy/compare/v1.0.1...v2.0.0
[1.0.1]: https://github.com/PaulRBerg/prb-proxy/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/PaulRBerg/prb-proxy/releases/tag/v1.0.0

## [4.0.2] - 2023-12-28

### Changed

- Install `prb-test` and `forge-std` as Node.js packages ([#179](https://github.com/PaulRBerg/prb-proxy/pull/179)) (@andreivladbrg, @PaulRBerg)
- Update import paths to include `src` ([#179](https://github.com/PaulRBerg/prb-proxy/pull/179)) (@PaulRBerg)
- Make Node.js the default installation option (@PaulRBerg)

### Added

- Include `test/utils` in Node.js package ([#179](https://github.com/PaulRBerg/prb-proxy/pull/179)) (@andreivladbrg, @PaulRBerg)

### Removed

- Remove git submodules ([#179](https://github.com/PaulRBerg/prb-proxy/pull/179)) (@andreivladbrg, @PaulRBerg)

## [4.0.1] - 2023-07-10

### Changed

- Improve documentation ([#163](https://github.com/PaulRBerg/prb-proxy/pull/163)) (@PaulRBerg, @IaroslavMazur)
- Rename `noProxy` to `onlyNonProxyOwner` ([#165](https://github.com/PaulRBerg/prb-proxy/pull/165)) (@PaulRBerg, @IaroslavMazur)
- Rename `owner` parameter to `user` ([#165](https://github.com/PaulRBerg/prb-proxy/pull/165)) (@PaulRBerg, @IaroslavMazur)

### Removed

- Remove unused errors ([#164](https://github.com/PaulRBerg/prb-proxy/pull/164)) (@PaulRBerg, @IaroslavMazur)

## [4.0.0] - 2023-07-07

_Version 3 has been skipped to keep the package version in sync with the contract version_

### Changed

- **Breaking**: Merge the registry and the factory ([#81](https://github.com/PaulRBerg/prb-proxy/pull/81)) (@PaulRBerg)
- **Breaking**: Rename `getCurrentProxy` to `getProxy` (@PaulRBerg)
- **Breaking**: Simplify the envoy permission system ([#72](https://github.com/PaulRBerg/prb-proxy/issues/73)) (@PaulRBerg)
- **Breaking**: Use `owner` instead of `tx.origin` as CREATE2 salt ([#130](https://github.com/PaulRBerg/prb-proxy/pull/130)) (@PaulRBerg)
- Bump Solidity pragmas (@PaulRBerg)
- Change license to MIT ([#49](https://github.com/PaulRBerg/prb-proxy/issues/49)) (@PaulRBerg)
- Rename custom errors to use single underscore ([b954b5](https://github.com/PaulRBerg/prb-proxy/commit/b954b5)) (@PaulRBerg)
- Improve formatting and documentation (@PaulRBerg)
- Lower pragma to `>=0.8.4` in interface files ([46a34c](https://github.com/PaulRBerg/prb-proxy/commit/46a34c)) (@PaulRBerg)
- Make the `owner` an immutable variable ([#120](https://github.com/PaulRBerg/prb-proxy/pull/120)) (@PaulRBerg)
- Make `VERSION` a string ([699f76](https://github.com/PaulRBerg/prb-proxy/commit/699f76)) (@PaulRBerg)
- Reduce deployment size by setting optimizer runs to 200 ([c2f955](https://github.com/PaulRBerg/prb-proxy/commit/c2f955)) (@PaulRBerg)

### Added

- Add ability to deploy a proxy and execute a delegate call to a target in a single transaction (@PaulRBerg)
- Add ASCII art (@PaulRBerg)
- Add plugin system ([#53](https://github.com/PaulRBerg/prb-proxy/pull/53)) (@cleanunicorn, @PaulRBerg)
- Emit event in `setPermission` ([b277fd](https://github.com/PaulRBerg/prb-proxy/commit/b277fd)) (@PaulRBerg)
- Provide testing utilities for deploying precompiled bytecodes (@PaulRBerg)
- Store the registry address as an immutable variable in the proxy (@PaulRBerg)

### Removed

- **Breaking**: Remove `PRBProxyFactory` contract ([#81](https://github.com/PaulRBerg/prb-proxy/pull/81)) (@PaulRBerg)
- **Breaking**: Remove proxy storage ([#120](https://github.com/PaulRBerg/prb-proxy/pull/120)) (@PaulRBerg)
- **Breaking**: Remove `transferOwnership` functionality ([#119](https://github.com/PaulRBerg/prb-proxy/pull/119)) (@PaulRBerg)

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
