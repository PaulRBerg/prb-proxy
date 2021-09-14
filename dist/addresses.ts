import { getCreate2Address } from "@ethersproject/address";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";

import PRBProxyArtifact from "../artifacts/PRBProxy.json";
import { computeFinalSalt } from "./salts";

const addresses = {
  PRBProxy: "0x427fA23EA53225AC1b7510194E51979510A68007",
  PRBProxyFactory: "0x479F1CD619a9efCeD0338a72C8CFc42Cd17B96F8",
  PRBProxyRegistry: "0x5E4cb493AF09B3e36AdF2aBBc9840E1297A9Bf1c",
};

export function computeProxyAddress(deployer: string, salt: string): string {
  return getCreate2Address(
    addresses.PRBProxyFactory,
    computeFinalSalt(deployer, salt),
    solidityKeccak256(["bytes"], [PRBProxyArtifact.bytecode]),
  );
}

export default addresses;
