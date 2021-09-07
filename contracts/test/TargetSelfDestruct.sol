// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

/// @title TargetSelfDestruct
/// @author Paul Razvan Berg
contract TargetSelfDestruct {
    function destroyMe() external {
        selfdestruct(payable(0));
    }
}
