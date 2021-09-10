import { AddressZero } from "@ethersproject/constants";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { SALT_ONE, SALT_ZERO } from "../../../../helpers/constants";
import { PRBProxy__factory } from "../../../../typechain/factories/PRBProxy__factory";
import { PRBProxy } from "../../../../typechain/PRBProxy";
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
      await expect(this.contracts.prbProxyRegistry.connect(deployer).deployFor(AddressZero)).to.be.revertedWith(
        OwnableErrors.OwnerZeroAddress,
      );
    });
  });

  context("when the proxy is not the zero address", function () {
    context("when the owner transferred ownership", function () {
      let thirdParty: SignerWithAddress;

      beforeEach(async function () {
        thirdParty = this.signers.carol;

        await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address);
        const prbProxy: PRBProxy = PRBProxy__factory.connect(proxyAddress, owner);
        await prbProxy.connect(owner).transferOwnership(thirdParty.address);
      });

      it("deploys the proxy", async function () {
        await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address);

        const newProxyAddress: string = computeProxyAddress.call(this, deployer.address, SALT_ZERO);
        const deployedBytecode: string = await ethers.provider.getCode(newProxyAddress);
        expect(deployedBytecode).to.equal(expectedBytecode);
      });
    });

    context("when the owner did not transfer ownership", function () {
      context("when the deployer is the same as the owner", function () {
        it("deploys the proxy", async function () {
          await this.contracts.prbProxyRegistry.connect(deployer).deployFor(deployer.address);
          const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
          expect(deployedBytecode).to.equal(expectedBytecode);
        });
      });

      context("when the deployer is not the same as the owner", function () {
        context("when it is the first proxy of the user", function () {
          it("deploys the proxy", async function () {
            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address);
            const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
            expect(deployedBytecode).to.equal(expectedBytecode);
          });

          it("updates the proxies mapping", async function () {
            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address);
            const newProxyAddress: string = await this.contracts.prbProxyRegistry.proxies(owner.address, SALT_ZERO);
            expect(proxyAddress).to.equal(newProxyAddress);
          });

          // it("updates the salts mapping", async function () {

          // });
        });

        context("when it is the second proxy of the user", function () {
          let proxyAddress: string;

          beforeEach(async function () {
            proxyAddress = computeProxyAddress.call(this, deployer.address, SALT_ONE);

            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address);
          });

          it("deploys the proxy", async function () {
            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address);
            const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
            expect(deployedBytecode).to.equal(expectedBytecode);
          });

          it("updates the proxies mapping", async function () {
            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address);
            const newProxyAddress: string = await this.contracts.prbProxyRegistry.proxies(owner.address, SALT_ONE);
            expect(proxyAddress).to.equal(newProxyAddress);
          });
        });
      });
    });
  });
}
