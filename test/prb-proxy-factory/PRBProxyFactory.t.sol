// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";
import { IPRBProxyFactory } from "src/interfaces/IPRBProxyFactory.sol";
import { PRBProxyFactory } from "src/PRBProxyFactory.sol";

import { BaseTest } from "../BaseTest.t.sol";

contract PRBProxyFactory_Test is BaseTest {
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

    /*//////////////////////////////////////////////////////////////////////////
                                      CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    bytes32 internal constant SEED_ONE = bytes32(uint256(0x01));
    bytes32 internal constant SEED_TWO = bytes32(uint256(0x02));
    bytes32 internal constant SEED_ZERO = bytes32(uint256(0x00));

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    IPRBProxyFactory internal factory = new PRBProxyFactory();
}
