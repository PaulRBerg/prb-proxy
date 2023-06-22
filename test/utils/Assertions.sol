// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { PRBTest } from "@prb/test/PRBTest.sol";

import { IPRBProxyPlugin } from "../../src/interfaces/IPRBProxyPlugin.sol";

abstract contract Assertions is PRBTest {
    function assertEq(IPRBProxyPlugin a, IPRBProxyPlugin b) internal {
        assertEq(address(a), address(b));
    }

    function assertEq(IPRBProxyPlugin a, IPRBProxyPlugin b, string memory err) internal {
        assertEq(address(a), address(b), err);
    }

    function assertEq(bytes4[] memory a, bytes4[] memory b) internal {
        uint256[] memory castedA;
        uint256[] memory castedB;
        assembly {
            castedA := a
            castedB := b
        }
        assertEq(castedA, castedB);
    }

    function assertEq(bytes4[] memory a, bytes4[] memory b, string memory err) internal {
        uint256[] memory castedA;
        uint256[] memory castedB;
        assembly {
            castedA := a
            castedB := b
        }
        assertEq(castedA, castedB, err);
    }
}
