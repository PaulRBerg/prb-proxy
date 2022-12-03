// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { ERC20 } from "@prb/contracts/token/erc20/ERC20.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
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

/// @title Base_Test
/// @author Paul Razvan Berg
/// @notice Common contract members needed across test contracts.
abstract contract Base_Test is PRBTest, StdCheats, StdUtils {
    /*//////////////////////////////////////////////////////////////////////////
                                       STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    struct Users {
        address payable alice;
        address payable bob;
        address payable envoy;
        address payable eve;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    bytes32 internal constant SEED_ONE = bytes32(uint256(0x01));
    bytes32 internal constant SEED_TWO = bytes32(uint256(0x02));
    bytes32 internal constant SEED_ZERO = bytes32(uint256(0x00));

    /*//////////////////////////////////////////////////////////////////////////
                                      STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ERC20 internal dai = new ERC20("Dai Stablecoin", "DAI", 18);
    IPRBProxyFactory internal factory;
    IPRBProxy internal proxy;
    IPRBProxyRegistry internal registry;
    ERC20 internal usdc = new ERC20("USD Coin", "USDC", 6);

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

        // Make Alice both the caller and the origin for all subsequent calls.
        vm.startPrank({ msgSender: users.alice, txOrigin: users.alice });

        /// Deploy the default proxy-related contracts.
        deployDefaultContracts();
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to compare two `IPRBProxyPlugin` addresses.
    function assertEq(IPRBProxyPlugin a, IPRBProxyPlugin b) internal {
        assertEq(address(a), address(b));
    }

    /// @dev Helper function to compare two `IPRBProxyPlugin` addresses.
    function assertEq(IPRBProxyPlugin a, IPRBProxyPlugin b, string memory err) internal {
        assertEq(address(a), address(b), err);
    }

    /// @dev Computes the proxy address without deploying it.
    function computeProxyAddress(address deployer, bytes32 seed) internal view returns (address proxyAddress) {
        bytes32 salt = keccak256(abi.encode(deployer, seed));
        bytes memory creationBytecode = type(PRBProxy).creationCode;
        bytes32 creationBytecodeHash = keccak256(creationBytecode);
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
        deal({ token: address(usdc), to: addr, give: 1_000_000e6 });
    }

    /// @dev Deploys the default proxy-related contracts.
    function deployDefaultContracts() internal {
        proxy = new PRBProxy();
        factory = new PRBProxyFactory();
        registry = new PRBProxyRegistry(factory);
    }

    /// @dev Deploys the proxy.
    function deployProxy() internal returns (IPRBProxy deployedProxy) {
        deployedProxy = new PRBProxy();
    }
}
