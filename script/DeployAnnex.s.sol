// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { PRBProxyAnnex } from "../src/PRBProxyAnnex.sol";

import { BaseScript } from "./Base.s.sol";

contract DeployAnnex is BaseScript {
    function run() public virtual broadcaster returns (PRBProxyAnnex annex) {
        annex = new PRBProxyAnnex();
    }
}
