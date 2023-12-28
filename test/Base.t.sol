// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { eqString } from "@prb/test/src/Helpers.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";

import { IPRBProxy } from "../src/interfaces/IPRBProxy.sol";
import { IPRBProxyRegistry } from "../src/interfaces/IPRBProxyRegistry.sol";
import { PRBProxy } from "../src/PRBProxy.sol";
import { PRBProxyRegistry } from "../src/PRBProxyRegistry.sol";

import { PluginBasic } from "./mocks/plugins/PluginBasic.sol";
import { PluginCollider } from "./mocks/plugins/PluginCollider.sol";
import { PluginEcho } from "./mocks/plugins/PluginEcho.sol";
import { PluginEmpty } from "./mocks/plugins/PluginEmpty.sol";
import { PluginPanic } from "./mocks/plugins/PluginPanic.sol";
import { PluginReverter } from "./mocks/plugins/PluginReverter.sol";
import { PluginSablier } from "./mocks/plugins/PluginSablier.sol";
import { PluginSelfDestructer } from "./mocks/plugins/PluginSelfDestructer.sol";
import { TargetBasic } from "./mocks/targets/TargetBasic.sol";
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
        PluginBasic basic;
        PluginCollider collider;
        PluginEcho echo;
        PluginEmpty empty;
        PluginPanic panic;
        PluginReverter reverter;
        PluginSablier sablier;
        PluginSelfDestructer selfDestructer;
    }

    struct Targets {
        TargetBasic basic;
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
            basic: new PluginBasic(),
            collider: new PluginCollider(),
            echo: new PluginEcho(),
            empty: new PluginEmpty(),
            panic: new PluginPanic(),
            reverter: new PluginReverter(),
            sablier: new PluginSablier(),
            selfDestructer: new PluginSelfDestructer()
        });

        // Create the targets.
        targets = Targets({
            basic: new TargetBasic(),
            echo: new TargetEcho(),
            panic: new TargetPanic(),
            reverter: new TargetReverter(),
            selfDestructer: new TargetSelfDestructer()
        });

        // Deploy the proxy registry.
        deployRegistryConditionally();

        // Make Alice both the caller and the origin.
        vm.startPrank({ msgSender: users.alice });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Computes the proxy address without deploying it.
    function computeProxyAddress(address owner) internal returns (address) {
        bytes32 salt = bytes32(abi.encodePacked(owner));
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
