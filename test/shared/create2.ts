import { defaultAbiCoder } from "@ethersproject/abi";
import { getCreate2Address } from "@ethersproject/address";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

export function getProxyAddress(this: Mocha.Context, deployer: string, salt: string): string {
  salt = solidityKeccak256(["address"], [defaultAbiCoder.encode(["address", "bytes32"], [deployer, salt])]);
  return getCreate2Address(
    this.contracts.prbProxyFactory.address,
    salt,
    solidityKeccak256(["bytes"], [this.artifacts.prbProxy.bytecode]),
  );
}

export function getRandomSalt(): string {
  const length: number = 64;
  const array: number[] = [...Array(length)];
  const number: string = array.map(() => Math.floor(Math.random() * 16).toString(16)).join("");
  return "0x" + number;
}
