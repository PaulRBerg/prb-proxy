// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { PRBProxy } from "src/PRBProxy.sol";

import { Base_Test } from "../../Base.t.sol";
import { PRBProxyFactory_Test } from "../PRBProxyFactory.t.sol";

contract DeployFor_Test is PRBProxyFactory_Test {
    address internal deployer;
    address internal owner;

    function setUp() public override {
        Base_Test.setUp();
        deployer = users.alice;
    }

    /// @dev it should deploy the proxy.
    function test_DeployFor_TxOriginSameAsOwner() external {
        // Deploy the first proxy.
        bytes memory actualRuntimeBytecode = address(factory.deployFor(deployer)).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    modifier txOriginNotSameAsOwner() {
        _;
    }

    /// @dev it should deploy the proxy.
    function test_DeployFor_FirstProxy() external txOriginNotSameAsOwner {
        owner = users.bob;
        bytes memory actualRuntimeBytecode = address(factory.deployFor(owner)).code;
        bytes memory expectedRuntimeBytecode = address(deployProxy()).code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    modifier notFirstProxy() {
        // Deploy the first proxy.
        owner = users.bob;
        factory.deployFor(owner);
        _;
    }

    /// @dev it should deploy the proxy.
    function test_DeployFor_TxOriginNotSameAsOwner_NotFirstProxy() external txOriginNotSameAsOwner notFirstProxy {
        address factoryProxyAddress = address(factory.deployFor(owner));
        bytes memory actualRuntimeBytecode = factoryProxyAddress.code;
        address testProxyAddress = address(deployProxy());
        bytes memory expectedRuntimeBytecode = testProxyAddress.code;
        assertEq(actualRuntimeBytecode, expectedRuntimeBytecode, "runtime bytecode");
    }

    /// @dev it should update the next seeds mapping.
    function test_DeployFor_TxOriginNotSameAsOwner_NotFirstProxy_UpdateNextSeeds()
        external
        txOriginNotSameAsOwner
        notFirstProxy
    {
        factory.deployFor(owner);
        bytes32 actualNextSeed = factory.getNextSeed(deployer);
        bytes32 expectedNextSeed = SEED_TWO;
        assertEq(actualNextSeed, expectedNextSeed, "nextSeed");
    }

    /// @dev it should update the proxies mapping.
    function test_DeployFor_UpdateProxies() external txOriginNotSameAsOwner notFirstProxy {
        IPRBProxy proxy = factory.deployFor(owner);
        bool isProxy = factory.isProxy(proxy);
        assertTrue(isProxy);
    }

    /// @dev it should emit a {DeployProxy} event.
    function test_DeployFor_Event() external txOriginNotSameAsOwner notFirstProxy {
        expectEmit();
        bytes32 salt = keccak256(abi.encode(deployer, SEED_ONE));
        bytes memory creationBytecode = getProxyBytecode();
        bytes32 creationBytecodeHash = keccak256(creationBytecode);
        address proxyAddress = computeCreate2Address(salt, creationBytecodeHash, address(factory));
        emit DeployProxy({
            origin: deployer,
            deployer: deployer,
            owner: owner,
            seed: SEED_ONE,
            salt: salt,
            proxy: IPRBProxy(proxyAddress)
        });
        factory.deployFor(owner);
    }
}
