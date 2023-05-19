// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <=0.9.0;

import { Annex_Test } from "../Annex.t.sol";

contract SetMinGasReserve_Test is Annex_Test {
    function testFuzz_SetMinGasReserve_Update(uint256 newMinGasReserve) external {
        setMinGasReserve(newMinGasReserve);
        uint256 actualMinGasReserve = proxy.minGasReserve();
        uint256 expectedMinGasReserve = newMinGasReserve;
        assertEq(actualMinGasReserve, expectedMinGasReserve, "minGasReserve");
    }

    function testFuzz_SetMinGasReserve_Event(uint256 newMinGasReserve) external {
        emit SetMinGasReserve({ oldMinGasReserve: DEFAULT_MIN_GAS_RESERVE, newMinGasReserve: newMinGasReserve });
        setMinGasReserve(newMinGasReserve);
    }
}
