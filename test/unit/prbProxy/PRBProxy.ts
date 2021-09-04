import { unitFixturePrbProxy } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxy } from "./PRBProxy.behavior";

export function unitTestPrbProxy(): void {
  describe("PRBProxy", function () {
    beforeEach(async function () {
      const {
        contracts: { prbProxy },
      } = await this.loadFixture(unitFixturePrbProxy);
      this.contracts.prbProxy = prbProxy;
    });

    shouldBehaveLikePrbProxy();
  });
}
