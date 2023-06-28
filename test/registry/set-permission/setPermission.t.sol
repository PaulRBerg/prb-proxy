// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract SetPermission_Test is Registry_Test {
    function test_RevertWhen_CallerDoesNotHaveProxy() external {
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_CallerDoesNotHaveProxy.selector, users.bob)
        );
        changePrank({ msgSender: users.bob });
        registry.setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
    }

    modifier whenCallerHasProxy() {
        proxy = registry.deploy();
        _;
    }

    function test_SetPermission_PermissionNotSet() external whenCallerHasProxy {
        registry.setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        bool permission =
            registry.getPermissionByOwner({ owner: users.alice, envoy: users.envoy, target: address(targets.dummy) });
        assertTrue(permission, "permission mismatch");
    }

    modifier whenPermissionSet() {
        registry.setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        _;
    }

    function test_SetPermission_ResetPermission() external whenCallerHasProxy whenPermissionSet {
        registry.setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        bool permission =
            registry.getPermissionByOwner({ owner: users.alice, envoy: users.envoy, target: address(targets.dummy) });
        assertTrue(permission, "permission mismatch");
    }

    function test_SetPermission_ResetPermission_Event() external whenCallerHasProxy whenPermissionSet {
        vm.expectEmit({ emitter: address(registry) });
        emit SetPermission({
            owner: users.alice,
            proxy: proxy,
            envoy: users.envoy,
            target: address(targets.dummy),
            permission: true
        });
        registry.setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
    }

    function test_SetPermission_UnsetPermission() external whenCallerHasProxy whenPermissionSet {
        registry.setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: false });
    }

    function test_SetPermission_UnsetPermission_Event() external whenCallerHasProxy whenPermissionSet {
        vm.expectEmit({ emitter: address(registry) });
        emit SetPermission({
            owner: users.alice,
            proxy: proxy,
            envoy: users.envoy,
            target: address(targets.dummy),
            permission: false
        });
        registry.setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: false });
    }
}
