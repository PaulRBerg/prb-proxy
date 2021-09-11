import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

import { computeFinalSalt } from "../../../../dist/salts";
import { SALT_ZERO } from "../../../../helpers/constants";
import { computeProxyAddress } from "../../../shared/create2";
import { getCloneDeployedBytecode } from "../../../shared/eip1167";
import { PRBProxyFactoryErrors } from "../../../shared/errors";

export default function shouldBehaveLikeClone(): void {
  let proxyAddress: string;
  let finalSalt: string;

  beforeEach(async function () {
    const deployer: SignerWithAddress = this.signers.alice;
    finalSalt = computeFinalSalt(this.signers.alice.address, SALT_ZERO);
    proxyAddress = await computeProxyAddress.call(this, deployer.address);
  });

  context("when the final salt was used", function () {
    beforeEach(async function () {
      await this.contracts.prbProxyFactory.__godMode_clone(finalSalt);
    });

    it("reverts", async function () {
      await expect(this.contracts.prbProxyFactory.__godMode_clone(finalSalt)).to.be.revertedWith(
        PRBProxyFactoryErrors.CloneFailed,
      );
    });
  });

  context("when the final salt was not used", function () {
    it("deploys the clone", async function () {
      await this.contracts.prbProxyFactory.__godMode_clone(finalSalt);
      const deployedBytecode: string = await ethers.provider.getCode(proxyAddress);
      const expectedBytecode: string = getCloneDeployedBytecode(this.contracts.prbProxyImplementation.address);
      expect(deployedBytecode).to.equal(expectedBytecode);
    });
  });
}
