// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { eqString } from "@prb/test/Helpers.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";

import { IPRBProxy } from "../src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "../src/interfaces/IPRBProxyRegistry.sol";
import { PRBProxy } from "../src/PRBProxy.sol";
import { PRBProxyRegistry } from "../src/PRBProxyRegistry.sol";

import { PluginDummy } from "./mocks/plugins/PluginDummy.sol";
import { PluginEcho } from "./mocks/plugins/PluginEcho.sol";
import { PluginEmpty } from "./mocks/plugins/PluginEmpty.sol";
import { PluginPanic } from "./mocks/plugins/PluginPanic.sol";
import { PluginReverter } from "./mocks/plugins/PluginReverter.sol";
import { PluginSelfDestructer } from "./mocks/plugins/PluginSelfDestructer.sol";
import { TargetDummy } from "./mocks/targets/TargetDummy.sol";
import { TargetDummyWithFallback } from "./mocks/targets/TargetDummyWithFallback.sol";
import { TargetEcho } from "./mocks/targets/TargetEcho.sol";
import { TargetPanic } from "./mocks/targets/TargetPanic.sol";
import { TargetReverter } from "./mocks/targets/TargetReverter.sol";
import { TargetSelfDestructer } from "./mocks/targets/TargetSelfDestructer.sol";
import { Assertions } from "./utils/Assertions.sol";
import { Events } from "./utils/Events.sol";

/// @notice Base test contract with common logic needed by all test contracts.
abstract contract Base_Test is Assertions, Events, StdCheats, StdUtils {
    /*//////////////////////////////////////////////////////////////////////////
                                       STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    struct Plugins {
        PluginDummy dummy;
        PluginEcho echo;
        PluginEmpty empty;
        PluginPanic panic;
        PluginReverter reverter;
        PluginSelfDestructer selfDestructer;
    }

    struct Targets {
        TargetDummy dummy;
        TargetDummyWithFallback dummyWithFallback;
        TargetEcho echo;
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
                                      CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint256 internal constant DEFAULT_MIN_GAS_RESERVE = 5000;
    bytes32 internal constant SEED_ONE = bytes32(uint256(0x01));
    bytes32 internal constant SEED_TWO = bytes32(uint256(0x02));
    bytes32 internal constant SEED_ZERO = bytes32(uint256(0x00));

    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    Plugins internal plugins;
    Targets internal targets;
    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

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
            dummy: new PluginDummy(),
            echo: new PluginEcho(),
            empty: new PluginEmpty(),
            panic: new PluginPanic(),
            reverter: new PluginReverter(),
            selfDestructer: new PluginSelfDestructer()
        });

        // Create the targets.
        targets = Targets({
            dummy: new TargetDummy(),
            dummyWithFallback: new TargetDummyWithFallback(),
            echo: new TargetEcho(),
            panic: new TargetPanic(),
            reverter: new TargetReverter(),
            selfDestructer: new TargetSelfDestructer()
        });

        // Deploy the proxy registry.
        deployRegistryConditionally();

        // Make Alice both the caller and the origin.
        vm.startPrank({ msgSender: users.alice, txOrigin: users.alice });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Computes the proxy address without deploying it.
    function computeProxyAddress(address origin, bytes32 seed) internal returns (address) {
        bytes32 salt = keccak256(abi.encode(origin, seed));
        bytes32 creationBytecodeHash = keccak256(getProxyBytecode());
        // Use the Create2 utility from Forge Std.
        return computeCreate2Address({ salt: salt, initcodeHash: creationBytecodeHash, deployer: address(registry) });
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with test assets.
    function createUser(string memory name) internal returns (address payable addr) {
        addr = payable(makeAddr(name));
        vm.deal({ account: addr, newBalance: 100 ether });
    }

    /// @dev Deploys {PRBProxyRegistry} from a source precompiled with `--via-ir`.
    function deployPrecompiledRegistry() internal returns (IPRBProxyRegistry registry_) {
        registry_ = IPRBProxyRegistry(deployCode("out-optimized/PRBProxyRegistry.sol/PRBProxyRegistry.json"));
    }

    /// @dev Conditionally deploy the registry either normally or from a source precompiled with `--via-ir`.
    function deployRegistryConditionally() internal {
        if (!isTestOptimizedProfile()) {
            registry = new PRBProxyRegistry();
        } else {
            registry = deployPrecompiledRegistry();
        }

        vm.label({ account: address(registry), newLabel: "Registry" });
    }

    /// @dev Reads the proxy bytecode either normally or from precompiled source.
    function getProxyBytecode() internal returns (bytes memory) {
        if (!isTestOptimizedProfile()) {
            return type(PRBProxy).creationCode;
        } else {
            return vm.getCode("out-optimized/PRBProxy.sol/PRBProxy.json");
        }
    }

    /// @dev Checks if the Foundry profile is "test-optimized".
    function isTestOptimizedProfile() internal returns (bool) {
        string memory profile = vm.envOr("FOUNDRY_PROFILE", string(""));
        return eqString(profile, "test-optimized");
    }
}
