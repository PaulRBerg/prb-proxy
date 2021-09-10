import { getCreate2Address } from "@ethersproject/address";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

import { computeFinalSalt } from "../../dist/salts";
import { getCloneBytecode } from "./eip1167";

export function computeProxyAddress(this: Mocha.Context, deployer: string, salt: string): string {
  return getCreate2Address(
    this.contracts.prbProxyFactory.address,
    computeFinalSalt(deployer, salt),
    solidityKeccak256(["bytes"], [getCloneBytecode(this.contracts.prbProxyImplementation.address)]),
  );
}
