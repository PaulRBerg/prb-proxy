import { integrationFixturePrbProxy } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxy } from "./PRBProxy.behavior";

export function integrationTestPrbProxy(): void {
  describe("PRBProxy", function () {
    beforeEach(async function () {
      const { prbProxy, targets } = await this.loadFixture(integrationFixturePrbProxy);
      this.contracts.prbProxy = prbProxy;
      this.contracts.targets.changeOwner = targets.changeOwner;
      this.contracts.targets.echo = targets.echo;
      this.contracts.targets.envoy = targets.envoy;
      this.contracts.targets.panic = targets.panic;
      this.contracts.targets.revert = targets.revert;
      this.contracts.targets.selfDestruct = targets.selfDestruct;
    });

    shouldBehaveLikePrbProxy();
  });
}
