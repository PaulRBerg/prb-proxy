import { Signer } from "@ethersproject/abstract-signer";
import { artifacts, waffle } from "hardhat";
import { Artifact } from "hardhat/types";

import { PRBProxyFactory } from "../../typechain/PRBProxyFactory";

const { deployContract } = waffle;

type UnitFixturePrbMathSd59x18ReturnType = {
  prbProxyFactory: PRBProxyFactory;
};

export async function unitFixturePrbProxyFactory(signers: Signer[]): Promise<UnitFixturePrbMathSd59x18ReturnType> {
  const deployer: Signer = signers[0];
  const prbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("PRBProxyFactory");
  const prbProxyFactory: PRBProxyFactory = <PRBProxyFactory>await deployContract(deployer, prbProxyFactoryArtifact, []);
  return { prbProxyFactory };
}
