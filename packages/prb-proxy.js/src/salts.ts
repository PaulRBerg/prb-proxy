import { defaultAbiCoder } from "@ethersproject/abi";
import { keccak256 } from "@ethersproject/keccak256";

export function computeFinalSalt(deployer: string, salt: string): string {
  return keccak256(defaultAbiCoder.encode(["address", "bytes32"], [deployer, salt]));
}
