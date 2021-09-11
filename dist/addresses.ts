import { getCreate2Address } from "@ethersproject/address";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

import { computeFinalSalt } from "./salts";

const addresses = {
  PRBProxy: "0x427fA23EA53225AC1b7510194E51979510A68007",
  PRBProxyFactory: "0x4A080d237DA7AB069D17C8aC6802ac73E8b46807",
  PRBProxyRegistry: "0x12fC6456a49f549363ffFB67f18fc4E1f8f6AB62",
};

export function computeProxyAddress(deployer: string, salt: string): string {
  const cloneBytecode: string[] = ["3d602d80600a3d3981f3363d3d373d3d3d363d73", "5af43d82803e903d91602b57fd5bf3"];
  return getCreate2Address(
    addresses.PRBProxyFactory,
    computeFinalSalt(deployer, salt),
    solidityKeccak256(["bytes"], ["0x" + cloneBytecode[0] + addresses.PRBProxy + cloneBytecode[1]]),
  );
}

export default addresses;
