// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { ERC20GodMode } from "@prb/contracts/token/erc20/ERC20GodMode.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats, StdUtils } from "forge-std/Components.sol";

import { PRBProxy } from "../src/PRBProxy.sol";

/// @title BaseTest
/// @author Paul Razvan Berg
/// @notice Common contract members needed across test contracts.
abstract contract BaseTest is PRBTest, StdCheats, StdUtils {
    /*//////////////////////////////////////////////////////////////////////////
                                       STRUCTS
    //////////////////////////////////////////////////////////////////////////*/

    struct Users {
        address payable alice;
        address payable bob;
        address payable eve;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint256 internal constant ONE_MILLION_DAI = 1_000_000e18;
    uint256 internal constant ONE_MILLION_USDC = 1_000_000e6;

    /*//////////////////////////////////////////////////////////////////////////
                                  TESTING VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    ERC20GodMode internal dai = new ERC20GodMode("Dai Stablecoin", "DAI", 18);
    ERC20GodMode internal usdc = new ERC20GodMode("USD Coin", "USDC", 6);
    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   SETUP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Create users for testing. Order matters.
        users = Users({ alice: mkaddr("Alice"), bob: mkaddr("Bob"), eve: mkaddr("Eve") });

        fundUser(users.alice);
        fundUser(users.bob);
        fundUser(users.eve);

        // Make Alice the `msg.sender` and `tx.origin` for all subsequent calls.
        vm.startPrank(users.alice, users.alice);
    }

    /*//////////////////////////////////////////////////////////////////////////
                             INTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function that multiplies the `amount` by `10^decimals` and returns a `uint256.`
    function bn(uint256 amount, uint256 decimals) internal pure returns (uint256 result) {
        result = amount * 10**decimals;
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Helper function to compare two `IERC20` arrays.
    function assertEq(IERC20[] memory a, IERC20[] memory b) internal {
        address[] memory castedA;
        address[] memory castedB;
        assembly {
            castedA := a
            castedB := b
        }
        assertEq(castedA, castedB);
    }

    /// @dev Helper to deploy PRBProxy instances by loading the bytecode directly.
    function deployProxy() internal returns (address proxyAddress) {
        bytes memory deploymentBytecode = type(PRBProxy).creationCode;
        assembly {
            proxyAddress := create(0, add(deploymentBytecode, 0x20), mload(deploymentBytecode))
        }
    }

    /// @dev Give each user 100 ETH, 1M DAI and 1M USDC.
    function fundUser(address payable user) internal {
        vm.deal(user, 100 ether);
        dai.mint(user, ONE_MILLION_DAI);
        usdc.mint(user, ONE_MILLION_USDC);
    }

    /// @dev Generates an address by hashing the name and labels the address.
    function mkaddr(string memory name) internal returns (address payable addr) {
        addr = payable(address(uint160(uint256(keccak256(abi.encodePacked(name))))));
        vm.label(addr, name);
    }
}
