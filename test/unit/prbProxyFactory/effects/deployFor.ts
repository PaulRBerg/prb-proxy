import { AddressZero } from "@ethersproject/constants";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { getProxyAddress, getRandomSalt } from "../../../shared/create2";
import { OwnableErrors } from "../../../shared/errors";

export default function shouldBehaveLikeDeployFor(): void {
  const salt: string = getRandomSalt();
  let deployer: SignerWithAddress;
  let owner: SignerWithAddress;
  let proxyAddress: string;

  beforeEach(function () {
    deployer = this.signers.alice;
    owner = this.signers.bob;
    proxyAddress = getProxyAddress.call(this, deployer.address, salt);
  });

  context("when the owner is the zero address", function () {
    it("reverts", async function () {
      await expect(
        this.contracts.prbProxyFactory.connect(this.signers.alice).deployFor(AddressZero, salt),
      ).to.be.revertedWith(OwnableErrors.OwnerZeroAddress);
    });
  });

  context("when the owner is not the zero address", function () {
    context("when the deployer is the same as the owner", function () {
      it("deploys the proxy", async function () {
        await this.contracts.prbProxyFactory.connect(deployer).deployFor(deployer.address, salt);
        const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
        expect(deployedBytecode).to.equal(this.artifacts.prbProxy.deployedBytecode);
      });
    });

    context("when the deployer is not the same as the owner", function () {
      it("deploys the proxy", async function () {
        await this.contracts.prbProxyFactory.connect(deployer).deployFor(owner.address, salt);
        const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
        expect(deployedBytecode).to.equal(this.artifacts.prbProxy.deployedBytecode);
      });

      it("updates the mapping", async function () {
        await this.contracts.prbProxyFactory.connect(deployer).deployFor(owner.address, salt);
        const isProxy: boolean = await this.contracts.prbProxyFactory.isProxy(proxyAddress);
        expect(isProxy).to.equal(true);
      });

      it("emits a DeployProxy event", async function () {
        await expect(this.contracts.prbProxyFactory.connect(deployer).deployFor(owner.address, salt))
          .to.emit(this.contracts.prbProxyFactory, "DeployProxy")
          .withArgs(deployer.address, owner.address, proxyAddress);
      });
    });
  });
}
