import { AddressZero } from "@ethersproject/constants";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { PRBProxy__factory } from "../../../../typechain/factories/PRBProxy__factory";
import { PRBProxy } from "../../../../typechain/PRBProxy";
import { getProxyAddress, getRandomSalt } from "../../../shared/create2";
import { getCloneDeployedBytecode } from "../../../shared/eip1167";
import { OwnableErrors, PRBProxyRegistryErrors } from "../../../shared/errors";

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
      await expect(this.contracts.prbProxyRegistry.connect(deployer).deployFor(AddressZero, salt)).to.be.revertedWith(
        OwnableErrors.OwnerZeroAddress,
      );
    });
  });

  context("when the proxy is not the zero address", function () {
    context("when the proxy exists for the owner", function () {
      beforeEach(async function () {
        await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address, salt);
      });

      it("reverts", async function () {
        await expect(
          this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address, salt),
        ).to.be.revertedWith(PRBProxyRegistryErrors.ProxyAlreadyDeployed);
      });
    });

    context("when the proxy does not exist for the owner", function () {
      context("when the owner transferred ownership", function () {
        let thirdParty: SignerWithAddress;

        beforeEach(async function () {
          thirdParty = this.signers.carol;

          await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address, salt);
          const prbProxy: PRBProxy = PRBProxy__factory.connect(proxyAddress, owner);
          await prbProxy.connect(owner).transferOwnership(thirdParty.address);
        });

        it("deploys the proxy", async function () {
          const newSalt: string = getRandomSalt();
          await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address, newSalt);

          const newProxyAddress: string = getProxyAddress.call(this, deployer.address, newSalt);
          const deployedBytecode: string = await ethers.provider.getCode(newProxyAddress);
          const expectedBytecode: string = getCloneDeployedBytecode(this.contracts.prbProxyImplementation.address);
          expect(deployedBytecode).to.equal(expectedBytecode);
        });
      });

      context("when the owner did not transfer ownership", function () {
        context("when the deployer is the same as the owner", function () {
          it("deploys the proxy", async function () {
            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(deployer.address, salt);
            const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
            const expectedBytecode: string = getCloneDeployedBytecode(this.contracts.prbProxyImplementation.address);
            expect(deployedBytecode).to.equal(expectedBytecode);
          });
        });

        context("when the deployer is not the same as the owner", function () {
          it("deploys the proxy", async function () {
            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address, salt);
            const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
            const expectedBytecode: string = getCloneDeployedBytecode(this.contracts.prbProxyImplementation.address);
            expect(deployedBytecode).to.equal(expectedBytecode);
          });

          it("updates the mapping", async function () {
            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address, salt);
            const newProxyAddress: string = await this.contracts.prbProxyRegistry.proxies(owner.address);
            expect(proxyAddress).to.equal(newProxyAddress);
          });
        });
      });
    });
  });
}
