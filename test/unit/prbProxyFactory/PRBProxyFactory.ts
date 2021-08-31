import { unitFixturePrbProxyFactory } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxyFactory } from "./PRBProxyFactory.behavior";

export function unitTestPrbProxyFactory(): void {
  describe("PRBProxyFactory", function () {
    beforeEach(async function () {
      const { prbProxyFactory } = await this.loadFixture(unitFixturePrbProxyFactory);
      this.contracts.prbProxyFactory = prbProxyFactory;
    });

    shouldBehaveLikePrbProxyFactory();
  });
}
