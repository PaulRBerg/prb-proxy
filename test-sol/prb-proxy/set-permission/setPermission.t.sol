// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { IPRBProxy } from "../../../src/IPRBProxy.sol";
import { PRBProxyTest } from "../PRBProxyTest.t.sol";
import { TargetDummy } from "../../shared/TargetDummy.t.sol";

contract PRBProxy__SetPermission is PRBProxyTest {
    bool internal constant permission = true;
    bytes4 internal constant selector = TargetDummy.foo.selector;

    /// @dev it should revert.
    function testCannotSetPermission__CallerNotOwner() external {
        // Make Eve the caller in this test.
        address caller = users.eve;
        changePrank(caller);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy__NotOwner.selector, owner, caller));
        prbProxy.setPermission(caller, address(targets.dummy), selector, permission);
    }

    modifier CallerOwner() {
        _;
    }

    /// @dev it should set the permission.
    function testSetPermission__PermissionNotSet() external CallerOwner {
        prbProxy.setPermission(envoy, address(targets.dummy), selector, permission);
        bool actualPermission = prbProxy.getPermission(envoy, address(targets.dummy), selector);
        bool expectedPermission = permission;
        assertEq(actualPermission, expectedPermission);
    }

    modifier PermissionSet() {
        prbProxy.setPermission(envoy, address(targets.dummy), selector, permission);
        _;
    }

    /// @dev it should do nothing when re-setting the permission.
    function testSetPermission__PermissionSet__ResetPermission() external CallerOwner PermissionSet {
        prbProxy.setPermission(envoy, address(targets.dummy), selector, permission);
        bool actualPermission = prbProxy.getPermission(envoy, address(targets.dummy), selector);
        bool expectedPermission = permission;
        assertEq(actualPermission, expectedPermission);
    }

    /// @dev it should unset the permission.
    function testSetPermission__PermissionSet__UnsetPermission() external CallerOwner PermissionSet {
        bool newPermission = false;
        prbProxy.setPermission(envoy, address(targets.dummy), selector, newPermission);
        bool actualPermission = prbProxy.getPermission(envoy, address(targets.dummy), selector);
        bool expectedPermission = newPermission;
        assertEq(actualPermission, expectedPermission);
    }
}
