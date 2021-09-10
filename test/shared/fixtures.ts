import { Signer } from "@ethersproject/abstract-signer";
import { artifacts, waffle } from "hardhat";
import { Artifact } from "hardhat/types";

import { PRBProxy__factory } from "../../typechain/factories/PRBProxy__factory";
import { PRBProxy } from "../../typechain/PRBProxy";
import { GodModePRBProxyFactory } from "../../typechain/GodModePRBProxyFactory";
import { PRBProxyRegistry } from "../../typechain/PRBProxyRegistry";
import { TargetEcho } from "../../typechain/TargetEcho";
import { TargetPanic } from "../../typechain/TargetPanic";
import { TargetRevert } from "../../typechain/TargetRevert";
import { computeFinalSalt } from "../../dist/salts";
import { TargetSelfDestruct } from "../../typechain/TargetSelfDestruct";
import { SALT_ZERO } from "../../helpers/constants";

type IntegrationFixturePrbProxyReturnType = {
  prbProxy: PRBProxy;
  prbProxyImplementation: PRBProxy;
  targetEcho: TargetEcho;
  targetPanic: TargetPanic;
  targetRevert: TargetRevert;
  targetSelfDestruct: TargetSelfDestruct;
};

export async function integrationFixturePrbProxy(signers: Signer[]): Promise<IntegrationFixturePrbProxyReturnType> {
  const deployer: Signer = signers[0];

  const prbProxyArtifact: Artifact = await artifacts.readArtifact("PRBProxy");
  const prbProxyImplementation: PRBProxy = <PRBProxy>await waffle.deployContract(deployer, prbProxyArtifact, []);

  const godModePrbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("GodModePRBProxyFactory");
  const prbProxyFactory: GodModePRBProxyFactory = <GodModePRBProxyFactory>(
    await waffle.deployContract(deployer, godModePrbProxyFactoryArtifact, [prbProxyImplementation.address])
  );

  const deployerAddress: string = await deployer.getAddress();
  const finalSalt: string = computeFinalSalt(deployerAddress, SALT_ZERO);
  const prbProxyAddress: string = await prbProxyFactory.connect(deployer).callStatic.__godMode_clone(finalSalt);
  await prbProxyFactory.connect(deployer).__godMode_clone(finalSalt);
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

  return { prbProxy, prbProxyImplementation, targetEcho, targetPanic, targetRevert, targetSelfDestruct };
}

type IntegrationFixturePrbProxyFactoryReturnType = {
  prbProxyFactory: GodModePRBProxyFactory;
  prbProxyImplementation: PRBProxy;
};

export async function integrationFixturePrbProxyFactory(
  signers: Signer[],
): Promise<IntegrationFixturePrbProxyFactoryReturnType> {
  const deployer: Signer = signers[0];

  const prbProxyArtifact: Artifact = await artifacts.readArtifact("PRBProxy");
  const prbProxyImplementation: PRBProxy = <PRBProxy>await waffle.deployContract(deployer, prbProxyArtifact, []);

  const godeModePrbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("GodModePRBProxyFactory");
  const prbProxyFactory: GodModePRBProxyFactory = <GodModePRBProxyFactory>(
    await waffle.deployContract(deployer, godeModePrbProxyFactoryArtifact, [prbProxyImplementation.address])
  );

  return { prbProxyFactory, prbProxyImplementation };
}

type IntegrationFixturePrbProxyRegistryReturnType = {
  prbProxyFactory: GodModePRBProxyFactory;
  prbProxyImplementation: PRBProxy;
  prbProxyRegistry: PRBProxyRegistry;
};

export async function integrationFixturePrbProxyRegistry(
  signers: Signer[],
): Promise<IntegrationFixturePrbProxyRegistryReturnType> {
  const deployer: Signer = signers[0];

  const prbProxyArtifact: Artifact = await artifacts.readArtifact("PRBProxy");
  const prbProxyImplementation: PRBProxy = <PRBProxy>await waffle.deployContract(deployer, prbProxyArtifact, []);

  const godeModePrbProxyFactoryArtifact: Artifact = await artifacts.readArtifact("GodModePRBProxyFactory");
  const prbProxyFactory: GodModePRBProxyFactory = <GodModePRBProxyFactory>(
    await waffle.deployContract(deployer, godeModePrbProxyFactoryArtifact, [prbProxyImplementation.address])
  );

  const prbProxyRegistryArtifact: Artifact = await artifacts.readArtifact("PRBProxyRegistry");
  const prbProxyRegistry: PRBProxyRegistry = <PRBProxyRegistry>(
    await waffle.deployContract(deployer, prbProxyRegistryArtifact, [prbProxyFactory.address])
  );

  return { prbProxyFactory, prbProxyImplementation, prbProxyRegistry };
}
