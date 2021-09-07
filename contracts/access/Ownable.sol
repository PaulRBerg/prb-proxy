// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.4;

import "./IOwnable.sol";

/// @notice Emitted when the caller is not the owner.
error Ownable__NotOwner(address owner, address caller);

/// @notice Emitted when setting the owner to the zero address.
error Ownable__OwnerZeroAddress();

/// @title Ownable
/// @author Paul Razvan Berg
contract Ownable is IOwnable {
    /// PUBLIC STORAGE ///

    /// @inheritdoc IOwnable
    address public override owner;

    /// MODIFIERS ///

    /// @notice Throws if called by any account other than the owner.
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert Ownable__NotOwner(owner, msg.sender);
        }
        _;
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    /// @inheritdoc IOwnable
    function renounceOwnership() external virtual override onlyOwner {
        owner = address(0);
        emit TransferOwnership(owner, address(0));
    }

    /// @inheritdoc IOwnable
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        setOwner(newOwner);
    }

    /// INTERNAL NON-CONSTANT FUNCTIONS ///
    function setOwner(address newOwner) internal virtual {
        if (newOwner == address(0)) {
            revert Ownable__OwnerZeroAddress();
        }
        owner = newOwner;
        emit TransferOwnership(owner, newOwner);
    }
}
