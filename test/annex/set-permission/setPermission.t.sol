// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Annex_Test } from "../Annex.t.sol";

contract SetPermission_Test is Annex_Test {
    function test_SetPermission_PermissionNotSet() external {
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        bool permission = proxy.permissions({ envoy: users.envoy, target: address(targets.dummy) });
        assertTrue(permission, "permission mismatch");
    }

    modifier whenPermissionSet() {
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        _;
    }

    function test_SetPermission_ResetPermission() external whenPermissionSet {
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        bool permission = proxy.permissions({ envoy: users.envoy, target: address(targets.dummy) });
        assertTrue(permission, "permission mismatch");
    }

    function test_SetPermission_ResetPermission_Event() external whenPermissionSet {
        vm.expectEmit({ emitter: address(proxy) });
        emit SetPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
    }

    function test_SetPermission_UnsetPermission() external whenPermissionSet {
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: false });
    }

    function test_SetPermission_UnsetPermission_Event() external whenPermissionSet {
        vm.expectEmit({ emitter: address(proxy) });
        emit SetPermission({ envoy: users.envoy, target: address(targets.dummy), permission: false });
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: false });
    }
}
