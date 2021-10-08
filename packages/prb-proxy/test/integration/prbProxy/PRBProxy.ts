import { integrationFixturePrbProxy } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxy } from "./PRBProxy.behavior";

export function integrationTestPrbProxy(): void {
  describe("PRBProxy", function () {
    beforeEach(async function () {
      const { prbProxy, targetEcho, targetPanic, targetRevert, targetSelfDestruct } = await this.loadFixture(
        integrationFixturePrbProxy,
      );
      this.contracts.prbProxy = prbProxy;
      this.contracts.targetEcho = targetEcho;
      this.contracts.targetPanic = targetPanic;
      this.contracts.targetRevert = targetRevert;
      this.contracts.targetSelfDestruct = targetSelfDestruct;
    });

    shouldBehaveLikePrbProxy();
  });
}
