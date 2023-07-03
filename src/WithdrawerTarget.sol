// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { IPRBProxy } from "./interfaces/IPRBProxy.sol";

interface IWrappedNativeAsset is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

contract WithdrawerTarget {
    using SafeERC20 for IERC20;

    error NativeWithdrawalFailed();

    function withdrawERC20(IERC20 asset, uint256 amount) external {
        address owner = _getOwner();
        asset.safeTransfer({ to: owner, value: amount });
    }

    function withdrawNative(uint256 amount) external {
        address owner = _getOwner();
        (bool sent,) = owner.call{ value: amount }("");
        if (!sent) {
            revert NativeWithdrawalFailed();
        }
    }

    function _getOwner() internal view returns (address) {
        return IPRBProxy(address(this)).owner();
    }
}
