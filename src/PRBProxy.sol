// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { IPRBProxy } from "./interfaces/IPRBProxy.sol";

/// @title PRBProxy
/// @author Paul Razvan Berg
/// @dev This contract implements the IPRBProxy interface.
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

    /// @notice Maps envoys to target contracts to function selectors to boolean flags.
    mapping(address => mapping(address => mapping(bytes4 => bool))) internal permissions;

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
                                  FALLBACK FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////////////////
                            PUBLIC NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPRBProxy
    function execute(address target, bytes calldata data) external payable override returns (bytes memory response) {
        // Check that the caller is either the owner or an envoy.
        if (owner != msg.sender) {
            bytes4 selector;
            assembly {
                selector := calldataload(data.offset)
            }
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

        // Save the owner address in memory. This local variable cannot be modified during the DELEGATECALL.
        address owner_ = owner;

        // Reserve some gas to ensure that the function has enough to finish the execution.
        uint256 stipend = gasleft() - minGasReserve;

        // Delegate call to the target contract.
        bool success;
        (success, response) = target.delegatecall{ gas: stipend }(data);

        // Check that the owner has not been changed.
        if (owner_ != owner) {
            revert PRBProxy_OwnerChanged(owner_, owner);
        }

        // Log the execution.
        emit Execute(target, data, response);

        // Check if the call was successful or not.
        if (!success) {
            // If there is return data, the call reverted with a reason or a custom error.
            if (response.length > 0) {
                assembly {
                    let returndata_size := mload(response)
                    revert(add(32, response), returndata_size)
                }
            } else {
                revert PRBProxy_ExecutionReverted();
            }
        }
    }

    /// @inheritdoc IPRBProxy
    function setPermission(
        address envoy,
        address target,
        bytes4 selector,
        bool permission
    ) external override onlyOwner {
        permissions[envoy][target][selector] = permission;
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
}
