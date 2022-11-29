// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "forge-std/console2.sol";
import { PRBProxy } from "src/PRBProxy.sol";
import { PRBProxyFactoryTest } from "../PRBProxyFactoryTest.t.sol";

contract PRBProxyFactory__DeployFor is PRBProxyFactoryTest {
    address internal deployer;

    function setUp() public override {
        super.setUp();
        deployer = users.alice;
    }

    /// @dev it should deploy the proxy.
    function testDeployFor__TxOriginSameAsOwner() external {
        // Deploy the first proxy.
        address owner = deployer;
        address factoryProxyAddress = prbProxyFactory.deployFor(owner);
        bytes memory actualRuntimeBytecode = factoryProxyAddress.code;
        address testProxyAddress = deployProxy();
        bytes memory expectedRuntimeBytecode = testProxyAddress.code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode);
    }

    /// @dev it should deploy the proxy.
    function testDeployFor__TxOriginNotSameAsOwner__FirstProxy() external {
        address owner = users.bob;
        address factoryProxyAddress = prbProxyFactory.deployFor(owner);
        bytes memory actualRuntimeBytecode = factoryProxyAddress.code;
        address testProxyAddress = deployProxy();
        bytes memory expectedRuntimeBytecode = testProxyAddress.code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode);
    }

    /// @dev it should deploy the proxy.
    function testDeployFor__TxOriginNotSameAsOwner__NotFirstProxy() external {
        // Deploy the first proxy.
        address owner = users.bob;
        prbProxyFactory.deployFor(owner);

        // Run the test.
        address factoryProxyAddress = prbProxyFactory.deployFor(owner);
        bytes memory actualRuntimeBytecode = factoryProxyAddress.code;
        address testProxyAddress = deployProxy();
        bytes memory expectedRuntimeBytecode = testProxyAddress.code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode);
    }

    /// @dev it should update the next seeds mapping.
    function testDeployFor__TxOriginNotSameAsOwner__NotFirstProxy__UpdateNextSeeds() external {
        // Deploy the first proxy.
        address owner = users.bob;
        prbProxyFactory.deployFor(owner);

        // Run the test.
        prbProxyFactory.deployFor(owner);
        bytes32 actualNextSeed = prbProxyFactory.getNextSeed(deployer);
        bytes32 expectedNextSeed = SEED_TWO;
        console2.logBytes32(actualNextSeed);
        console2.logBytes32(expectedNextSeed);
        assertEq(actualNextSeed, expectedNextSeed);
    }

    /// @dev it should update the proxies mapping.
    function testDeployFor__TxOriginNotSameAsOwner__NotFirstProxy__UpdateProxies() external {
        // Deploy the first proxy.
        address owner = users.bob;
        prbProxyFactory.deployFor(owner);

        // Run the test.
        address proxyAddress = prbProxyFactory.deployFor(owner);
        bool actualIsProxy = prbProxyFactory.isProxy(proxyAddress);
        bool expectedIsProxy = true;
        assertEq(actualIsProxy, expectedIsProxy);
    }

    /// @dev it should emit a DeployProxy event.
    function testDeployFor__TxOriginNotSameAsOwner__NotFirstProxy__Event() external {
        // Deploy the first proxy.
        address owner = users.bob;
        prbProxyFactory.deployFor(owner);

        // Run the test.
        vm.expectEmit(true, true, true, true);
        bytes32 salt = keccak256(abi.encode(deployer, SEED_ONE));
        bytes memory deploymentBytecode = type(PRBProxy).creationCode;
        bytes32 deploymentBytecodeHash = keccak256(deploymentBytecode);
        address proxyAddress = computeCreate2Address(salt, deploymentBytecodeHash, address(prbProxyFactory));
        emit DeployProxy(deployer, deployer, owner, SEED_ONE, salt, proxyAddress);
        prbProxyFactory.deployFor(owner);
    }
}
