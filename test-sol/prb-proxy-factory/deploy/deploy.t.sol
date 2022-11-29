// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { PRBProxy } from "src/PRBProxy.sol";
import { PRBProxyFactoryTest } from "../PRBProxyFactoryTest.t.sol";

contract PRBProxyFactory__Deploy is PRBProxyFactoryTest {
    address internal deployer;

    function setUp() public override {
        super.setUp();
        deployer = users.alice;
    }

    /// @dev it should deploy the proxy.
    function testDeploy() external {
        address factoryProxyAddress = prbProxyFactory.deploy();
        bytes memory actualRuntimeBytecode = factoryProxyAddress.code;
        address testProxyAddress = deployProxy();
        bytes memory expectedRuntimeBytecode = testProxyAddress.code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode);
    }

    /// @dev it should update the next seeds mapping.
    function testDeploy__UpdateNextSeeds() external {
        prbProxyFactory.deploy();
        bytes32 actualNextSeed = prbProxyFactory.getNextSeed(deployer);
        bytes32 expectedNextSeed = SEED_ONE;
        assertEq(actualNextSeed, expectedNextSeed);
    }

    /// @dev it should update the proxies mapping.
    function testDeploy__UpdateProxies() external {
        address proxyAddress = prbProxyFactory.deploy();
        bool actualIsProxy = prbProxyFactory.isProxy(proxyAddress);
        bool expectedIsProxy = true;
        assertEq(actualIsProxy, expectedIsProxy);
    }

    /// @dev it should emit a DeployProxy event.
    function testDeploy__Event() external {
        vm.expectEmit(true, true, true, true);
        bytes32 salt = keccak256(abi.encode(deployer, SEED_ZERO));
        bytes memory deploymentBytecode = type(PRBProxy).creationCode;
        bytes32 deploymentBytecodeHash = keccak256(deploymentBytecode);
        address proxyAddress = computeCreate2Address(salt, deploymentBytecodeHash, address(prbProxyFactory));
        emit DeployProxy(deployer, deployer, deployer, SEED_ZERO, salt, proxyAddress);
        prbProxyFactory.deploy();
    }
}
