import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { Fixture } from "ethereum-waffle";

import { PRBProxy } from "../../typechain/PRBProxy";
import { PRBProxyFactory } from "../../typechain/PRBProxyFactory";
import { PRBProxyRegistry } from "../../typechain/PRBProxyRegistry";
import { TargetChangeOwner } from "../../typechain/TargetChangeOwner";
import { TargetEcho } from "../../typechain/TargetEcho";
import { TargetEnvoy } from "../../typechain/TargetEnvoy";
import { TargetPanic } from "../../typechain/TargetPanic";
import { TargetRevert } from "../../typechain/TargetRevert";
import { TargetSelfDestruct } from "../../typechain/TargetSelfDestruct";

declare module "mocha" {
  export interface Context {
    contracts: Contracts;
    loadFixture: <T>(fixture: Fixture<T>) => Promise<T>;
    signers: Signers;
  }
}

export interface Contracts {
  prbProxy: PRBProxy;
  prbProxyFactory: PRBProxyFactory;
  prbProxyRegistry: PRBProxyRegistry;
  targets: Targets;
}

export interface Signers {
  alice: SignerWithAddress;
  bob: SignerWithAddress;
  carol: SignerWithAddress;
}

export interface Targets {
  changeOwner: TargetChangeOwner;
  echo: TargetEcho;
  envoy: TargetEnvoy;
  panic: TargetPanic;
  revert: TargetRevert;
  selfDestruct: TargetSelfDestruct;
}
