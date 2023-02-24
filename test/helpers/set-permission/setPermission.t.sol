// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { TargetDummy } from "../../shared/targets/TargetDummy.t.sol";
import { Helpers_Test } from "../Helpers.t.sol";

contract SetPermission_Test is Helpers_Test {
    /// @dev it should revert.
    function test_RevertWhen_CallerNotOwner() external {
        // Make Eve the caller in this test.
        address eve = users.eve;
        changePrank(eve);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_ExecutionUnauthorized.selector, owner, eve, helpers));
        setPermission({ envoy: eve, target: address(targets.dummy), permission: true });
    }

    modifier callerOwner() {
        _;
    }

    /// @dev it should set the permission.
    function test_SetPermission_PermissionNotSet() external callerOwner {
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        bool permission = proxy.getPermission({ envoy: users.envoy, target: address(targets.dummy) });
        assertTrue(permission);
    }

    modifier permissionSet() {
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        _;
    }

    /// @dev it should do nothing when re-setting the permission.
    function test_SetPermission_PermissionSet_ResetPermission() external callerOwner permissionSet {
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        bool permission = proxy.getPermission({ envoy: users.envoy, target: address(targets.dummy) });
        assertTrue(permission);
    }

    /// @dev it should emit a {SetPermission} event.
    function test_SetPermission_PermissionSet_ResetPermission_Event() external callerOwner permissionSet {
        expectEmit();
        emit SetPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
    }

    /// @dev it should unset the permission.
    function test_SetPermission_PermissionSet_UnsetPermission() external callerOwner permissionSet {
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: false });
    }

    /// @dev it should emit a {SetPermission} event.
    function test_SetPermission_PermissionSet_UnsetPermission_Event() external callerOwner permissionSet {
        expectEmit();
        emit SetPermission({ envoy: users.envoy, target: address(targets.dummy), permission: false });
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: false });
    }
}
