import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { Fixture } from "ethereum-waffle";

import { PRBProxy } from "../../src/types/PRBProxy";
import { PRBProxyFactory } from "../../src/types/PRBProxyFactory";
import { PRBProxyRegistry } from "../../src/types/PRBProxyRegistry";
import { TargetChangeOwner } from "../../src/types/TargetChangeOwner";
import { TargetEcho } from "../../src/types/TargetEcho";
import { TargetEnvoy } from "../../src/types/TargetEnvoy";
import { TargetPanic } from "../../src/types/TargetPanic";
import { TargetRevert } from "../../src/types/TargetRevert";
import { TargetSelfDestruct } from "../../src/types/TargetSelfDestruct";

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
