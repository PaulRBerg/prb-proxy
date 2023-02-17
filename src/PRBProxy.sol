// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IPRBProxy } from "./interfaces/IPRBProxy.sol";
import { IPRBProxyPlugin } from "./interfaces/IPRBProxyPlugin.sol";

/*

██████╗ ██████╗ ██████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██████╔╝██████╔╝██████╔╝██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝
██╔═══╝ ██╔══██╗██╔══██╗██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝
██║     ██║  ██║██████╔╝██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/

/// @title PRBProxy
/// @author Paul Razvan Berg
/// @dev This contract implements the {IPRBProxy} interface.
contract PRBProxy is IPRBProxy {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxy
    address public override owner;

    /// @inheritdoc IPRBProxy
    uint256 public override minGasReserve;

    /*//////////////////////////////////////////////////////////////////////////
                                  INTERNAL STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Maps plugin methods to plugin implementation.
    mapping(bytes4 method => IPRBProxyPlugin plugin) internal plugins;

    /// @dev Maps envoys to target contracts to function selectors to boolean flags.
    mapping(address envoy => mapping(address target => mapping(bytes4 selector => bool permission)))
        internal permissions;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor() {
        minGasReserve = 5_000;
        owner = msg.sender;
        emit TransferOwnership({ oldOwner: address(0), newOwner: msg.sender });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert PRBProxy_NotOwner({ owner: owner, caller: msg.sender });
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  FALLBACK FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Used for running plugins.
    /// @dev Called when the call data is not empty.
    fallback(bytes calldata data) external payable returns (bytes memory response) {
        // Check if the function signature exists in the installed plugin methods mapping.
        IPRBProxyPlugin plugin = plugins[msg.sig];
        if (address(plugin) == address(0)) {
            revert PRBProxy_PluginNotInstalledForMethod(msg.sender, msg.sig);
        }

        // Delegate call to the plugin.
        bool success;
        (success, response) = _safeDelegateCall(address(plugin), data);

        // Log the plugin run.
        emit RunPlugin(plugin, data, response);

        // Check if the call has been successful or not.
        if (!success) {
            // If there is return data, the call reverted with a reason or a custom error.
            if (response.length > 0) {
                assembly {
                    let returndata_size := mload(response)
                    revert(add(32, response), returndata_size)
                }
            } else {
                revert PRBProxy_PluginReverted(plugin);
            }
        }
    }

    /// @dev Called when the call data is empty.
    receive() external payable {}

    /*//////////////////////////////////////////////////////////////////////////
                              PUBLIC CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxy
    function getPermission(
        address envoy,
        address target,
        bytes4 selector
    ) external view override returns (bool permission) {
        permission = permissions[envoy][target][selector];
    }

    /// @inheritdoc IPRBProxy
    function getPluginForMethod(bytes4 method) external view override returns (IPRBProxyPlugin plugin) {
        plugin = plugins[method];
    }

    /*/////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxy
    function execute(address target, bytes calldata data) external payable override returns (bytes memory response) {
        // Check that the caller is either the owner or an envoy with permission.
        if (owner != msg.sender) {
            bytes4 selector = bytes4(data[:4]);
            if (!permissions[msg.sender][target][selector]) {
                revert PRBProxy_ExecutionUnauthorized({
                    owner: owner,
                    caller: msg.sender,
                    target: target,
                    selector: selector
                });
            }
        }

        // Check that the target is a valid contract.
        if (target.code.length == 0) {
            revert PRBProxy_TargetNotContract(target);
        }

        // Delegate call to the target contract.
        bool success;
        (success, response) = _safeDelegateCall(target, data);

        // Log the execution.
        emit Execute(target, data, response);

        // Check if the call has been successful or not.
        if (!success) {
            // If there is return data, the call reverted with a reason or a custom error.
            if (response.length > 0) {
                assembly {
                    // The length of the data is at `response`, while the actual data is at `response + 32`.
                    let returndata_size := mload(response)
                    revert(add(response, 32), returndata_size)
                }
            } else {
                revert PRBProxy_ExecutionReverted();
            }
        }
    }

    /// @inheritdoc IPRBProxy
    function installPlugin(IPRBProxyPlugin plugin) external override {
        // Check that the caller is the owner.
        if (owner != msg.sender) {
            revert PRBProxy_NotOwner(owner, msg.sender);
        }

        // Get the method list to install.
        bytes4[] memory methodList = plugin.methodList();

        // The plugin must have at least one listed method.
        uint256 length = methodList.length;
        if (length == 0) {
            revert PRBProxy_NoPluginMethods(plugin);
        }

        // Enable every method in the list.
        for (uint256 i = 0; i < length; ) {
            plugins[methodList[i]] = plugin;
            unchecked {
                i += 1;
            }
        }

        // Log the plugin installation.
        emit InstallPlugin(plugin);
    }

    /// @inheritdoc IPRBProxy
    function setPermission(
        address envoy,
        address target,
        bytes4 selector,
        bool permission
    ) external override onlyOwner {
        permissions[envoy][target][selector] = permission;
        emit SetPermission(envoy, target, selector, permission);
    }

    /// @inheritdoc IPRBProxy
    function transferOwnership(address newOwner) external override onlyOwner {
        // Load the current admin in memory.
        address oldOwner = owner;

        // Effects: update the owner.
        owner = newOwner;

        // Log the transfer of the owner.
        emit TransferOwnership(oldOwner, newOwner);
    }

    /// @inheritdoc IPRBProxy
    function uninstallPlugin(IPRBProxyPlugin plugin) external override {
        // Check that the caller is the owner.
        if (owner != msg.sender) {
            revert PRBProxy_NotOwner(owner, msg.sender);
        }

        // Get the method list to uninstall.
        bytes4[] memory methodList = plugin.methodList();

        // The plugin must have at least one listed method.
        uint256 length = methodList.length;
        if (length == 0) {
            revert PRBProxy_NoPluginMethods(plugin);
        }

        // Disable every method in the list.
        for (uint256 i = 0; i < length; ) {
            delete plugins[methodList[i]];
            unchecked {
                i += 1;
            }
        }

        // Log the plugin uninstallation.
        emit UninstallPlugin(plugin);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Performs a DELEGATECALL to the given address with the given data.
    /// @dev Shared logic between the {execute} and the {fallback} functions.
    function _safeDelegateCall(address to, bytes memory data) internal returns (bool success, bytes memory response) {
        // Save the owner address in memory. This variable cannot be modified during the DELEGATECALL.
        address owner_ = owner;

        // Reserve some gas to ensure that the function has enough to finish the execution.
        uint256 stipend = gasleft() - minGasReserve;

        // Delegate call to the given contract.
        (success, response) = to.delegatecall{ gas: stipend }(data);

        // Check that the owner has not been changed.
        if (owner_ != owner) {
            revert PRBProxy_OwnerChanged(owner_, owner);
        }
    }
}
