// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { PRBProxy_Test } from "../PRBProxy.t.sol";

contract TransferOwnership_Test is PRBProxy_Test {
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

    modifier CallerOwner() {
        _;
    }

    /// @dev it should transfer the ownership.
    function test_TransferOwnership_ToZeroAddress() external CallerOwner {
        address newOwner = address(0);
        proxy.transferOwnership(newOwner);
        address actualOwner = proxy.owner();
        address expectedOwner = newOwner;
        assertEq(actualOwner, expectedOwner);
    }

    modifier ToNonZeroAddress() {
        _;
    }

    /// @dev it should transfer the ownership.
    function test_TransferOwnership() external CallerOwner ToNonZeroAddress {
        address newOwner = users.bob;
        proxy.transferOwnership(newOwner);
        address actualOwner = proxy.owner();
        address expectedOwner = newOwner;
        assertEq(actualOwner, expectedOwner);
    }

    /// @dev it should emit a TransferOwnership event.
    function test_TransferOwnership_Event() external CallerOwner ToNonZeroAddress {
        address oldOwner = owner;
        address newOwner = users.bob;
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: false, checkData: false });
        emit TransferOwnership(oldOwner, newOwner);
        proxy.transferOwnership(newOwner);
    }
}
