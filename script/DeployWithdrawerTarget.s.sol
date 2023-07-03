// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { WithdrawerTarget } from "../src/WithdrawerTarget.sol";

import { BaseScript } from "./Base.s.sol";

contract DeployWithdrawerTarget is BaseScript {
    function run() public virtual broadcaster returns (WithdrawerTarget withdrawer) {
        withdrawer = new WithdrawerTarget();
    }
}
