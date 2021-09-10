import { getCreate2Address } from "@ethersproject/address";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

import { computeFinalSalt } from "./salts";

const addresses = {
  PRBProxy: "0x427fA23EA53225AC1b7510194E51979510A68007",
  PRBProxyFactory: "0x4A080d237DA7AB069D17C8aC6802ac73E8b46807",
  PRBProxyRegistry: "0x12fC6456a49f549363ffFB67f18fc4E1f8f6AB62",
};

export function computeProxyAddress(this: Mocha.Context, deployer: string, salt: string): string {
  const cloneDeployedBytecode: string[] = ["363d3d373d3d3d363d73", "5af43d82803e903d91602b57fd5bf3"];
  return getCreate2Address(
    this.contracts.prbProxyFactory.address,
    computeFinalSalt(deployer, salt),
    solidityKeccak256(["bytes"], [cloneDeployedBytecode[0] + addresses.PRBProxy + cloneDeployedBytecode[1]]),
  );
}

export default addresses;
