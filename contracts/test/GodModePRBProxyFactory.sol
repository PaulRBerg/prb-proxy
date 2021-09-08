// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "../PRBProxyFactory.sol";

/// @title GodModePRBProxyFactory
/// @author Paul Razvan Berg
contract GodModePRBProxyFactory is PRBProxyFactory {
    constructor(IPRBProxy implementaton_) PRBProxyFactory(implementaton_) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function __godMode_clone(bytes32 salt) external returns (address payable proxy) {
        proxy = clone(salt);
    }
}
