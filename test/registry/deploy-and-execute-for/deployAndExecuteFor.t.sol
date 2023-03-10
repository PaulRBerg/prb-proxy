// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { Registry_Test } from "../Registry.t.sol";

contract DeployAndExecuteFor_Test is Registry_Test {
    bytes internal data;
    uint256 internal input = 1729;
    address internal target;

    function setUp() public override {
        Registry_Test.setUp();

        data = abi.encodeWithSelector(targets.echo.echoUint256.selector, input);
        target = address(targets.echo);
    }

    /// @dev it should revert.
    function test_RevertWhen_OwnerHasProxy() external {
        (IPRBProxy proxy,) = registry.deployAndExecuteFor({ owner: users.alice, target: target, data: data });
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_OwnerHasProxy.selector, users.alice, proxy)
        );
        registry.deployAndExecuteFor({ owner: users.alice, target: target, data: data });
    }

    modifier ownerDoesNotHaveProxy() {
        _;
    }

    /// @dev it should deploy the proxy.
    function testFuzz_DeployAndExecuteFor_Deploy(
        address origin,
        address operator,
        address owner
    )
        external
        ownerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });

        (IPRBProxy actualProxy,) = registry.deployAndExecuteFor(owner, target, data);
        address expectedProxy = computeProxyAddress(origin, SEED_ZERO);
        assertEq(address(actualProxy), expectedProxy, "deployed proxy address");
    }

    /// @dev it should update the next seeds mapping.
    function testFuzz_DeployAndExecuteFor_UpdateNextSeeds(
        address origin,
        address operator,
        address owner
    )
        external
        ownerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });
        registry.deployAndExecuteFor(owner, target, data);

        bytes32 actualNextSeed = registry.getNextSeed(origin);
        bytes32 expectedNextSeed = SEED_ONE;
        assertEq(actualNextSeed, expectedNextSeed, "next seed");
    }

    /// @dev it should update the current proxies mapping.
    function testFuzz_DeployAndExecuteFor_UpdateCurrentProxies(
        address origin,
        address operator,
        address owner
    )
        external
        ownerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });
        registry.deployAndExecuteFor(owner, target, data);

        address actualProxyAddress = address(registry.getProxy(owner));
        address expectedProxyAddress = computeProxyAddress(origin, SEED_ZERO);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address");
    }

    /// @dev it should delegate call to the target contract.
    function testFuzz_DeployAndExecuteFor_Execute(
        address origin,
        address operator,
        address owner
    )
        external
        ownerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });

        (, bytes memory actualResponse) = registry.deployAndExecuteFor(owner, target, data);
        bytes memory expectedResponse = abi.encode(input);
        assertEq(actualResponse, expectedResponse, "echo.echoUint256 response");
    }

    /// @dev it should emit a {DeployProxy} event.
    function testFuzz_DeployAndExecuteFor_Event_Deploy(
        address origin,
        address operator,
        address owner
    )
        external
        ownerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });

        vm.expectEmit();
        emit DeployProxy({
            origin: origin,
            operator: operator,
            owner: owner,
            seed: SEED_ZERO,
            salt: keccak256(abi.encode(origin, SEED_ZERO)),
            proxy: IPRBProxy(computeProxyAddress(origin, SEED_ZERO))
        });
        registry.deployAndExecuteFor(owner, target, data);
    }

    /// @dev it should emit an {Execute} event.
    function testFuzz_DeployAndExecuteFor_Event_Execute(
        address origin,
        address operator,
        address owner
    )
        external
        ownerDoesNotHaveProxy
    {
        changePrank({ txOrigin: origin, msgSender: operator });

        vm.expectEmit();
        emit Execute({ target: address(targets.echo), data: data, response: abi.encode(input) });
        registry.deployAndExecuteFor(owner, target, data);
    }
}
