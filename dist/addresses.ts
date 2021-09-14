import { getCreate2Address } from "@ethersproject/address";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

import PRBProxyArtifact from "../artifacts/PRBProxy.json";
import { computeFinalSalt } from "./salts";

const addresses = {
  PRBProxyFactory: "0x031233FDF1A3Fa4316aD0F197987fB975172450E",
  PRBProxyRegistry: "0xB2D4c98DD0CB05C399e3f930Ba37D1f035d3C88A",
};

export function computeProxyAddress(deployer: string, salt: string): string {
  return getCreate2Address(
    addresses.PRBProxyFactory,
    computeFinalSalt(deployer, salt),
    solidityKeccak256(["bytes"], [PRBProxyArtifact.bytecode]),
  );
}

export default addresses;
