// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./access/IOwnable.sol";

/// @title IPRBProxy
/// @author Paul Razvan Berg
/// @notice Proxy contract to compose transactions on owner's behalf.
interface IPRBProxy is IOwnable {
    /// EVENTS ///

    event Execute(address indexed target, bytes data, bytes response);

    /// PUBLIC CONSTANT FUNCTIONS ///

    /// @notice How much gas should remain for executing the remainder of the assembly code.
    function minGasReserve() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @notice Delegate calls to the target contract by forwarding the call data. This function returns
    /// the data it gets back, including when the contract call reverts with a reason or custom error.
    ///
    /// @dev Requirements:
    /// - The caller must be the owner.
    /// - `target` must be a contract.
    ///
    /// @param target The address of the target contract.
    /// @param data Function selector plus ABI encoded data.
    /// @return response The response received from the target contract.
    function execute(address target, bytes memory data) external payable returns (bytes memory response);

    /// @notice Initializes the contract by setting the address of the owner of the proxy.
    ///
    /// @dev Supposed to be called by an EIP-1167 clone.
    ///
    /// Requirements:
    /// - Can only be called once.
    ///
    /// @param owner_ The address of the owner of the proxy.
    function initialize(address owner_) external;

    /// @notice Sets a new value for the `minGasReserve` storage variable.
    /// @dev Requirements:
    /// - The caller must be the owner.
    function setMinGasReserve(uint256 newMinGasReserve) external;
}
