import { Signer } from "@ethersproject/abstract-signer";
import { artifacts, waffle } from "hardhat";
import { Artifact } from "hardhat/types";

import { PRBProxy__factory } from "../../typechain/factories/PRBProxy__factory";
import { PRBProxy } from "../../typechain/PRBProxy";
import { PRBProxyFactory } from "../../typechain/PRBProxyFactory";
import { PRBProxyRegistry } from "../../typechain/PRBProxyRegistry";
import { TargetEcho } from "../../typechain/TargetEcho";
import { TargetPanic } from "../../typechain/TargetPanic";
import { TargetRevert } from "../../typechain/TargetRevert";
import { TargetSelfDestruct } from "../../typechain/TargetSelfDestruct";
import { SALT_ZERO } from "../../helpers/constants";

type IntegrationFixturePrbProxyReturnType = {
  prbProxy: PRBProxy;
  targetEcho: TargetEcho;
  targetPanic: TargetPanic;
  targetRevert: TargetRevert;
  targetSelfDestruct: TargetSelfDestruct;
};

export async function integrationFixturePrbProxy(signers: Signer[]): Promise<IntegrationFixturePrbProxyReturnType> {
  const deployer: Signer = signers[0];

  const prbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("PRBProxyFactory");
  const prbProxyFactory: PRBProxyFactory = <PRBProxyFactory>(
    await waffle.deployContract(deployer, prbProxyFactoryArtifact, [])
  );

  const deployerAddress: string = await deployer.getAddress();
  const prbProxyAddress: string = await prbProxyFactory.connect(deployer).callStatic.deployFor(deployerAddress);
  await prbProxyFactory.connect(deployer).deployFor(deployerAddress);
  const prbProxy: PRBProxy = PRBProxy__factory.connect(prbProxyAddress, deployer);

  const targetEchoArtifact: Artifact = await artifacts.readArtifact("TargetEcho");
  const targetEcho: TargetEcho = <TargetEcho>await waffle.deployContract(deployer, targetEchoArtifact, []);

  const targetPanicArtifact: Artifact = await artifacts.readArtifact("TargetPanic");
  const targetPanic: TargetPanic = <TargetPanic>await waffle.deployContract(deployer, targetPanicArtifact, []);

  const targetRevertArtifact: Artifact = await artifacts.readArtifact("TargetRevert");
  const targetRevert: TargetRevert = <TargetRevert>await waffle.deployContract(deployer, targetRevertArtifact, []);

  const targetSelfDestructArtifact: Artifact = await artifacts.readArtifact("TargetSelfDestruct");
  const targetSelfDestruct: TargetSelfDestruct = <TargetSelfDestruct>(
    await waffle.deployContract(deployer, targetSelfDestructArtifact, [])
  );

  return { prbProxy, targetEcho, targetPanic, targetRevert, targetSelfDestruct };
}

type IntegrationFixturePrbProxyFactoryReturnType = {
  prbProxy: PRBProxy;
  prbProxyFactory: PRBProxyFactory;
};

export async function integrationFixturePrbProxyFactory(
  signers: Signer[],
): Promise<IntegrationFixturePrbProxyFactoryReturnType> {
  const deployer: Signer = signers[0];

  const prbProxyArtifact: Artifact = await artifacts.readArtifact("PRBProxy");
  const prbProxy: PRBProxy = <PRBProxy>await waffle.deployContract(deployer, prbProxyArtifact, []);

  const prbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("PRBProxyFactory");
  const prbProxyFactory: PRBProxyFactory = <PRBProxyFactory>(
    await waffle.deployContract(deployer, prbProxyFactoryArtifact, [])
  );

  return { prbProxy, prbProxyFactory };
}

type IntegrationFixturePrbProxyRegistryReturnType = {
  prbProxy: PRBProxy;
  prbProxyFactory: PRBProxyFactory;
  prbProxyRegistry: PRBProxyRegistry;
};

export async function integrationFixturePrbProxyRegistry(
  signers: Signer[],
): Promise<IntegrationFixturePrbProxyRegistryReturnType> {
  const deployer: Signer = signers[0];

  const prbProxyArtifact: Artifact = await artifacts.readArtifact("PRBProxy");
  const prbProxy: PRBProxy = <PRBProxy>await waffle.deployContract(deployer, prbProxyArtifact, []);

  const prbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("PRBProxyFactory");
  const prbProxyFactory: PRBProxyFactory = <PRBProxyFactory>(
    await waffle.deployContract(deployer, prbProxyFactoryArtifact, [])
  );

  const prbProxyRegistryArtifact: Artifact = await artifacts.readArtifact("PRBProxyRegistry");
  const prbProxyRegistry: PRBProxyRegistry = <PRBProxyRegistry>(
    await waffle.deployContract(deployer, prbProxyRegistryArtifact, [prbProxyFactory.address])
  );

  return { prbProxy, prbProxyFactory, prbProxyRegistry };
}
