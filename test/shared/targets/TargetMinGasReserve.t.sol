// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

/// @dev This works because the storage variables are ordered in exactly the same as they are in {PRBProxy}.
contract TargetMinGasReserve {
    address public owner;
    uint256 public minGasReserve;

    function setMinGasReserve(uint256 newMinGasReserve) external {
        minGasReserve = newMinGasReserve;
    }
}
