// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { PRBProxyStorage } from "../../../src/abstracts/PRBProxyStorage.sol";

contract TargetSelfDestructer is PRBProxyStorage {
    function destroyMe(address payable recipient) external {
        selfdestruct(recipient);
    }
}
