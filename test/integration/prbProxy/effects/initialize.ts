import { BigNumber } from "@ethersproject/bignumber";
import { AddressZero } from "@ethersproject/constants";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";

import { PRBProxyErrors } from "../../../shared/errors";
import { bn } from "../../../shared/numbers";

export default function shouldBehaveLikeInitialize(): void {
  context("when called via the implementation contract", function () {
    it("reverts", async function () {
      await expect(this.contracts.prbProxyImplementation.initialize(AddressZero)).to.be.revertedWith(
        PRBProxyErrors.AlreadyInitialized,
      );
    });
  });

  context("when called via the the clone", function () {
    let owner: SignerWithAddress;

    beforeEach(async function () {
      owner = this.signers.alice;
    });

    context("when the proxy was initialized", function () {
      beforeEach(async function () {
        await this.contracts.prbProxy.initialize(owner.address);
      });

      it("reverts", async function () {
        await expect(this.contracts.prbProxy.initialize(owner.address)).to.be.revertedWith(
          PRBProxyErrors.AlreadyInitialized,
        );
      });
    });

    context("when the proxy was not initialized", function () {
      it("initializes the proxy", async function () {
        await this.contracts.prbProxy.initialize(owner.address);

        const newMinGasReserve: BigNumber = await this.contracts.prbProxy.minGasReserve();
        expect(newMinGasReserve).to.equal(bn("5000"));

        const newOwner: string = await this.contracts.prbProxy.owner();
        expect(newOwner).to.equal(owner.address);
      });
    });
  });
}
