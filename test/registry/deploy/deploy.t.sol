// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract Deploy_Test is Registry_Test {
    function setUp() public override {
        Registry_Test.setUp();
    }

    function test_RevertWhen_OwnerHasProxy() external {
        IPRBProxy proxy = registry.deploy();
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_OwnerHasProxy.selector, users.alice, proxy)
        );
        registry.deploy();
    }

    modifier whenOwnerDoesNotHaveProxy() {
        _;
    }

    function testFuzz_Deploy_ProxyAddress(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        address actualProxy = address(registry.deploy());
        address expectedProxy = computeProxyAddress(owner);
        assertEq(actualProxy, expectedProxy, "deployed proxy address mismatch");
    }

    function testFuzz_Deploy_ProxyOwner(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        IPRBProxy proxy = registry.deploy();
        address actualOwner = proxy.owner();
        address expectedOwner = owner;
        assertEq(actualOwner, expectedOwner, "proxy owner mismatch");
    }

    function testFuzz_Deploy_UpdateProxies(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        registry.deploy();
        address actualProxy = address(registry.getProxy(owner));
        address expectedProxy = computeProxyAddress({ owner: owner });
        assertEq(actualProxy, expectedProxy, "proxy mapping mismatch");
    }

    function testFuzz_Deploy_Event(address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: owner });
        vm.expectEmit({ emitter: address(registry) });
        emit DeployProxy({ operator: owner, owner: owner, proxy: IPRBProxy(computeProxyAddress(owner)) });
        registry.deploy();
    }
}
