// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyAnnex } from "../src/PRBProxyAnnex.sol";
import { PRBProxyRegistry } from "../src/PRBProxyRegistry.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev Deploys {PRBProxyAnnex} and {PRBProxyRegistry} at deterministic addresses across chains.
/// @dev Reverts if any contract has already been deployed.
contract DeployDeterministicSystem is BaseScript {
    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    function run(uint256 create2Salt)
        public
        virtual
        broadcaster
        returns (PRBProxyAnnex annex, PRBProxyRegistry registry)
    {
        annex = new PRBProxyAnnex{ salt: bytes32(create2Salt) }();
        registry = new PRBProxyRegistry{ salt: bytes32(create2Salt) }();
    }
}
