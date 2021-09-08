import { integrationFixturePrbProxyFactory } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxyFactory } from "./PRBProxyFactory.behavior";

export function integrationTestPrbProxyFactory(): void {
  describe("PRBProxyFactory", function () {
    beforeEach(async function () {
      const { prbProxyFactory, prbProxyImplementation } = await this.loadFixture(integrationFixturePrbProxyFactory);
      this.contracts.prbProxyImplementation = prbProxyImplementation;
      this.contracts.prbProxyFactory = prbProxyFactory;
    });

    shouldBehaveLikePrbProxyFactory();
  });
}
