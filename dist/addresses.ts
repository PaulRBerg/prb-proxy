import { getCreate2Address } from "@ethersproject/address";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

import { computeFinalSalt } from "./salts";

const addresses = {
  PRBProxy: "0x427fA23EA53225AC1b7510194E51979510A68007",
  PRBProxyFactory: "0x26f8B92465A199dd8d64c5c7e7cBd09320D85E34",
  PRBProxyRegistry: "0xFf53cd8D40419fB74843736E71D8b5C5B5C76135",
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
