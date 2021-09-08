import shouldBehaveLikeExecute from "./effects/execute";
import shouldBehaveLikeInitialize from "./effects/initialize";
import shouldBehaveLikeReceive from "./effects/receive";
import shouldBehaveLikeSetMinGasReserve from "./effects/setMinGasReserve";

export function shouldBehaveLikePrbProxy(): void {
  describe("Effects Functions", function () {
    describe("execute", function () {
      shouldBehaveLikeExecute();
    });

    describe("initialize", function () {
      shouldBehaveLikeInitialize();
    });

    describe("receive", function () {
      shouldBehaveLikeReceive();
    });

    describe("setMinGasReserve", function () {
      shouldBehaveLikeSetMinGasReserve();
    });
  });
}
