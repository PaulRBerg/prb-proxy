# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2022-03-10

### Added

- Support for Avalanche (@PaulRBerg)

### Changed

- Change the package name from `prb-proxy` to `@prb/proxy` (@PaulRBerg)
- Change the extension for types from `.d.ts` to `.ts` (@PaulRBerg)
- Upgrade to latest versions of `ethers` (@PaulRBerg)
- Upgrade to Solidity v0.8.12 (@PaulRBerg)
- Use modern Solidity `create2` instead of inline assembly ([#20](https://github.com/PaulRBerg/prb-proxy/pull/20))
  (@transmissions11)
- Use modern Solidity `target.code.length` instead of inline assembly (@PaulRBerg)
  ([#19](https://github.com/PaulRBerg/prb-proxy/pull/19)) (@transmissions11)

### Fixed

- Fix old owner address in `TransferOwnership` ([#29](https://github.com/PaulRBerg/prb-proxy/pull/29) (@PaulRBerg)

### Removed

- The `setMinGasReserve` function (@PaulRBerg)

## [1.0.1] - 2021-10-18

### Added

- Include contracts in npm package (@PaulRBerg)

### Fixed

- Add `override` modifiers so that contacts can be imported in Solidity v0.8.7 and lower (@PaulRBerg)

## [1.0.0] - 2021-10-18

### Added

- First release.

[2.0.0]: https://github.com/PaulRBerg/prb-proxy/compare/v1.0.1...v2.0.0
[1.0.1]: https://github.com/PaulRBerg/prb-proxy/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/PaulRBerg/prb-proxy/releases/tag/v1.0.0
