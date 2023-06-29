// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Registry_Test } from "../Registry.t.sol";

contract GetPermissionByOwner_Test is Registry_Test {
    function setUp() public virtual override {
        Registry_Test.setUp();
        proxy = registry.deploy();
    }

    function test_GetPermissionByOwner_EnvoyDoesNotHavePermission() external {
        bool permission =
            registry.getPermissionByProxy({ proxy: proxy, envoy: users.envoy, target: address(targets.basic) });
        assertFalse(permission, "permission mismatch");
    }

    modifier whenEnvoyHasPermission() {
        registry.setPermission({ envoy: users.envoy, target: address(targets.basic), permission: true });
        _;
    }

    function test_GetPermissionByOwner() external whenEnvoyHasPermission {
        bool permission =
            registry.getPermissionByProxy({ proxy: proxy, envoy: users.envoy, target: address(targets.basic) });
        assertTrue(permission, "permission mismatch");
    }
}
