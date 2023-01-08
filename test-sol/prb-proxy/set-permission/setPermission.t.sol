// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { PRBProxy_Test } from "../PRBProxy.t.sol";
import { TargetDummy } from "../../helpers/targets/TargetDummy.t.sol";

contract SetPermission_Test is PRBProxy_Test {
    bytes4 internal constant selector = TargetDummy.foo.selector;

    /// @dev it should revert.
    function test_RevertWhen_CallerNotOwner() external {
        // Make Eve the caller in this test.
        address caller = users.eve;
        changePrank(caller);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_NotOwner.selector, owner, caller));
        proxy.setPermission(caller, address(targets.dummy), selector, true);
    }

    modifier CallerOwner() {
        _;
    }

    /// @dev it should set the permission.
    function test_SetPermission_PermissionNotSet() external CallerOwner {
        proxy.setPermission(envoy, address(targets.dummy), selector, true);
        bool permission = proxy.getPermission(envoy, address(targets.dummy), selector);
        assertTrue(permission);
    }

    modifier PermissionSet() {
        proxy.setPermission(envoy, address(targets.dummy), selector, true);
        _;
    }

    /// @dev it should do nothing when re-setting the permission.
    function test_SetPermission_PermissionSet_ResetPermission() external CallerOwner PermissionSet {
        proxy.setPermission(envoy, address(targets.dummy), selector, true);
        bool permission = proxy.getPermission(envoy, address(targets.dummy), selector);
        assertTrue(permission);
    }

    /// @dev it should unset the permission.
    function test_SetPermission_PermissionSet_UnsetPermission() external CallerOwner PermissionSet {
        proxy.setPermission(envoy, address(targets.dummy), selector, false);
        bool permission = proxy.getPermission(envoy, address(targets.dummy), selector);
        assertFalse(permission);
    }
}
