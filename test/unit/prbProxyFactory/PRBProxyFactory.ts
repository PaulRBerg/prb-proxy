import { unitFixturePrbProxyFactory } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxyFactory } from "./PRBProxyFactory.behavior";

export function unitTestPrbProxyFactory(): void {
  describe("PRBProxyFactory", function () {
    beforeEach(async function () {
      const {
        artifacts: { prbProxy },
        contracts: { prbProxyFactory },
      } = await this.loadFixture(unitFixturePrbProxyFactory);
      this.artifacts.prbProxy = prbProxy;
      this.contracts.prbProxyFactory = prbProxyFactory;
    });

    shouldBehaveLikePrbProxyFactory();
  });
}
