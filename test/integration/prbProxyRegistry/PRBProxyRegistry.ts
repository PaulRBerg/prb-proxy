import { integrationFixturePrbProxyRegistry } from "../../shared/fixtures";
import { shouldBehaveLikePrbProxyRegistry } from "./PRBProxyRegistry.behavior";

export function unitTestPrbProxyRegistry(): void {
  describe("PRBProxyRegistry", function () {
    beforeEach(async function () {
      const {
        artifacts: { prbProxy },
        contracts: { prbProxyFactory, prbProxyRegistry },
      } = await this.loadFixture(integrationFixturePrbProxyRegistry);
      this.artifacts.prbProxy = prbProxy;
      this.contracts.prbProxyFactory = prbProxyFactory;
      this.contracts.prbProxyRegistry = prbProxyRegistry;
    });

    shouldBehaveLikePrbProxyRegistry();
  });
}
