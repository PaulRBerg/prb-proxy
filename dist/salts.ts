import { defaultAbiCoder } from "@ethersproject/abi";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

export function computeFinalSalt(deployer: string, salt: string): string {
  return solidityKeccak256(["address"], [defaultAbiCoder.encode(["address", "bytes32"], [deployer, salt])]);
}
