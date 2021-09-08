// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

/// @title TargetSelfDestruct
/// @author Paul Razvan Berg
contract TargetSelfDestruct {
    function destroyMe(address payable recipient) external {
        selfdestruct(recipient);
    }
}
