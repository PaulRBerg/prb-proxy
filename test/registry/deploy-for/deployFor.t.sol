// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract DeployFor_Test is Registry_Test {
    function setUp() public override {
        Registry_Test.setUp();
    }

    function test_RevertWhen_OwnerHasProxy() external {
        IPRBProxy proxy = registry.deployFor({ owner: users.alice });
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_OwnerHasProxy.selector, users.alice, proxy)
        );
        registry.deployFor({ owner: users.alice });
    }

    modifier whenOwnerDoesNotHaveProxy() {
        _;
    }

    function testFuzz_DeployFor_ProxyAddress(address operator, address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: operator });
        address actualProxy = address(registry.deployFor(owner));
        address expectedProxy = computeProxyAddress(owner);
        assertEq(actualProxy, expectedProxy, "deployed proxy address mismatch");
    }

    function testFuzz_DeployFor_ProxyOwner(address operator, address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: operator });
        IPRBProxy proxy = registry.deployFor(owner);
        address actualOwner = proxy.owner();
        address expectedOwner = owner;
        assertEq(actualOwner, expectedOwner, "proxy owner mismatch");
    }

    function testFuzz_DeployFor_UpdateProxies(address operator, address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: operator });
        registry.deployFor(owner);

        address actualProxyAddress = address(registry.getProxy(owner));
        address expectedProxyAddress = computeProxyAddress(owner);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address mismatch");
    }

    function testFuzz_DeployFor_Event(address operator, address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ msgSender: operator });

        vm.expectEmit({ emitter: address(registry) });
        emit DeployProxy({ operator: operator, owner: owner, proxy: IPRBProxy(computeProxyAddress(owner)) });
        registry.deployFor(owner);
    }
}
