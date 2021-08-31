import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { Fixture } from "ethereum-waffle";

import { PRBProxyFactory } from "../../typechain/PRBProxyFactory";

declare module "mocha" {
  export interface Context {
    contracts: Contracts;
    loadFixture: <T>(fixture: Fixture<T>) => Promise<T>;
    signers: Signers;
  }
}

export interface Contracts {
  prbProxyFactory: PRBProxyFactory;
}

export interface Signers {
  alice: SignerWithAddress;
  bob: SignerWithAddress;
}
