import { getCreate2Address } from "@ethersproject/address";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

import { computeFinalSalt } from "../../dist/salts";
import { getCloneBytecode } from "./eip1167";

export async function computeProxyAddress(this: Mocha.Context, deployer: string): Promise<string> {
  const nextSalt: string = await this.contracts.prbProxyFactory.getNextSalt(deployer);
  return getCreate2Address(
    this.contracts.prbProxyFactory.address,
    computeFinalSalt(deployer, nextSalt),
    solidityKeccak256(["bytes"], [getCloneBytecode(this.contracts.prbProxyImplementation.address)]),
  );
}
