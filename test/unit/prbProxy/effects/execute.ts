import { AddressZero } from "@ethersproject/constants";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";

import { OwnableErrors, PRBProxyErrors } from "../../../shared/errors";

export default function shouldBehaveLikeExecute(): void {
  let owner: SignerWithAddress;

  beforeEach(function () {
    owner = this.signers.alice;
  });

  context("when the caller is not the owner", function () {
    let raider: SignerWithAddress;

    beforeEach(function () {
      raider = this.signers.bob;
    });

    it.only("reverts", async function () {
      const data: string = "0x";
      await expect(this.contracts.prbProxy.connect(raider).execute(AddressZero, data)).to.be.revertedWith(
        OwnableErrors.NotOwner,
      );
    });
  });

  context("when the caller is not the owner", function () {
    context("when the target is the zero address", function () {
      it("reverts", async function () {
        const data: string = "0x";
        await expect(this.contracts.prbProxy.connect(owner).execute(AddressZero, data)).to.be.revertedWith(
          PRBProxyErrors.TargetZeroAddress,
        );
      });
    });

    context("when the target is not the zero address", function () {
      context("when the target is not a contract", function () {
        it.skip("reverts", async function () {
          const target: string = "0x0000000000000000000000000000000000000001";
          const data: string = "0x";
          await expect(this.contracts.prbProxy.connect(owner).execute(target, data)).to.be.revertedWith(
            PRBProxyErrors.TargetInvalid,
          );
        });
      });
    });
  });
}
