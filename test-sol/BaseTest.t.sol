// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { ERC20 } from "@prb/contracts/token/erc20/ERC20.sol";
import { IERC20 } from "@prb/contracts/token/erc20/IERC20.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { PRBProxy } from "src/PRBProxy.sol";

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
                                      STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    ERC20 internal dai = new ERC20("Dai Stablecoin", "DAI", 18);
    ERC20 internal usdc = new ERC20("USD Coin", "USDC", 6);

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        // Create users for testing.
        users = Users({ alice: createUser("Alice"), bob: createUser("Bob"), eve: createUser("Eve") });

        // Make Alice both the caller and the origin for all subsequent calls.
        vm.startPrank({ msgSender: users.alice, txOrigin: users.alice });
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Generates an address by hashing the name, labels the address and funds it with 100 ETH, 1 million DAI,
    /// and 1 million USDC.
    function createUser(string memory name) internal returns (address payable addr) {
        addr = payable(address(uint160(uint256(keccak256(abi.encodePacked(name))))));
        vm.label({ account: addr, newLabel: name });
        vm.deal({ account: addr, newBalance: 100 ether });
        deal({ token: address(dai), to: addr, give: 1_000_000e18 });
        deal({ token: address(usdc), to: addr, give: 1_000_000e6 });
    }

    /// @dev Deploys PRBProxy instances by loading the bytecode directly.
    function deployProxy() internal returns (IPRBProxy proxy) {
        proxy = new PRBProxy();
    }
}
