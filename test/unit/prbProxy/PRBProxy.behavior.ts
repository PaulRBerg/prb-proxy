import shouldBehaveLikeExecute from "./effects/execute";
import shouldBehaveLikeSetMinGasReserve from "./effects/setMinGasReserve";

export function shouldBehaveLikePrbProxy(): void {
  describe("Effects Functions", function () {
    describe("execute", function () {
      shouldBehaveLikeExecute();
    });

    describe("setMinGasReserve", function () {
      shouldBehaveLikeSetMinGasReserve();
    });
  });
}
