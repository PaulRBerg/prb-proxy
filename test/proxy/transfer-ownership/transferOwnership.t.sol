// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { Proxy_Test } from "../Proxy.t.sol";

contract TransferOwnership_Test is Proxy_Test {
    /// @dev it should revert.
    function test_RevertWhen_CallerNotOwner() external {
        // Make Eve the caller in this test.
        address caller = users.eve;
        changePrank(caller);

        // Run the test.
        address newOwner = users.eve;
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_NotOwner.selector, owner, caller));
        proxy.transferOwnership(newOwner);
    }

    modifier callerOwner() {
        _;
    }

    /// @dev it should transfer the ownership.
    function test_TransferOwnership_ToZeroAddress() external callerOwner {
        proxy.transferOwnership(address(0));
        address actualOwner = proxy.owner();
        address expectedOwner = address(0);
        assertEq(actualOwner, expectedOwner, "proxy owner");
    }

    modifier toNonZeroAddress() {
        _;
    }

    /// @dev it should transfer the ownership.
    function test_TransferOwnership() external callerOwner toNonZeroAddress {
        address newOwner = users.bob;
        proxy.transferOwnership(newOwner);
        address actualOwner = proxy.owner();
        address expectedOwner = newOwner;
        assertEq(actualOwner, expectedOwner, "proxy owner");
    }

    /// @dev it should emit a {TransferOwnership} event.
    function test_TransferOwnership_Event() external callerOwner toNonZeroAddress {
        address oldOwner = owner;
        address newOwner = users.bob;
        expectEmit();
        emit TransferOwnership(oldOwner, newOwner);
        proxy.transferOwnership(newOwner);
    }
}
