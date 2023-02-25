// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { IPRBProxy } from "src/interfaces/IPRBProxy.sol";

import { TargetDummy } from "../../shared/targets/TargetDummy.t.sol";
import { Helpers_Test } from "../Helpers.t.sol";

contract SetMinGasReserve_Test is Helpers_Test {
    /// @dev it should update the minimum gas reserve.
    function testFuzz_SetMinGasReserve_Update(uint256 newMinGasReserve) external {
        setMinGasReserve(newMinGasReserve);
        uint256 actualMinGasReserve = proxy.minGasReserve();
        uint256 expectedMinGasReserve = newMinGasReserve;
        assertEq(actualMinGasReserve, expectedMinGasReserve, "minGasReserve");
    }

    /// @dev it should emit a {SetMinGasReserve} event.
    function testFuzz_SetMinGasReserve_Event(uint256 newMinGasReserve) external {
        emit SetMinGasReserve({ oldMinGasReserve: DEFAULT_MIN_GAS_RESERVE, newMinGasReserve: newMinGasReserve });
        setMinGasReserve(newMinGasReserve);
    }
}
