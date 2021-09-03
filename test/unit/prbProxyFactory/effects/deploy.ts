import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { getProxyAddress, getRandomSalt } from "../../../shared/create2";

export default function shouldBehaveLikeDeploy(): void {
  const salt: string = getRandomSalt();
  let deployer: SignerWithAddress;
  let proxyAddress: string;

  beforeEach(async function () {
    deployer = this.signers.alice;
    proxyAddress = getProxyAddress.call(this, deployer.address, salt);
  });

  it("deploys the proxy", async function () {
    await this.contracts.prbProxyFactory.connect(deployer).deploy(salt);
    const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
    expect(deployedBytecode).to.equal(this.artifacts.prbProxy.deployedBytecode);
  });

  it("updates the mapping", async function () {
    await this.contracts.prbProxyFactory.connect(deployer).deploy(salt);
    const isProxy: boolean = await this.contracts.prbProxyFactory.isProxy(proxyAddress);
    expect(isProxy).to.equal(true);
  });

  it("emits a DeployProxy event", async function () {
    await expect(this.contracts.prbProxyFactory.connect(deployer).deploy(salt))
      .to.emit(this.contracts.prbProxyFactory, "DeployProxy")
      .withArgs(deployer.address, deployer.address, proxyAddress);
  });
}
