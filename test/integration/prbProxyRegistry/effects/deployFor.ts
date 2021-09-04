import { expect } from "chai";
import { AddressZero } from "@ethersproject/constants";
import { ethers } from "hardhat";
import { Contract } from "@ethersproject/contracts";

import { PRBProxy } from "../../../../typechain/PRBProxy";
import { OwnableErrors, PRBProxyRegistryErrors } from "../../../shared/errors";

import { getProxyAddress, getRandomSalt } from "../../../shared/create2";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

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
          const proxy: PRBProxy = <PRBProxy>new Contract(proxyAddress, this.artifacts.prbProxy.abi, owner);
          await proxy.connect(owner)._transferOwnership(thirdParty.address);
        });

        it("deploys the proxy", async function () {
          const newSalt: string = getRandomSalt();
          await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address, newSalt);

          const newProxyAddress: string = getProxyAddress.call(this, deployer.address, newSalt);
          const deployedBytecode: string = await ethers.provider.getCode(newProxyAddress);
          expect(deployedBytecode).to.equal(this.artifacts.prbProxy.deployedBytecode);
        });
      });

      context("when the owner did not transfer ownership", function () {
        context("when the deployer is the same as the owner", function () {
          it("deploys the proxy", async function () {
            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(deployer.address, salt);
            const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
            expect(deployedBytecode).to.equal(this.artifacts.prbProxy.deployedBytecode);
          });
        });

        context("when the deployer is not the same as the owner", function () {
          it("deploys the proxy", async function () {
            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address, salt);
            const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
            expect(deployedBytecode).to.equal(this.artifacts.prbProxy.deployedBytecode);
          });

          it("updates the mapping", async function () {
            await this.contracts.prbProxyRegistry.connect(deployer).deployFor(owner.address, salt);
            const mappingProxyAddress: string = await this.contracts.prbProxyRegistry.proxies(owner.address);
            expect(proxyAddress).to.equal(mappingProxyAddress);
          });
        });
      });
    });
  });
}
