// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

contract TargetSelfDestructer {
    function destroyMe(address payable recipient) external {
        selfdestruct(recipient);
    }
}
