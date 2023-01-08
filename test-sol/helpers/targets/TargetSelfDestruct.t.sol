// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

contract TargetSelfDestruct {
    function destroyMe(address payable recipient) external {
        selfdestruct(recipient);
    }
}
