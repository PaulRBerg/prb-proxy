// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IPRBProxy.sol";
import "./access/Ownable.sol";

/// @notice Emitted when attempting to initialize the contract again.
error PRBProxy__AlreadyInitialized();

/// @notice Emitted when execution reverted with no reason.
error PRBProxy__ExecutionReverted();

/// @notice Emitted when passing an EOA or an undeployed contract as the target.
error PRBProxy__TargetInvalid(address target);

/// @notice Emitted when passing the zero address as the target.
error PRBProxy__TargetZeroAddress();

/// @title PRBProxy
/// @author Paul Razvan Berg
contract PRBProxy is
    IPRBProxy, // One dependency
    Ownable // One dependency
{
    /// PUBLIC STORAGE ///

    /// @inheritdoc IPRBProxy
    uint256 public override minGasReserve;

    /// INTERNAL STORAGE ///

    /// @dev Indicates that the contract has been initialized.
    bool internal initialized;

    /// CONSTRUCTOR ///

    /// @dev Initializes the implementation contract. The owner is set to the zero address so that no function
    /// can be called post deployment. This eliminates the risk of an accidental self destruct.
    constructor() {
        initialized = true;
        owner = address(0);
    }

    /// FALLBACK FUNCTION ///

    /// @dev Called when Ether is sent and the call data is empty.
    receive() external payable {
        // solhint-disable-previous-line no-empty-blocks
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc IPRBProxy
    function initialize(address owner_) external override {
        // Checks
        if (initialized) {
            revert PRBProxy__AlreadyInitialized();
        }

        // Effects
        initialized = true;
        minGasReserve = 5000;
        setOwner(owner_);
    }

    /// @inheritdoc IPRBProxy
    function execute(address target, bytes memory data)
        external
        payable
        override
        onlyOwner
        returns (bytes memory response)
    {
        // Check that the target is not the zero address.
        if (target == address(0)) {
            revert PRBProxy__TargetZeroAddress();
        }

        // Check that the target is a valid contract.
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(target)
        }
        if (codeSize == 0) {
            revert PRBProxy__TargetInvalid(target);
        }

        // Ensure that there will remain enough gas after the DELEGATECALL.
        uint256 stipend = gasleft() - minGasReserve;

        // Delegate call to the target contract.
        (bool success, bytes memory returndata) = target.delegatecall{ gas: stipend }(data);
        if (success) {
            return returndata;
        } else {
            // If there is return data, the call reverted with a reason or a custom error.
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert PRBProxy__ExecutionReverted();
            }
        }
    }

    /// @inheritdoc IPRBProxy
    function setMinGasReserve(uint256 newMinGasReserve) external override onlyOwner {
        minGasReserve = newMinGasReserve;
    }
}
