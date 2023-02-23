// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "src/interfaces/IPRBProxyPlugin.sol";
import { PRBProxyStorage } from "src/PRBProxyStorage.sol";

contract StorageMock is PRBProxyStorage {
    constructor(
        address owner_,
        uint256 minGasReserve_,
        bytes4 method_,
        IPRBProxyPlugin plugin_,
        address envoy_,
        address target_
    ) {
        owner = owner_;
        minGasReserve = minGasReserve_;
        plugins[method_] = plugin_;
        permissions[envoy_][target_];
    }
}
