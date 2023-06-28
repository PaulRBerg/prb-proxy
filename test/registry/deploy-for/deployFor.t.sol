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

    function testFuzz_DeployFor_ProxyAddress(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });
        address actualProxy = address(registry.deployFor(owner));
        address expectedProxy = computeProxyAddress(origin, SEED_ZERO);
        assertEq(actualProxy, expectedProxy, "deployed proxy address mismatch");
    }

    function testFuzz_DeployFor_ProxyOwner(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });
        IPRBProxy proxy = registry.deployFor(owner);
        address actualOwner = proxy.owner();
        address expectedOwner = owner;
        assertEq(actualOwner, expectedOwner, "proxy owner mismatch");
    }

    function testFuzz_DeployFor_UpdateNextSeeds(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });
        registry.deployFor(owner);

        bytes32 actualNextSeed = registry.nextSeeds(origin);
        bytes32 expectedNextSeed = SEED_ONE;
        assertEq(actualNextSeed, expectedNextSeed, "next seed mismatch");
    }

    function testFuzz_DeployFor_UpdateProxies(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });
        registry.deployFor(owner);

        address actualProxyAddress = address(registry.proxies(owner));
        address expectedProxyAddress = computeProxyAddress(origin, SEED_ZERO);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address mismatch");
    }

    function testFuzz_DeployFor_Event(
        address origin,
        address operator,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });

        vm.expectEmit({ emitter: address(registry) });
        emit DeployProxy({
            origin: origin,
            operator: operator,
            owner: owner,
            seed: SEED_ZERO,
            salt: keccak256(abi.encode(origin, SEED_ZERO)),
            proxy: IPRBProxy(computeProxyAddress(origin, SEED_ZERO))
        });
        registry.deployFor(owner);
    }
}
