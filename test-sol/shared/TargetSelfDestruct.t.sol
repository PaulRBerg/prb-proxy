// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

contract TargetSelfDestruct {
    function destroyMe(address payable recipient) external {
        selfdestruct(recipient);
    }
}
