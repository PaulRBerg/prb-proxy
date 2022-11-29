// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { IPRBProxy } from "src/IPRBProxy.sol";
import { PRBProxyTest } from "../PRBProxyTest.t.sol";

contract PRBProxy__TransferOwnership is PRBProxyTest {
    /// @dev it should revert.
    function testCannotTransferOwnership__CallerNotOwner() external {
        // Make Eve the caller in this test.
        address caller = users.eve;
        changePrank(caller);

        // Run the test.
        address newOwner = users.eve;
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy__NotOwner.selector, owner, caller));
        prbProxy.transferOwnership(newOwner);
    }

    modifier CallerOwner() {
        _;
    }

    /// @dev it should transfer the ownership.
    function testTransferOwnership__ToZeroAddress() external CallerOwner {
        address newOwner = address(0);
        prbProxy.transferOwnership(newOwner);
        address actualOwner = prbProxy.owner();
        address expectedOwner = newOwner;
        assertEq(actualOwner, expectedOwner);
    }

    modifier ToNonZeroAddress() {
        _;
    }

    /// @dev it should transfer the ownership.
    function testTransferOwnership() external CallerOwner ToNonZeroAddress {
        address newOwner = users.bob;
        prbProxy.transferOwnership(newOwner);
        address actualOwner = prbProxy.owner();
        address expectedOwner = newOwner;
        assertEq(actualOwner, expectedOwner);
    }

    /// @dev it should emit a TransferOwnership event.
    function testTransferOwnership__Event() external CallerOwner ToNonZeroAddress {
        address oldOwner = owner;
        address newOwner = users.bob;
        vm.expectEmit(true, true, false, false);
        emit TransferOwnership(oldOwner, newOwner);
        prbProxy.transferOwnership(newOwner);
    }
}
