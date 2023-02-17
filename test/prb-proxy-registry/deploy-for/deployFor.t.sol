// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";

import { PRBProxyRegistry_Test } from "../PRBProxyRegistry.t.sol";

contract DeployFor_Test is PRBProxyRegistry_Test {
    address internal deployer;
    address internal owner;

    function setUp() public override {
        PRBProxyRegistry_Test.setUp();
        deployer = users.alice;
        owner = users.bob;
    }

    modifier ownerHasProxyInRegistry() {
        _;
    }

    /// @dev it should revert.
    function test_RevertWhen_OwnerDidNotTransferOwnership() external ownerHasProxyInRegistry {
        registry.deployFor(deployer);
        vm.expectRevert(
            abi.encodeWithSelector(IPRBProxyRegistry.PRBProxyRegistry_ProxyAlreadyExists.selector, deployer)
        );
        registry.deployFor(deployer);
    }

    /// @dev it should deploy the proxy.
    function test_DeployFor_OwnerTransferredOwnership() external ownerHasProxyInRegistry {
        IPRBProxy proxy = registry.deployFor(deployer);
        proxy.transferOwnership(address(1729));
        bytes memory actualRuntimeBytecode = address(registry.deployFor(deployer)).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    modifier ownerDoesNotHaveProxyInRegistry() {
        _;
    }

    /// @dev it should deploy the proxy.
    function test_DeployFor_DeployerSameAsOwner() external ownerDoesNotHaveProxyInRegistry {
        bytes memory actualRuntimeBytecode = address(registry.deployFor(deployer)).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    modifier deployerNotSameAsOwner() {
        _;
    }

    /// @dev it should deploy the proxy.
    function test_DeployFor_DeployerDidNotDeployAnotherProxyForTheOwnerViaFactory()
        external
        ownerDoesNotHaveProxyInRegistry
        deployerNotSameAsOwner
    {
        bytes memory actualRuntimeBytecode = address(registry.deployFor(owner)).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    modifier deployerDeployedAnotherProxyForTheOwnerViaFactory() {
        factory.deployFor(owner);
        _;
    }

    /// @dev it should deploy the proxy.
    function test_DeployFor_DeployerDidNotDeployAnotherProxyForHimselfViaFactory()
        external
        ownerDoesNotHaveProxyInRegistry
        deployerNotSameAsOwner
        deployerDeployedAnotherProxyForTheOwnerViaFactory
    {
        bytes memory actualRuntimeBytecode = address(registry.deployFor(owner)).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    modifier deployerDeployedAnotherProxyForHimselfViaFactory() {
        factory.deployFor(deployer);
        _;
    }

    /// @dev it should deploy the proxy.
    function test_DeployFor()
        external
        ownerDoesNotHaveProxyInRegistry
        deployerNotSameAsOwner
        deployerDeployedAnotherProxyForTheOwnerViaFactory
        deployerDeployedAnotherProxyForHimselfViaFactory
    {
        bytes memory actualRuntimeBytecode = address(registry.deployFor(owner)).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    /// @dev it should update the current proxies mapping.
    function test_DeployFor_CurrentProxies()
        external
        ownerDoesNotHaveProxyInRegistry
        deployerNotSameAsOwner
        deployerDeployedAnotherProxyForTheOwnerViaFactory
        deployerDeployedAnotherProxyForHimselfViaFactory
    {
        registry.deployFor(owner);
        address actualProxyAddress = address(registry.getCurrentProxy(owner));
        address expectedProxyAddress = computeProxyAddress(deployer, SEED_TWO);
        assertEq(actualProxyAddress, expectedProxyAddress, "proxy address");
    }

    /// @dev it should emit a {DeployProxy} event.
    function test_DeployFor_Event() external {
        expectEmit();
        bytes32 salt = keccak256(abi.encode(deployer, SEED_ZERO));
        address proxyAddress = computeProxyAddress(deployer, SEED_ZERO);
        emit DeployProxy({
            origin: deployer,
            deployer: address(registry),
            owner: owner,
            seed: SEED_ZERO,
            salt: salt,
            proxy: IPRBProxy(proxyAddress)
        });
        registry.deployFor(owner);
    }
}
