import { expect } from "chai";
import { ethers } from "hardhat";

import { computeFinalSalt, generateRandomSalt } from "../../../../dist/salts";
import { computeProxyAddress } from "../../../shared/create2";
import { getCloneDeployedBytecode } from "../../../shared/eip1167";
import { PRBProxyFactoryErrors } from "../../../shared/errors";

export default function shouldBehaveLikeClone(): void {
  let proxyAddress: string;
  let finalSalt: string;

  beforeEach(async function () {
    const salt: string = generateRandomSalt();
    finalSalt = computeFinalSalt(this.signers.alice.address, salt);
    proxyAddress = computeProxyAddress.call(this, this.signers.alice.address, salt);
  });

  context("when the salt was used", function () {
    beforeEach(async function () {
      await this.contracts.prbProxyFactory.__godMode_clone(finalSalt);
    });

    it("reverts", async function () {
      await expect(this.contracts.prbProxyFactory.__godMode_clone(finalSalt)).to.be.revertedWith(
        PRBProxyFactoryErrors.CloneFailed,
      );
    });
  });

  context("when the salt was not used", function () {
    it("deploys the clone", async function () {
      await this.contracts.prbProxyFactory.__godMode_clone(finalSalt);
      const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
      const expectedBytecode: string = getCloneDeployedBytecode(this.contracts.prbProxyImplementation.address);
      expect(deployedBytecode).to.equal(expectedBytecode);
    });
  });
}
