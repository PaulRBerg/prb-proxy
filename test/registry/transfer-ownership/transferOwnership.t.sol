// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

/// @dev User roles:
/// - Alice is the caller
/// - Bob is the new owner
contract TransferOwnership_Test is Registry_Test {
    function setUp() public override {
        Registry_Test.setUp();
    }

    /// @dev it should revert.
    function test_RevertWhen_NewOwnerHasProxy() external {
        registry.deploy();
        IPRBProxy proxy = registry.deployFor({ owner: users.bob });
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_OwnerHasProxy.selector, users.bob, proxy)
        );
        registry.transferOwnership({ newOwner: users.bob });
    }

    modifier newOwnerDoesNotHaveProxy() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_CallerDoesNotHaveProxy() external newOwnerDoesNotHaveProxy {
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_OwnerDoesNotHaveProxy.selector, users.alice)
        );
        registry.transferOwnership({ newOwner: users.bob });
    }

    modifier callerHasProxy() {
        proxy = registry.deploy();
        _;
    }

    /// @dev it should transfer the ownership.
    function testFuzz_TransferOwnership_DeleteProxy(address newOwner)
        external
        newOwnerDoesNotHaveProxy
        callerHasProxy
    {
        vm.assume(newOwner != users.alice);

        registry.transferOwnership(newOwner);
        address actualProxy = address(registry.getProxy({ owner: users.alice }));
        address expectedProxy = address(0);
        assertEq(actualProxy, expectedProxy, "proxy for caller");
    }

    /// @dev it should transfer the ownership.
    function testFuzz_TransferOwnership_SetProxy(address newOwner) external newOwnerDoesNotHaveProxy callerHasProxy {
        vm.assume(newOwner != users.alice);

        registry.transferOwnership(newOwner);
        address actualProxy = address(registry.getProxy({ owner: newOwner }));
        address expectedProxy = address(proxy);
        assertEq(actualProxy, expectedProxy, "proxy for new owner");
    }

    /// @dev it should emit a {TransferOwnership} event.
    function testFuzz_TransferOwnership_Event(address newOwner) external newOwnerDoesNotHaveProxy callerHasProxy {
        vm.assume(newOwner != users.alice);

        vm.expectEmit();
        emit TransferOwnership({ proxy: proxy, oldOwner: users.alice, newOwner: newOwner });
        registry.transferOwnership(newOwner);
    }
}
