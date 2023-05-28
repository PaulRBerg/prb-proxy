// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { eqString } from "@prb/test/Helpers.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyAnnex } from "src/interfaces/IPRBProxyAnnex.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";
import { PRBProxy } from "src/PRBProxy.sol";
import { PRBProxyAnnex } from "src/PRBProxyAnnex.sol";
import { PRBProxyRegistry } from "src/PRBProxyRegistry.sol";

import { PluginChangeOwner } from "./mocks/plugins/PluginChangeOwner.sol";
import { PluginDummy } from "./mocks/plugins/PluginDummy.sol";
import { PluginEcho } from "./mocks/plugins/PluginEcho.sol";
import { PluginEmpty } from "./mocks/plugins/PluginEmpty.sol";
import { PluginPanic } from "./mocks/plugins/PluginPanic.sol";
import { PluginReverter } from "./mocks/plugins/PluginReverter.sol";
import { PluginSelfDestructer } from "./mocks/plugins/PluginSelfDestructer.sol";
import { TargetChangeOwner } from "./mocks/targets/TargetChangeOwner.sol";
import { TargetDummy } from "./mocks/targets/TargetDummy.sol";
import { TargetDummyWithFallback } from "./mocks/targets/TargetDummyWithFallback.sol";
import { TargetEcho } from "./mocks/targets/TargetEcho.sol";
import { TargetMinGasReserve } from "./mocks/targets/TargetMinGasReserve.sol";
import { TargetPanic } from "./mocks/targets/TargetPanic.sol";
import { TargetReverter } from "./mocks/targets/TargetReverter.sol";
import { TargetSelfDestructer } from "./mocks/targets/TargetSelfDestructer.sol";
import { Assertions } from "./utils/Assertions.sol";
import { Events } from "./utils/Events.sol";

/// @title Base_Test
/// @notice Base test contract with common logic needed by all test contracts.
abstract contract Base_Test is Assertions, Events, StdCheats, StdUtils {
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

    IPRBProxyAnnex internal annex;
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

        // Make Alice both the caller and the origin.
        vm.startPrank({ msgSender: users.alice, txOrigin: users.alice });

        // Deploy the proxy system.
        deploySystemConditionally();

        // Labels the contracts most relevant for testing.
        vm.label({ account: address(annex), newLabel: "Annex" });
        vm.label({ account: address(registry), newLabel: "Registry" });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Computes the proxy address without deploying it.
    function computeProxyAddress(address origin, bytes32 seed) internal returns (address proxyAddress) {
        bytes32 salt = keccak256(abi.encode(origin, seed));
        bytes32 creationBytecodeHash = keccak256(getProxyBytecode());
        // Use the Create2 utility from Forge Std.
        proxyAddress =
            computeCreate2Address({ salt: salt, initcodeHash: creationBytecodeHash, deployer: address(registry) });
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with test assets.
    function createUser(string memory name) internal returns (address payable addr) {
        addr = payable(makeAddr(name));
        vm.deal({ account: addr, newBalance: 100 ether });
    }

    /// @dev Deploys {PRBProxyAnnex} from a source precompiled with `--via-ir`.
    function deployPrecompiledAnnex() internal returns (IPRBProxyAnnex annex_) {
        annex_ = IPRBProxyAnnex(deployCode("out-optimized/PRBProxyAnnex.sol/PRBProxyAnnex.json"));
    }

    /// @dev Deploys {PRBProxyRegistry} from a source precompiled with `--via-ir`.
    function deployPrecompiledRegistry() internal returns (IPRBProxyRegistry registry_) {
        registry_ = IPRBProxyRegistry(deployCode("out-optimized/PRBProxyRegistry.sol/PRBProxyRegistry.json"));
    }

    /// @dev Conditionally deploy the proxy system either normally or from a source precompiled with `--via-ir`..
    function deploySystemConditionally() internal {
        // We deploy from precompiled source if the Foundry profile is "test-optimized".
        if (isTestOptimizedProfile()) {
            annex = deployPrecompiledAnnex();
            registry = deployPrecompiledRegistry();
        }
        // We deploy normally for all other profiles.
        else {
            annex = new PRBProxyAnnex();
            registry = new PRBProxyRegistry();
        }
    }

    /// @dev Reads the proxy bytecode either normally or from precompiled source.
    function getProxyBytecode() internal returns (bytes memory bytecode) {
        if (isTestOptimizedProfile()) {
            bytecode = vm.getCode("out-optimized/PRBProxy.sol/PRBProxy.json");
        } else {
            bytecode = type(PRBProxy).creationCode;
        }
    }

    /// @dev Checks if the Foundry profile is "test-optimized".
    function isTestOptimizedProfile() internal returns (bool result) {
        string memory profile = vm.envOr("FOUNDRY_PROFILE", string(""));
        result = eqString(profile, "test-optimized");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ABI ENCODERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev ABI encodes the parameters and calls {PRBProxyAnnex.installPlugin}.
    function installPlugin(IPRBProxyPlugin plugin) internal {
        bytes memory data = abi.encodeCall(annex.installPlugin, (plugin));
        proxy.execute({ target: address(annex), data: data });
    }

    /// @dev ABI encodes the parameters and calls {PRBProxyAnnex.setMinGasReserve}.
    function setMinGasReserve(uint256 newMinGasReserve) internal {
        bytes memory data = abi.encodeCall(annex.setMinGasReserve, (newMinGasReserve));
        proxy.execute({ target: address(annex), data: data });
    }

    /// @dev ABI encodes the parameters and calls {PRBProxyAnnex.setPermission}.
    function setPermission(address envoy, address target, bool permission) internal {
        bytes memory data = abi.encodeCall(annex.setPermission, (envoy, target, permission));
        proxy.execute({ target: address(annex), data: data });
    }

    /// @dev ABI encodes the parameters and calls {PRBProxyAnnex.uninstallPlugin}.
    function uninstallPlugin(IPRBProxyPlugin plugin) internal {
        bytes memory data = abi.encodeCall(annex.uninstallPlugin, (plugin));
        proxy.execute({ target: address(annex), data: data });
    }
}
