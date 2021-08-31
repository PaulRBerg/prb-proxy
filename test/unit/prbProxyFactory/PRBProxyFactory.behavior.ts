import shouldBehaveLikeDeployFor from "./effects/deployFor";

export function shouldBehaveLikePrbProxyFactory(): void {
  describe("Effects Functions", function () {
    describe("deployFor", function () {
      shouldBehaveLikeDeployFor();
    });
  });
}
