// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";
import { eqString } from "@prb/test/Helpers.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyHelpers } from "src/interfaces/IPRBProxyHelpers.sol";
import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { IPRBProxyRegistry } from "src/interfaces/IPRBProxyRegistry.sol";
import { PRBProxy } from "src/PRBProxy.sol";
import { PRBProxyHelpers } from "src/PRBProxyHelpers.sol";
import { PRBProxyRegistry } from "src/PRBProxyRegistry.sol";

import { PluginChangeOwner } from "./mocks/plugins/PluginChangeOwner.t.sol";
import { PluginDummy } from "./mocks/plugins/PluginDummy.t.sol";
import { PluginEcho } from "./mocks/plugins/PluginEcho.t.sol";
import { PluginEmpty } from "./mocks/plugins/PluginEmpty.t.sol";
import { PluginPanic } from "./mocks/plugins/PluginPanic.t.sol";
import { PluginReverter } from "./mocks/plugins/PluginReverter.t.sol";
import { PluginSelfDestructer } from "./mocks/plugins/PluginSelfDestructer.t.sol";
import { TargetChangeOwner } from "./mocks/targets/TargetChangeOwner.t.sol";
import { TargetDummy } from "./mocks/targets/TargetDummy.t.sol";
import { TargetDummyWithFallback } from "./mocks/targets/TargetDummyWithFallback.t.sol";
import { TargetEcho } from "./mocks/targets/TargetEcho.t.sol";
import { TargetMinGasReserve } from "./mocks/targets/TargetMinGasReserve.t.sol";
import { TargetPanic } from "./mocks/targets/TargetPanic.t.sol";
import { TargetReverter } from "./mocks/targets/TargetReverter.t.sol";
import { TargetSelfDestructer } from "./mocks/targets/TargetSelfDestructer.t.sol";
import { Events } from "./utils/Events.t.sol";

/// @title Base_Test
/// @notice Base test contract with common logic needed by all test contracts.
abstract contract Base_Test is PRBTest, Events, StdCheats, StdUtils {
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

    ERC20 internal dai = new ERC20("Dai Stablecoin", "DAI");
    IPRBProxyHelpers internal helpers;
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

        // Deploy the default proxy-related contracts.
        deployDefaultContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  HELPER FUNCTIONS
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
    function computeProxyAddress(address origin, bytes32 seed) internal returns (address proxyAddress) {
        bytes32 salt = keccak256(abi.encode(origin, seed));
        bytes32 creationBytecodeHash = keccak256(getProxyBytecode());
        // Use the create2 utility from Forge Std.
        proxyAddress =
            computeCreate2Address({ salt: salt, initcodeHash: creationBytecodeHash, deployer: address(registry) });
    }

    /// @dev Generates an address by hashing the name, labels the address and funds it with 100 ETH and 1 million DAI.
    function createUser(string memory name) internal returns (address payable addr) {
        addr = payable(makeAddr(name));
        vm.deal({ account: addr, newBalance: 100 ether });
        deal({ token: address(dai), to: addr, give: 1_000_000e18 });
    }

    /// @dev Conditionally the default contracts either normally or from precompiled source.
    function deployDefaultContracts() internal {
        // We deploy from precompiled source if the profile is "test-optimized".
        if (isTestOptimizedProfile()) {
            helpers = IPRBProxyHelpers(deployCode("optimized-out/PRBProxyHelpers.sol/PRBProxyHelpers.json"));
            registry = IPRBProxyRegistry(deployCode("optimized-out/PRBProxyRegistry.sol/PRBProxyRegistry.json"));
        }
        // We deploy normally in all other cases.
        else {
            helpers = new PRBProxyHelpers();
            registry = new PRBProxyRegistry();
        }

        // Finally, label all the contracts just deployed.
        vm.label({ account: address(helpers), newLabel: "Helpers" });
        vm.label({ account: address(registry), newLabel: "Registry" });
    }

    /// @dev Reads the proxy bytecode either normally or from precompiled source.
    function getProxyBytecode() internal returns (bytes memory bytecode) {
        if (isTestOptimizedProfile()) {
            bytecode = vm.getCode("optimized-out/PRBProxy.sol/PRBProxy.json");
        } else {
            bytecode = type(PRBProxy).creationCode;
        }
    }

    /// @dev ABI encodes the parameters and calls the `installPlugin` helper on the enshrined target.
    function installPlugin(IPRBProxyPlugin plugin) internal {
        bytes memory data = abi.encodeCall(helpers.installPlugin, (plugin));
        proxy.execute({ target: address(helpers), data: data });
    }

    /// @dev Checks if the Foundry profile is "test-optimized".
    function isTestOptimizedProfile() internal returns (bool result) {
        string memory profile = vm.envOr("FOUNDRY_PROFILE", string(""));
        result = eqString(profile, "test-optimized");
    }

    /// @dev ABI encodes the parameters and calls the `setMinGasReserve` helper on the enshrined target.
    function setMinGasReserve(uint256 newMinGasReserve) internal {
        bytes memory data = abi.encodeCall(helpers.setMinGasReserve, (newMinGasReserve));
        proxy.execute({ target: address(helpers), data: data });
    }

    /// @dev ABI encodes the parameters and calls the `setPermission` helper on the enshrined target.
    function setPermission(address envoy, address target, bool permission) internal {
        bytes memory data = abi.encodeCall(helpers.setPermission, (envoy, target, permission));
        proxy.execute({ target: address(helpers), data: data });
    }

    /// @dev ABI encodes the parameters and calls the `uninstallPlugin` helper on the enshrined target.
    function uninstallPlugin(IPRBProxyPlugin plugin) internal {
        bytes memory data = abi.encodeCall(helpers.uninstallPlugin, (plugin));
        proxy.execute({ target: address(helpers), data: data });
    }
}
