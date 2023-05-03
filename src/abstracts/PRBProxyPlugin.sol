// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

import { IPRBProxyPlugin } from "../interfaces/IPRBProxyPlugin.sol";
import { PRBProxyStorage } from "./PRBProxyStorage.sol";

/// @title PRBProxyPlugin
/// @dev This is meant to be inherited by plugins. See the documentation in {IPRBProxyPlugin}.
abstract contract PRBProxyPlugin is IPRBProxyPlugin, PRBProxyStorage { }
