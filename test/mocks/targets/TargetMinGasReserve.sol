// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { PRBProxyStorage } from "../../../src/abstracts/PRBProxyStorage.sol";

contract TargetMinGasReserve is PRBProxyStorage {
    function setMinGasReserve(uint256 newMinGasReserve) external {
        minGasReserve = newMinGasReserve;
    }
}
