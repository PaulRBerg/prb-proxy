// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Base_Test } from "../Base.t.sol";

import { StorageMock } from "../shared/mockups/StorageMock.t.sol";

/// @dev The {PRBProxyStorage} contract duplicates the storage layout of the {PRBProxy} contracts, so we
contract Storage_Test is Base_Test {
    StorageMock internal storageMock;

    function setUp() public virtual override {
        Base_Test.setUp();
        proxy = registry.deployFor({ owner: users.alice });
        installPlugin(plugins.dummy);
        setPermission({ envoy: users.envoy, target: address(targets.dummy), permission: true });
        storageMock = new StorageMock({
            owner_: proxy.owner(),
            minGasReserve_: proxy.minGasReserve(),
            method_: targets.dummy.foo.selector,
            plugin_: plugins.dummy,
            envoy_: users.envoy,
            target_: address(targets.dummy)
        });
    }

    function test_Slot0() external {
        bytes32 actualValue = vm.load(address(storageMock), bytes32(uint256(0)));
        bytes32 expectedValue = vm.load(address(proxy), bytes32(uint256(0)));
        assertEq(actualValue, expectedValue, "Slot 0 should be the same");
    }

    function test_Slot1() external {
        bytes32 actualValue = vm.load(address(storageMock), bytes32(uint256(1)));
        bytes32 expectedValue = vm.load(address(proxy), bytes32(uint256(1)));
        assertEq(actualValue, expectedValue, "Slot 1 should be the same");
    }

    function test_Slot2() external {
        bytes32 actualValue = vm.load(address(storageMock), bytes32(uint256(2)));
        bytes32 expectedValue = vm.load(address(proxy), bytes32(uint256(2)));
        assertEq(actualValue, expectedValue, "Slot 2 should be the same");
    }

    function test_Slot3() external {
        bytes32 actualValue = vm.load(address(storageMock), bytes32(uint256(3)));
        bytes32 expectedValue = vm.load(address(proxy), bytes32(uint256(3)));
        assertEq(actualValue, expectedValue, "Slot 3 should be the same");
    }
}
