// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { PRBProxy_Test } from "../PRBProxy.t.sol";
import { TargetDummy } from "../../shared/targets/TargetDummy.t.sol";

contract SetPermission_Test is PRBProxy_Test {
    /// @dev it should revert.
    function test_RevertWhen_CallerNotOwner() external {
        // Make Eve the caller in this test.
        address caller = users.eve;
        changePrank(caller);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(IPRBProxy.PRBProxy_NotOwner.selector, owner, caller));
        proxy.setPermission({
            envoy: caller,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector,
            permission: true
        });
    }

    modifier callerOwner() {
        _;
    }

    /// @dev it should set the permission.
    function test_SetPermission_PermissionNotSet() external callerOwner {
        proxy.setPermission({
            envoy: users.envoy,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector,
            permission: true
        });
        bool permission = proxy.getPermission({
            envoy: users.envoy,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector
        });
        assertTrue(permission);
    }

    modifier permissionSet() {
        proxy.setPermission({
            envoy: users.envoy,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector,
            permission: true
        });
        _;
    }

    /// @dev it should do nothing when re-setting the permission.
    function test_SetPermission_PermissionSet_ResetPermission() external callerOwner permissionSet {
        proxy.setPermission({
            envoy: users.envoy,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector,
            permission: true
        });
        bool permission = proxy.getPermission({
            envoy: users.envoy,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector
        });
        assertTrue(permission);
    }

    /// @dev it should emit a {SetPermission} event.
    function test_SetPermission_PermissionSet_ResetPermission_Event() external callerOwner permissionSet {
        expectEmit();
        emit SetPermission({
            envoy: users.envoy,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector,
            permission: true
        });
        proxy.setPermission({
            envoy: users.envoy,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector,
            permission: true
        });
    }

    /// @dev it should unset the permission.
    function test_SetPermission_PermissionSet_UnsetPermission() external callerOwner permissionSet {
        proxy.setPermission({
            envoy: users.envoy,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector,
            permission: false
        });
    }

    /// @dev it should emit a {SetPermission} event.
    function test_SetPermission_PermissionSet_UnsetPermission_Event() external callerOwner permissionSet {
        expectEmit();
        emit SetPermission({
            envoy: users.envoy,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector,
            permission: false
        });
        proxy.setPermission({
            envoy: users.envoy,
            target: address(targets.dummy),
            selector: TargetDummy.foo.selector,
            permission: false
        });
    }
}
