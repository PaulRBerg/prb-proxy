import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { Fixture } from "ethereum-waffle";

import { PRBProxy } from "../../typechain/PRBProxy";
import { PRBProxyFactory } from "../../typechain/PRBProxyFactory";
import { PRBProxyRegistry } from "../../typechain/PRBProxyRegistry";
import { TargetEcho } from "../../typechain/TargetEcho";
import { TargetPanic } from "../../typechain/TargetPanic";
import { TargetRevert } from "../../typechain/TargetRevert";

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
  prbProxyImplementation: PRBProxy;
  prbProxyRegistry: PRBProxyRegistry;
  targetEcho: TargetEcho;
  targetPanic: TargetPanic;
  targetRevert: TargetRevert;
}

export interface Signers {
  alice: SignerWithAddress;
  bob: SignerWithAddress;
  carol: SignerWithAddress;
}
