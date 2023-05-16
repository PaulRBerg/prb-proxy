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

    function testFuzz_Deploy(address origin, address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ txOrigin: origin, msgSender: owner });
        address actualProxy = address(registry.deploy());
        address expectedProxy = computeProxyAddress({ origin: origin, seed: SEED_ZERO });
        assertEq(actualProxy, expectedProxy, "deployed proxy address");
    }

    function testFuzz_Deploy_UpdateNextSeeds(address origin, address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ txOrigin: origin, msgSender: owner });
        registry.deploy();

        bytes32 actualNextSeed = registry.nextSeeds(origin);
        bytes32 expectedNextSeed = SEED_ONE;
        assertEq(actualNextSeed, expectedNextSeed, "next seed");
    }

    function testFuzz_Deploy_UpdateProxies(address origin, address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ txOrigin: origin, msgSender: owner });
        registry.deploy();
        address actualProxy = address(registry.proxies(owner));
        address expectedProxy = computeProxyAddress({ origin: origin, seed: SEED_ZERO });
        assertEq(actualProxy, expectedProxy, "proxy mapping");
    }

    function testFuzz_Deploy_Event(address origin, address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ txOrigin: origin, msgSender: owner });
        vm.expectEmit({ emitter: address(registry) });
        emit DeployProxy({
            origin: origin,
            operator: owner,
            owner: owner,
            seed: SEED_ZERO,
            salt: keccak256(abi.encode(origin, SEED_ZERO)),
            proxy: IPRBProxy(computeProxyAddress({ origin: origin, seed: SEED_ZERO }))
        });
        registry.deploy();
    }
}
