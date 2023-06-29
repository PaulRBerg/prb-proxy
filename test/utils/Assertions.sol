// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { PRBTest } from "@prb/test/PRBTest.sol";

import { IPRBProxyPlugin } from "../../src/interfaces/IPRBProxyPlugin.sol";

abstract contract Assertions is PRBTest {
    /// @dev Compares two {IPRBProxyPlugin} addresses.
    function assertEq(IPRBProxyPlugin a, IPRBProxyPlugin b) internal {
        assertEq(address(a), address(b));
    }

    /// @dev Compares two {IPRBProxyPlugin} addresses.
    function assertEq(IPRBProxyPlugin a, IPRBProxyPlugin b, string memory err) internal {
        assertEq(address(a), address(b), err);
    }
}
