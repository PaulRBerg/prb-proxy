import { shouldBehaveLikeDeploy } from "./effects/deploy";
import { shouldBehaveLikeDeployFor } from "./effects/deployFor";
import { shouldBehaveLikeVersionGetter } from "./view/version";

export function shouldBehaveLikePrbProxyFactory(): void {
  describe("View Functions", function () {
    shouldBehaveLikeVersionGetter();
  });

  describe("Effects Functions", function () {
    describe("deploy", function () {
      shouldBehaveLikeDeploy();
    });

    describe("deployFor", function () {
      shouldBehaveLikeDeployFor();
    });
  });
}
