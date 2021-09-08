import shouldBehaveLikeClone from "./effects/clone";
import shouldBehaveLikeDeploy from "./effects/deploy";
import shouldBehaveLikeDeployFor from "./effects/deployFor";

export function shouldBehaveLikePrbProxyFactory(): void {
  describe("Effects Functions", function () {
    describe("clone", function () {
      shouldBehaveLikeClone();
    });

    describe("deploy", function () {
      shouldBehaveLikeDeploy();
    });

    describe("deployFor", function () {
      shouldBehaveLikeDeployFor();
    });
  });
}
