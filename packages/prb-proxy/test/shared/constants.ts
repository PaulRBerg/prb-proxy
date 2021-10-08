import { BigNumber } from "@ethersproject/bignumber";
import { hexZeroPad } from "@ethersproject/bytes";

export const SALT_ONE: string = hexZeroPad(BigNumber.from(1).toHexString(), 32);
export const SALT_ZERO: string = "0x".concat("0".repeat(64));
