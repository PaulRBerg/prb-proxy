import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

export function computeFinalSalt(deployer: string, salt: string): string {
  return solidityKeccak256(["address", "bytes32"], [deployer, salt]);
}
