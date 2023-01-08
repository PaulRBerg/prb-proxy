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
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_NotOwner.selector, users.owner, caller));
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
        assertEq(actualOwner, expectedOwner);
    }

    modifier toNonZeroAddress() {
        _;
    }

    /// @dev it should transfer the ownership.
    function test_TransferOwnership() external callerOwner toNonZeroAddress {
        address newOwner = users.alice;
        proxy.transferOwnership(newOwner);
        address actualOwner = proxy.owner();
        address expectedOwner = newOwner;
        assertEq(actualOwner, expectedOwner);
    }

    /// @dev it should emit a TransferOwnership event.
    function test_TransferOwnership_Event() external callerOwner toNonZeroAddress {
        address oldOwner = users.owner;
        address newOwner = users.alice;
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: false, checkData: false });
        emit TransferOwnership(oldOwner, newOwner);
        proxy.transferOwnership(newOwner);
    }
}
