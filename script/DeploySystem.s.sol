// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyAnnex } from "../src/PRBProxyAnnex.sol";
import { PRBProxyRegistry } from "../src/PRBProxyRegistry.sol";

import { BaseScript } from "./Base.s.sol";

contract DeploySystem is BaseScript {
    function run() public virtual broadcaster returns (PRBProxyAnnex annex, PRBProxyRegistry registry) {
        annex = new PRBProxyAnnex();
        registry = new PRBProxyRegistry();
    }
}
