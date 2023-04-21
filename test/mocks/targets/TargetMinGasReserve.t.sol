// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

/// @dev This works because the storage layout is exactly the same as in {PRBProxy}.
contract TargetMinGasReserve {
    address public owner;
    uint256 public minGasReserve;

    function setMinGasReserve(uint256 newMinGasReserve) external {
        minGasReserve = newMinGasReserve;
    }
}
