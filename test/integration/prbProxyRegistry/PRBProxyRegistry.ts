import { integrationFixturePrbProxyRegistry } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxyRegistry } from "./PRBProxyRegistry.behavior";

export function integrationTestPrbProxyRegistry(): void {
  describe("PRBProxyRegistry", function () {
    beforeEach(async function () {
      const {
        contracts: { prbProxyFactory, prbProxyImplementation, prbProxyRegistry },
      } = await this.loadFixture(integrationFixturePrbProxyRegistry);
      this.contracts.prbProxyFactory = prbProxyFactory;
      this.contracts.prbProxyImplementation = prbProxyImplementation;
      this.contracts.prbProxyRegistry = prbProxyRegistry;
    });

    shouldBehaveLikePrbProxyRegistry();
  });
}
