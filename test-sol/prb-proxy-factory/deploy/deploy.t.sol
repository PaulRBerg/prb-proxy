// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { PRBProxy } from "src/PRBProxy.sol";

import { BaseTest } from "../../BaseTest.t.sol";
import { PRBProxyFactory_Test } from "../PRBProxyFactory.t.sol";

contract Deploy_Test is PRBProxyFactory_Test {
    address internal deployer;

    function setUp() public override {
        BaseTest.setUp();
        deployer = users.owner;
    }

    /// @dev it should deploy the proxy.
    function test_Deploy() external {
        address factoryProxyAddress = address(factory.deploy());
        bytes memory actualRuntimeBytecode = factoryProxyAddress.code;
        address testProxyAddress = address(deployProxy());
        bytes memory expectedRuntimeBytecode = testProxyAddress.code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode);
    }

    /// @dev it should update the next seeds mapping.
    function test_Deploy_UpdateNextSeeds() external {
        factory.deploy();
        bytes32 actualNextSeed = factory.getNextSeed(deployer);
        bytes32 expectedNextSeed = SEED_ONE;
        assertEq(actualNextSeed, expectedNextSeed);
    }

    /// @dev it should update the proxies mapping.
    function test_Deploy_UpdateProxies() external {
        IPRBProxy proxy = factory.deploy();
        bool isProxy = factory.isProxy(proxy);
        assertTrue(isProxy);
    }

    /// @dev it should emit a DeployProxy event.
    function test_Deploy_Event() external {
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
        bytes32 salt = keccak256(abi.encode(deployer, SEED_ZERO));
        bytes memory deploymentBytecode = type(PRBProxy).creationCode;
        bytes32 deploymentBytecodeHash = keccak256(deploymentBytecode);
        address proxyAddress = computeCreate2Address(salt, deploymentBytecodeHash, address(factory));
        emit DeployProxy({
            origin: deployer,
            deployer: deployer,
            owner: deployer,
            seed: SEED_ZERO,
            salt: salt,
            proxy: IPRBProxy(proxyAddress)
        });
        factory.deploy();
    }
}
