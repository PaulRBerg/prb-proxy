// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

/// @dev User roles:
/// - Bob is the origin, operator, and owner of the proxy
contract DeployAndExecute_Test is Registry_Test {
    bytes internal data;
    uint256 internal input = 1729;
    address internal target;

    function setUp() public override {
        Registry_Test.setUp();

        data = abi.encodeWithSelector(targets.echo.echoUint256.selector, input);
        target = address(targets.echo);
    }

    function test_RevertWhen_OwnerHasProxy() external {
        IPRBProxy proxy = registry.deployAndExecute(target, data);
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_OwnerHasProxy.selector, users.alice, proxy)
        );
        registry.deployAndExecute(target, data);
    }

    modifier whenOwnerDoesNotHaveProxy() {
        _;
    }

    function testFuzz_DeployAndExecute_ProxyAddress(address origin, address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ txOrigin: origin, msgSender: owner });
        IPRBProxy actualProxy = registry.deployAndExecute(target, data);
        address expectedProxy = computeProxyAddress(origin, SEED_ZERO);
        assertEq(address(actualProxy), expectedProxy, "deployed proxy address mismatch");
    }

    function testFuzz_DeployAndExecute_ProxyOwner(address origin, address owner) external whenOwnerDoesNotHaveProxy {
        changePrank({ txOrigin: origin, msgSender: owner });
        IPRBProxy proxy = registry.deployAndExecute(target, data);
        address actualOwner = proxy.owner();
        address expectedOwner = owner;
        assertEq(actualOwner, expectedOwner, "proxy owner mismatch");
    }

    function testFuzz_DeployAndExecute_UpdateNextSeeds(
        address origin,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: owner });
        registry.deployAndExecute(target, data);

        bytes32 actualNextSeed = registry.nextSeeds(origin);
        bytes32 expectedNextSeed = SEED_ONE;
        assertEq(actualNextSeed, expectedNextSeed, "next seed mismatch");
    }

    function testFuzz_DeployAndExecute_UpdateProxies(
        address origin,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: owner });
        registry.deployAndExecute(target, data);

        address actualProxyAddress = address(registry.getProxy(owner));
        address expectedProxyAddress = computeProxyAddress(origin, SEED_ZERO);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address mismatch");
    }

    function testFuzz_DeployAndExecute_Event_DeployProxy(
        address origin,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: owner });

        vm.expectEmit({ emitter: address(registry) });
        emit DeployProxy({
            origin: origin,
            operator: owner,
            owner: owner,
            seed: SEED_ZERO,
            salt: keccak256(abi.encode(origin, SEED_ZERO)),
            proxy: IPRBProxy(computeProxyAddress(origin, SEED_ZERO))
        });
        registry.deployAndExecute(target, data);
    }

    function testFuzz_DeployAndExecute_Event_Execute(
        address origin,
        address owner
    )
        external
        whenOwnerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: owner });

        vm.expectEmit({ emitter: computeProxyAddress({ origin: origin, seed: SEED_ZERO }) });
        emit Execute({ target: address(targets.echo), data: data, response: abi.encode(input) });
        registry.deployAndExecute(target, data);
    }
}
