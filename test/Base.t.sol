// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <=0.9.0;

import { ERC20 } from "@prb/contracts/token/erc20/ERC20.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { eqString } from "@prb/test/Helpers.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyFactory } from "src/interfaces/IPRBProxyFactory.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";
import { PRBProxy } from "src/PRBProxy.sol";
import { PRBProxyFactory } from "src/PRBProxyFactory.sol";
import { PRBProxyRegistry } from "src/PRBProxyRegistry.sol";

import { PluginChangeOwner } from "./helpers/plugins/PluginChangeOwner.t.sol";
import { PluginDummy } from "./helpers/plugins/PluginDummy.t.sol";
import { PluginEcho } from "./helpers/plugins/PluginEcho.t.sol";
import { PluginEmpty } from "./helpers/plugins/PluginEmpty.t.sol";
import { PluginPanic } from "./helpers/plugins/PluginPanic.t.sol";
import { PluginReverter } from "./helpers/plugins/PluginReverter.t.sol";
import { PluginSelfDestructer } from "./helpers/plugins/PluginSelfDestructer.t.sol";
import { TargetChangeOwner } from "./helpers/targets/TargetChangeOwner.t.sol";
import { TargetDummy } from "./helpers/targets/TargetDummy.t.sol";
import { TargetDummyWithFallback } from "./helpers/targets/TargetDummyWithFallback.t.sol";
import { TargetEcho } from "./helpers/targets/TargetEcho.t.sol";
import { TargetMinGasReserve } from "./helpers/targets/TargetMinGasReserve.t.sol";
import { TargetPanic } from "./helpers/targets/TargetPanic.t.sol";
import { TargetReverter } from "./helpers/targets/TargetReverter.t.sol";
import { TargetSelfDestructer } from "./helpers/targets/TargetSelfDestructer.t.sol";

/// @title Base_Test
/// @author Paul Razvan Berg
/// @notice Common contract members needed across test contracts.
abstract contract Base_Test is PRBTest, StdCheats, StdUtils {
    /*//////////////////////////////////////////////////////////////////////////
                                       STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    struct Plugins {
        PluginChangeOwner changeOwner;
        PluginDummy dummy;
        PluginEcho echo;
        PluginEmpty empty;
        PluginPanic panic;
        PluginReverter reverter;
        PluginSelfDestructer selfDestructer;
    }

    struct Targets {
        TargetChangeOwner changeOwner;
        TargetDummy dummy;
        TargetDummyWithFallback dummyWithFallback;
        TargetEcho echo;
        TargetMinGasReserve minGasReserve;
        TargetPanic panic;
        TargetReverter reverter;
        TargetSelfDestructer selfDestructer;
    }

    struct Users {
        address payable alice;
        address payable bob;
        address payable envoy;
        address payable eve;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event DeployProxy(
        address indexed origin,
        address indexed deployer,
        address indexed owner,
        bytes32 seed,
        bytes32 salt,
        IPRBProxy proxy
    );

    event Execute(address indexed target, bytes data, bytes response);

    /*//////////////////////////////////////////////////////////////////////////
                                      CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    bytes32 internal constant SEED_ONE = bytes32(uint256(0x01));
    bytes32 internal constant SEED_TWO = bytes32(uint256(0x02));
    bytes32 internal constant SEED_ZERO = bytes32(uint256(0x00));

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Plugins internal plugins;
    Targets internal targets;
    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ERC20 internal dai = new ERC20("Dai Stablecoin", "DAI", 18);
    IPRBProxyFactory internal factory;
    IPRBProxy internal proxy;
    IPRBProxyRegistry internal registry;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Create users for testing.
        users = Users({
            alice: createUser("Alice"),
            bob: createUser("Bob"),
            envoy: createUser("Envoy"),
            eve: createUser("Eve")
        });

        // Create the plugins.
        plugins = Plugins({
            changeOwner: new PluginChangeOwner(),
            dummy: new PluginDummy(),
            echo: new PluginEcho(),
            empty: new PluginEmpty(),
            panic: new PluginPanic(),
            reverter: new PluginReverter(),
            selfDestructer: new PluginSelfDestructer()
        });

        // Create the targets.
        targets = Targets({
            changeOwner: new TargetChangeOwner(),
            dummy: new TargetDummy(),
            dummyWithFallback: new TargetDummyWithFallback(),
            echo: new TargetEcho(),
            minGasReserve: new TargetMinGasReserve(),
            panic: new TargetPanic(),
            reverter: new TargetReverter(),
            selfDestructer: new TargetSelfDestructer()
        });

        // Make Alice both the caller and the origin for all subsequent calls.
        vm.startPrank({ msgSender: users.alice, txOrigin: users.alice });

        /// Deploy the default proxy-related contracts.
        deployDefaultContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to compare two {IPRBProxyPlugin} addresses.
    function assertEq(IPRBProxyPlugin a, IPRBProxyPlugin b) internal {
        assertEq(address(a), address(b));
    }

    /// @dev Helper function to compare two {IPRBProxyPlugin} addresses.
    function assertEq(IPRBProxyPlugin a, IPRBProxyPlugin b, string memory err) internal {
        assertEq(address(a), address(b), err);
    }

    /// @dev Computes the proxy address without deploying it.
    function computeProxyAddress(address deployer, bytes32 seed) internal returns (address proxyAddress) {
        bytes32 salt = keccak256(abi.encode(deployer, seed));
        bytes32 creationBytecodeHash = keccak256(getProxyBytecode());
        // Uses the create2 utility from forge-std.
        proxyAddress = computeCreate2Address(salt, creationBytecodeHash, address(factory));
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with 100 ETH, 1 million DAI,
    /// and 1 million USDC.
    function createUser(string memory name) internal returns (address payable addr) {
        addr = payable(address(uint160(uint256(keccak256(abi.encodePacked(name))))));
        vm.label({ account: addr, newLabel: name });
        vm.deal({ account: addr, newBalance: 100 ether });
        deal({ token: address(dai), to: addr, give: 1_000_000e18 });
    }

    /// @dev Conditionally the default contracts either normally or from precompiled source.
    function deployDefaultContracts() internal {
        // We deploy from precompiled source if the profile is "test-optimized".
        if (isTestOptimizedProfile()) {
            proxy = IPRBProxy(deployCode("optimized-out/PRBProxy.sol/PRBProxy.json"));
            factory = IPRBProxyFactory(deployCode("optimized-out/PRBProxyFactory.sol/PRBProxyFactory.json"));
            registry = IPRBProxyRegistry(
                deployCode("optimized-out/PRBProxyRegistry.sol/PRBProxyRegistry.json", abi.encode(address(factory)))
            );
        }
        // We deploy normally in all other cases.
        else {
            proxy = new PRBProxy();
            factory = new PRBProxyFactory();
            registry = new PRBProxyRegistry(factory);
        }

        // Finally, label all the contracts just deployed.
        vm.label({ account: address(proxy), newLabel: "Proxy" });
        vm.label({ account: address(factory), newLabel: "Factory" });
        vm.label({ account: address(registry), newLabel: "Registry" });
    }

    /// @dev Conditionally deploy the proxy either normally or from precompiled source.
    function deployProxy() internal returns (IPRBProxy deployedProxy) {
        if (isTestOptimizedProfile()) {
            deployedProxy = IPRBProxy(deployCode("optimized-out/PRBProxy.sol/PRBProxy.json"));
        } else {
            deployedProxy = new PRBProxy();
        }

        // Label the proxy.
        vm.label({ account: address(deployedProxy), newLabel: "Proxy" });
    }

    /// @dev Expects an event to be emitted by checking all three topics and the data. As mentioned in the Foundry
    /// Book, the extra `true` arguments don't hurt.
    function expectEmit() internal {
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
    }

    /// @dev Reads the bytecode either normally or from precompiled source.
    function getProxyBytecode() internal returns (bytes memory bytecode) {
        if (isTestOptimizedProfile()) {
            bytecode = vm.getCode("optimized-out/PRBProxy.sol/PRBProxy.json");
        } else {
            bytecode = type(PRBProxy).creationCode;
        }
    }

    /// @dev Checks if the Foundry profile is "test-optimized".
    function isTestOptimizedProfile() internal returns (bool result) {
        string memory profile = vm.envOr("FOUNDRY_PROFILE", string(""));
        result = eqString(profile, "test-optimized");
    }
}
