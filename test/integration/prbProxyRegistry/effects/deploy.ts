import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { SALT_ZERO } from "../../../../helpers/constants";
import { computeProxyAddress } from "../../../shared/create2";
import { getCloneDeployedBytecode } from "../../../shared/eip1167";

export default function shouldBehaveLikeDeploy(): void {
  let deployer: SignerWithAddress;
  let proxyAddress: string;

  beforeEach(async function () {
    deployer = this.signers.alice;
    proxyAddress = await computeProxyAddress.call(this, deployer.address);
  });

  it("deploys the proxy", async function () {
    await this.contracts.prbProxyRegistry.connect(deployer).deploy();
    const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
    const expectedBytecode: string = getCloneDeployedBytecode(this.contracts.prbProxyImplementation.address);
    expect(deployedBytecode).to.equal(expectedBytecode);
  });

  it("updates the currentProxies mapping", async function () {
    await this.contracts.prbProxyRegistry.connect(deployer).deploy();
    const currentProxy: string = await this.contracts.prbProxyRegistry.getCurrentProxy(deployer.address);
    expect(proxyAddress).to.equal(currentProxy);
  });
}
