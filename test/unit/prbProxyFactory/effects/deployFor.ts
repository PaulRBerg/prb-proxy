import { defaultAbiCoder } from "@ethersproject/abi";
import { getCreate2Address } from "@ethersproject/address";
import { AddressZero } from "@ethersproject/constants";
import { keccak256 as solidityKeccak256 } from "@ethersproject/solidity";
import { expect } from "chai";
import { artifacts } from "hardhat";
import { Artifact } from "hardhat/types";

import { OwnableErrors } from "../../../shared/errors";

export default function shouldBehaveLikeDeployFor(): void {
  context("when the owner is the zero address", function () {
    it("reverts", async function () {
      await expect(
        this.contracts.prbProxyFactory.connect(this.signers.alice).deployFor(AddressZero),
      ).to.be.revertedWith(OwnableErrors.OwnerZeroAddress);
    });
  });

  context("when the owner is not the zero address", function () {
    context("when deploying for someone else", function () {
      it.only("works", async function () {
        const prbProxyArtifact: Artifact = await artifacts.readArtifact("PRBProxy");
        const proxyAddress: string = getCreate2Address(
          this.contracts.prbProxyFactory.address,
          solidityKeccak256(["address"], [defaultAbiCoder.encode(["address"], [this.signers.bob.address])]),
          solidityKeccak256(["bytes"], [prbProxyArtifact.bytecode]),
        );
        await expect(this.contracts.prbProxyFactory.connect(this.signers.alice).deployFor(this.signers.bob.address))
          .to.emit(this.contracts.prbProxyFactory, "DeployProxy")
          .withArgs(this.signers.alice.address, this.signers.bob.address, proxyAddress);
        // TODO: check bytecode is correct
      });
    });
  });
}
