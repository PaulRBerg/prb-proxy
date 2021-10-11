import { hexZeroPad } from "@ethersproject/bytes";
import { One } from "@ethersproject/constants";

export const SEED_ONE: string = hexZeroPad(One.toHexString(), 32);
export const SEED_ZERO: string = "0x".concat("0".repeat(64));
