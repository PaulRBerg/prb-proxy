import { defaultAbiCoder } from "@ethersproject/abi";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

export function computeFinalSalt(deployer: string, salt: string): string {
  return solidityKeccak256(["address"], [defaultAbiCoder.encode(["address", "bytes32"], [deployer, salt])]);
}

export function generateRandomSalt(): string {
  const length: number = 64;
  const array: number[] = [...Array(length)];
  const number: string = array.map(() => Math.floor(Math.random() * 16).toString(16)).join("");
  return "0x" + number;
}
