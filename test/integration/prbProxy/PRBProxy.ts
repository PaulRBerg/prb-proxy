import { integrationFixturePrbProxy } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxy } from "./PRBProxy.behavior";

export function integrationTestPrbProxy(): void {
  describe("PRBProxy", function () {
    beforeEach(async function () {
      const {
        contracts: { prbProxy, targetEcho, targetPanic, targetRevert },
      } = await this.loadFixture(integrationFixturePrbProxy);
      this.contracts.prbProxy = prbProxy;
      this.contracts.targetEcho = targetEcho;
      this.contracts.targetPanic = targetPanic;
      this.contracts.targetRevert = targetRevert;
    });

    shouldBehaveLikePrbProxy();
  });
}
