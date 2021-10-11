import { shouldBehaveLikeExecute } from "./effects/execute";
import { shouldBehaveLikeReceive } from "./effects/receive";
import { shouldBehaveLikeSetMinGasReserve } from "./effects/setMinGasReserve";

export function shouldBehaveLikePrbProxy(): void {
  describe("Effects Functions", function () {
    describe("execute", function () {
      shouldBehaveLikeExecute();
    });

    describe("receive", function () {
      shouldBehaveLikeReceive();
    });

    describe("setMinGasReserve", function () {
      shouldBehaveLikeSetMinGasReserve();
    });
  });
}
