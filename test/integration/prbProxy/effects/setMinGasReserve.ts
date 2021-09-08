import { Zero } from "@ethersproject/constants";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";

import { OwnableErrors } from "../../../shared/errors";
import { bn } from "../../../shared/numbers";

export default function shouldBehaveLikeSetMinGasReserve(): void {
  let owner: SignerWithAddress;

  beforeEach(async function () {
    owner = this.signers.alice;
  });

  context("when called on the implementation contract", function () {
    it("reverts", async function () {
      await expect(this.contracts.prbProxyImplementation.connect(owner).setMinGasReserve(Zero)).to.be.revertedWith(
        OwnableErrors.NotOwner,
      );
    });
  });

  context("when called on the clone", function () {
    context("when the proxy was not initialized", function () {
      it("reverts", async function () {
        await expect(this.contracts.prbProxy.connect(owner).setMinGasReserve(Zero)).to.be.revertedWith(
          OwnableErrors.NotOwner,
        );
      });
    });

    context("when the proxy was initialized", function () {
      beforeEach(async function () {
        await this.contracts.prbProxy.connect(owner).initialize(owner.address);
      });

      context("when the caller is not the owner", function () {
        it("reverts", async function () {
          const raider: SignerWithAddress = this.signers.bob;
          await expect(this.contracts.prbProxy.connect(raider).setMinGasReserve(Zero)).to.be.revertedWith(
            OwnableErrors.NotOwner,
          );
        });
      });

      context("when the caller is the owner", function () {
        it("sets the min gas reserve", async function () {
          await this.contracts.prbProxy.connect(owner).setMinGasReserve(bn("5001"));
          const newMinGasReserve = await this.contracts.prbProxy.minGasReserve();
          expect(newMinGasReserve).to.equal(bn("5001"));
        });
      });
    });
  });
}
