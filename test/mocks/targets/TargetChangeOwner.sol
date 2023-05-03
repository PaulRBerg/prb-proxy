// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { PRBProxyStorage } from "../../../src/abstracts/PRBProxyStorage.sol";

contract TargetChangeOwner is PRBProxyStorage {
    function changeIt() external {
        owner = address(1729);
    }
}
