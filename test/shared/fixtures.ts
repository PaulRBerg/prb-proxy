import { Signer } from "@ethersproject/abstract-signer";
import { artifacts, waffle } from "hardhat";
import { Artifact } from "hardhat/types";

import { PRBProxyFactory } from "../../typechain/PRBProxyFactory";
import { PRBProxyRegistry } from "../../typechain/PRBProxyRegistry";

const { deployContract } = waffle;

type IntegrationFixturePrbProxyRegistryReturnType = {
  artifacts: {
    prbProxy: Artifact;
  };
  contracts: {
    prbProxyFactory: PRBProxyFactory;
    prbProxyRegistry: PRBProxyRegistry;
  };
};

export async function integrationFixturePrbProxyRegistry(
  signers: Signer[],
): Promise<IntegrationFixturePrbProxyRegistryReturnType> {
  const prbProxy: Artifact = await artifacts.readArtifact("PRBProxy");

  const deployer: Signer = signers[0];
  const prbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("PRBProxyFactory");
  const prbProxyFactory: PRBProxyFactory = <PRBProxyFactory>await deployContract(deployer, prbProxyFactoryArtifact, []);

  const prbProxyRegistryArtifact: Artifact = await artifacts.readArtifact("PRBProxyRegistry");
  const prbProxyRegistry: PRBProxyRegistry = <PRBProxyRegistry>(
    await deployContract(deployer, prbProxyRegistryArtifact, [prbProxyFactory.address])
  );

  return { artifacts: { prbProxy }, contracts: { prbProxyFactory, prbProxyRegistry } };
}

type UnitFixturePrbProxyFactoryReturnType = {
  artifacts: {
    prbProxy: Artifact;
  };
  contracts: {
    prbProxyFactory: PRBProxyFactory;
  };
};

export async function unitFixturePrbProxyFactory(signers: Signer[]): Promise<UnitFixturePrbProxyFactoryReturnType> {
  const prbProxy: Artifact = await artifacts.readArtifact("PRBProxy");

  const deployer: Signer = signers[0];
  const prbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("PRBProxyFactory");
  const prbProxyFactory: PRBProxyFactory = <PRBProxyFactory>await deployContract(deployer, prbProxyFactoryArtifact, []);

  return { artifacts: { prbProxy }, contracts: { prbProxyFactory } };
}
