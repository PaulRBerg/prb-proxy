// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

contract TargetSelfDestructer {
    function destroyMe(address payable recipient) external {
        selfdestruct(recipient);
    }
}
