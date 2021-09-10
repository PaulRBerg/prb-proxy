import { AddressZero } from "@ethersproject/constants";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { SALT_ZERO } from "../../../../helpers/constants";
import { computeProxyAddress } from "../../../shared/create2";
import { getCloneDeployedBytecode } from "../../../shared/eip1167";
import { OwnableErrors } from "../../../shared/errors";

export default function shouldBehaveLikeDeployFor(): void {
  let deployer: SignerWithAddress;
  let expectedBytecode: string;
  let owner: SignerWithAddress;
  let proxyAddress: string;

  beforeEach(function () {
    deployer = this.signers.alice;
    expectedBytecode = getCloneDeployedBytecode(this.contracts.prbProxyImplementation.address);
    owner = this.signers.bob;
    proxyAddress = computeProxyAddress.call(this, deployer.address, SALT_ZERO);
  });

  context("when the owner is the zero address", function () {
    it("reverts", async function () {
      await expect(
        this.contracts.prbProxyFactory.connect(this.signers.alice).deployFor(AddressZero),
      ).to.be.revertedWith(OwnableErrors.OwnerZeroAddress);
    });
  });

  context("when the owner is not the zero address", function () {
    context("when the deployer is the same as the owner", function () {
      it("deploys the proxy", async function () {
        await this.contracts.prbProxyFactory.connect(deployer).deployFor(deployer.address);
        const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
        expect(deployedBytecode).to.equal(expectedBytecode);
      });
    });

    context("when the deployer is not the same as the owner", function () {
      it("deploys the proxy", async function () {
        await this.contracts.prbProxyFactory.connect(deployer).deployFor(owner.address);
        const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
        expect(deployedBytecode).to.equal(expectedBytecode);
      });

      it("updates the isProxy mapping", async function () {
        await this.contracts.prbProxyFactory.connect(deployer).deployFor(owner.address);
        const isProxy: boolean = await this.contracts.prbProxyFactory.isProxy(proxyAddress);
        expect(isProxy).to.equal(true);
      });

      // it("updates the salts mapping", async function () {
      // });

      it("emits a DeployProxy event", async function () {
        await expect(this.contracts.prbProxyFactory.connect(deployer).deployFor(owner.address))
          .to.emit(this.contracts.prbProxyFactory, "DeployProxy")
          .withArgs(deployer.address, deployer.address, owner.address, proxyAddress);
      });
    });
  });
}
