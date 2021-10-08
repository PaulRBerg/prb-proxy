import { integrationFixturePrbProxyFactory } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxyFactory } from "./PRBProxyFactory.behavior";

export function integrationTestPrbProxyFactory(): void {
  describe("PRBProxyFactory", function () {
    beforeEach(async function () {
      const { prbProxy, prbProxyFactory } = await this.loadFixture(integrationFixturePrbProxyFactory);
      this.contracts.prbProxy = prbProxy;
      this.contracts.prbProxyFactory = prbProxyFactory;
    });

    shouldBehaveLikePrbProxyFactory();
  });
}
