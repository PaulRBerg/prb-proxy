# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2022-03-10

### Added

- Support for Avalanche.

### Changed

- Change the package name from `prb-proxy` to `@prb/proxy`.
- Change the extension for types from `.d.ts` to `.ts`.
- Upgrade to latest versions of `ethers`.
- Upgrade to Solidity v0.8.12.
- Use modern Solidity `create2` instead of inline assembly (see [pull request #20](https://github.com/paulrberg/prb-proxy/pull/20)).
- Use modern Solidity `target.code.length` instead of inline assembly (see pull request [pull request #19](https://github.com/paulrberg/prb-proxy/pull/19)).

### Fixed

- Old owner address in `TransferOwnership` (see pull request [pull request #29](https://github.com/paulrberg/prb-proxy/pull/29).

### Removed

- The `setMinGasReserve` function.

## [1.0.1] - 2021-10-18

### Added

- Include contracts in npm package.

### Fixed

- Add `override` modifiers so that contacts can be imported in Solidity v0.8.7 and lower.

## [1.0.0] - 2021-10-18

### Added

- First release.

[2.0.0]: https://github.com/paulrberg/prb-proxy/compare/v1.0.1...v2.0.0
[1.0.1]: https://github.com/paulrberg/prb-proxy/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/paulrberg/prb-proxy/releases/tag/v1.0.0
