import { integrationFixturePrbProxyRegistry } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxyRegistry } from "./PRBProxyRegistry.behavior";

export function integrationTestPrbProxyRegistry(): void {
  describe("PRBProxyRegistry", function () {
    beforeEach(async function () {
      const { prbProxy, prbProxyFactory, prbProxyRegistry } = await this.loadFixture(
        integrationFixturePrbProxyRegistry,
      );
      this.contracts.prbProxy = prbProxy;
      this.contracts.prbProxyFactory = prbProxyFactory;
      this.contracts.prbProxyRegistry = prbProxyRegistry;
    });

    shouldBehaveLikePrbProxyRegistry();
  });
}
