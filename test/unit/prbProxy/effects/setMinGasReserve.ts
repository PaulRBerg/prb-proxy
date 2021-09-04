import { Zero } from "@ethersproject/constants";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";

import { OwnableErrors } from "../../../shared/errors";
import { bn } from "../../../shared/numbers";

export default function shouldBehaveLikeSetMinGasReserve(): void {
  let owner: SignerWithAddress;

  beforeEach(function () {
    owner = this.signers.alice;
  });

  context("when the caller is not the owner", function () {
    let raider: SignerWithAddress;

    beforeEach(function () {
      raider = this.signers.bob;
    });

    it("reverts", async function () {
      await expect(this.contracts.prbProxy.connect(raider).setMinGasReserve(Zero)).to.be.revertedWith(
        OwnableErrors.NotOwner,
      );
    });
  });

  context("when the caller is the owner", function () {
    it("sets the min gas reserve", async function () {
      await this.contracts.prbProxy.connect(owner).setMinGasReserve(bn("6000"));
      const newMinGasReserve = await this.contracts.prbProxy.minGasReserve();
      expect(newMinGasReserve).to.equal(bn("6000"));
    });
  });
}
