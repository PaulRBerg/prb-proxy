// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "@paulrberg/contracts/access/IOwnable.sol";

/// @title IPRBProxy
/// @author Paul Razvan Berg
interface IPRBProxy is IOwnable {
    /// PUBLIC CONSTANT FUNCTIONS ///

    /// @notice How much gas should remain for executing the remainder of the assembly code.
    function minGasReserve() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @notice Delegate calls to the target contract by passing the provided data as calldata.
    /// @param target The address of the target contract.
    /// @param data Function selector plus RLP encoded data.
    /// @return response The response received from the target contract.
    function execute(address target, bytes memory data) external payable returns (bytes memory response);

    /// @notice Sets a new value for the `minGasReserve` storage variable.
    function setMinGasReserve(uint256 newMinGasReserve) external;
}
