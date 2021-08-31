// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "@paulrberg/contracts/access/Ownable.sol";

import "./IPRBProxy.sol";

/// @notice Emitted when execution reverted with no reason.
error PRBProxy__ExecutionReverted();

/// @notice Emitted when passing an EOA or a not-yet-deployed contract as the target.
error PRBProxy__TargetInvalid(address target);

/// @notice Emitted when passing the zero address as the target.
error PRBProxy__TargetZeroAddress();

/// @title PRBProxy
/// @author Paul Razvan Berg
contract PRBProxy is
    IPRBProxy, // One dependency
    Ownable // One dependency
{
    /// @inheritdoc IPRBProxy
    uint256 public override minGasReserve;

    /// CONSTRUCTOR ///

    constructor() Ownable() {
        minGasReserve = 5000;
    }

    /// FALLBACK FUNCTION ///

    /// @dev This is called whenever the call data is empty.
    receive() external payable {
        // solhint-disable-previous-line no-empty-blocks
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

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
