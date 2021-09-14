import { getCreate2Address } from "@ethersproject/address";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";
import { artifacts } from "hardhat";

import { computeFinalSalt } from "../../dist/salts";

export async function computeProxyAddress(this: Mocha.Context, deployer: string): Promise<string> {
  const nextSalt: string = await this.contracts.prbProxyFactory.getNextSalt(deployer);
  const bytecode: string = (await artifacts.readArtifact("PRBProxy")).bytecode;
  return getCreate2Address(
    this.contracts.prbProxyFactory.address,
    computeFinalSalt(deployer, nextSalt),
    solidityKeccak256(["bytes"], [bytecode]),
  );
}
