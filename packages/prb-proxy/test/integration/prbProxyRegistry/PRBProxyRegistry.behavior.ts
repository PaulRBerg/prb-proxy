import { shouldBehaveLikeDeploy } from "./effects/deploy";
import { shouldBehaveLikeDeployFor } from "./effects/deployFor";

export function shouldBehaveLikePrbProxyRegistry(): void {
  describe("Effects Functions", function () {
    describe("deploy", function () {
      shouldBehaveLikeDeploy();
    });

    describe("deployFor", function () {
      shouldBehaveLikeDeployFor();
    });
  });
}
