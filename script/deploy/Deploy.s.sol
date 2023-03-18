// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyHelpers } from "../../src/PRBProxyHelpers.sol";
import { PRBProxyRegistry } from "../../src/PRBProxyRegistry.sol";

import { BaseScript } from "../shared/Base.s.sol";

/// @dev Deploys the {PRBProxyRegistry} and the {PRBProxyHelpers} contracts at deterministic addresses across all
/// chains. Reverts if any of the two contracts has already been deployed.
contract Deploy is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy the contract via a deterministic CREATE2 factory.
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run() public virtual broadcaster returns (PRBProxyHelpers helpers, PRBProxyRegistry registry) {
        registry = new PRBProxyRegistry{ salt: ZERO_SALT }();
        helpers = new PRBProxyHelpers{ salt: ZERO_SALT }();
    }
}
