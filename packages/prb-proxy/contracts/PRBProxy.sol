// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";

/// @notice Emitted when execution reverted with no reason.
error PRBProxy__ExecutionReverted();

/// @notice Emitted when the caller is not the owner.
error PRBProxy__NotOwner(address owner, address caller);

/// @notice Emitted when the owner is changed during the DELEGATECALL.
error PRBProxy__OwnerChanged(address originalOwner, address newOwner);

/// @notice Emitted when passing an EOA or an undeployed contract as the target.
error PRBProxy__TargetInvalid(address target);

/// @title PRBProxy
/// @author Paul Razvan Berg
contract PRBProxy is IPRBProxy {
    /// PUBLIC STORAGE ///

    /// @inheritdoc IPRBProxy
    address public owner;

    /// @inheritdoc IPRBProxy
    uint256 public minGasReserve;

    /// MODIFIERS ///

    /// @notice Reverts if called by any account other than the owner.
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert PRBProxy__NotOwner(owner, msg.sender);
        }
        _;
    }

    /// CONSTRUCTOR ///

    constructor() {
        minGasReserve = 5_000;
        owner = msg.sender;
        emit TransferOwnership(address(0), msg.sender);
    }

    /// FALLBACK FUNCTION ///

    /// @dev Called when Ether is sent and the call data is empty.
    receive() external payable {}

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxy
    function execute(address target, bytes memory data) external payable onlyOwner returns (bytes memory response) {
        // Check that the target is a valid contract.
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(target)
        }
        if (codeSize == 0) {
            revert PRBProxy__TargetInvalid(target);
        }

        // Save the owner address in memory. This local variable cannot be modified during the DELEGATECALL.
        address owner_ = owner;

        // Reserve some gas to ensure that there will be enough to complete the function execution.
        uint256 stipend = gasleft() - minGasReserve;

        // Delegate call to the target contract.
        bool success;
        (success, response) = target.delegatecall{ gas: stipend }(data);

        // Check that the owner has not been changed.
        if (owner_ != owner) {
            revert PRBProxy__OwnerChanged(owner_, owner);
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
                revert PRBProxy__ExecutionReverted();
            }
        }
    }

    /// @inheritdoc IPRBProxy
    function setMinGasReserve(uint256 newMinGasReserve) external onlyOwner {
        minGasReserve = newMinGasReserve;
    }

    /// @inheritdoc IPRBProxy
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
        emit TransferOwnership(owner, newOwner);
    }
}
