import { Signer } from "@ethersproject/abstract-signer";
import { artifacts, waffle } from "hardhat";
import { Artifact } from "hardhat/types";
import { Contract } from "@ethersproject/contracts";

import { PRBProxy } from "../../typechain/PRBProxy";
import { PRBProxyFactory } from "../../typechain/PRBProxyFactory";
import { PRBProxyRegistry } from "../../typechain/PRBProxyRegistry";
import { TargetEcho } from "../../typechain/TargetEcho";
import { TargetPanic } from "../../typechain/TargetPanic";
import { TargetRevert } from "../../typechain/TargetRevert";
import { getRandomSalt } from "./create2";

type IntegrationFixturePrbProxyReturnType = {
  contracts: {
    prbProxy: PRBProxy;
    targetEcho: TargetEcho;
    targetPanic: TargetPanic;
    targetRevert: TargetRevert;
  };
};

export async function integrationFixturePrbProxy(signers: Signer[]): Promise<IntegrationFixturePrbProxyReturnType> {
  const deployer: Signer = signers[0];

  const prbProxyArtifact: Artifact = await artifacts.readArtifact("PRBProxy");
  const prbProxyImplementation: PRBProxy = <PRBProxy>await waffle.deployContract(deployer, prbProxyArtifact, []);

  const prbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("PRBProxyFactory");
  const prbProxyFactory: PRBProxyFactory = <PRBProxyFactory>(
    await waffle.deployContract(deployer, prbProxyFactoryArtifact, [prbProxyImplementation.address])
  );

  const deployerAddress: string = await deployer.getAddress();
  const salt: string = getRandomSalt();
  const prbProxyAddress: string = await prbProxyFactory.connect(deployer).callStatic.deployFor(deployerAddress, salt);
  await prbProxyFactory.connect(deployer).deployFor(deployerAddress, salt);
  const prbProxy: PRBProxy = <PRBProxy>new Contract(prbProxyAddress, prbProxyArtifact.abi, deployer);

  const targetEchoArtifact: Artifact = await artifacts.readArtifact("TargetEcho");
  const targetEcho: TargetEcho = <TargetEcho>await waffle.deployContract(deployer, targetEchoArtifact, []);

  const targetPanicArtifact: Artifact = await artifacts.readArtifact("TargetPanic");
  const targetPanic: TargetPanic = <TargetPanic>await waffle.deployContract(deployer, targetPanicArtifact, []);

  const targetRevertArtifact: Artifact = await artifacts.readArtifact("TargetRevert");
  const targetRevert: TargetRevert = <TargetRevert>await waffle.deployContract(deployer, targetRevertArtifact, []);

  return { contracts: { prbProxy, targetEcho, targetPanic, targetRevert } };
}

type IntegrationFixturePrbProxyFactoryReturnType = {
  contracts: {
    prbProxyFactory: PRBProxyFactory;
    prbProxyImplementation: PRBProxy;
  };
};

export async function integrationFixturePrbProxyFactory(
  signers: Signer[],
): Promise<IntegrationFixturePrbProxyFactoryReturnType> {
  const deployer: Signer = signers[0];

  const prbProxyArtifact: Artifact = await artifacts.readArtifact("PRBProxy");
  const prbProxyImplementation: PRBProxy = <PRBProxy>await waffle.deployContract(deployer, prbProxyArtifact, []);

  const prbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("PRBProxyFactory");
  const prbProxyFactory: PRBProxyFactory = <PRBProxyFactory>(
    await waffle.deployContract(deployer, prbProxyFactoryArtifact, [prbProxyImplementation.address])
  );

  return { contracts: { prbProxyFactory, prbProxyImplementation } };
}

type IntegrationFixturePrbProxyRegistryReturnType = {
  contracts: {
    prbProxyFactory: PRBProxyFactory;
    prbProxyImplementation: PRBProxy;
    prbProxyRegistry: PRBProxyRegistry;
  };
};

export async function integrationFixturePrbProxyRegistry(
  signers: Signer[],
): Promise<IntegrationFixturePrbProxyRegistryReturnType> {
  const deployer: Signer = signers[0];

  const prbProxyArtifact: Artifact = await artifacts.readArtifact("PRBProxy");
  const prbProxyImplementation: PRBProxy = <PRBProxy>await waffle.deployContract(deployer, prbProxyArtifact, []);

  const prbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("PRBProxyFactory");
  const prbProxyFactory: PRBProxyFactory = <PRBProxyFactory>(
    await waffle.deployContract(deployer, prbProxyFactoryArtifact, [prbProxyImplementation.address])
  );

  const prbProxyRegistryArtifact: Artifact = await artifacts.readArtifact("PRBProxyRegistry");
  const prbProxyRegistry: PRBProxyRegistry = <PRBProxyRegistry>(
    await waffle.deployContract(deployer, prbProxyRegistryArtifact, [prbProxyFactory.address])
  );

  return { contracts: { prbProxyFactory, prbProxyImplementation, prbProxyRegistry } };
}
