import { shouldBehaveLikeExecute } from "./effects/execute";
import { shouldBehaveLikeReceive } from "./effects/receive";
import { shouldBehaveLikeSetMinGasReserve } from "./effects/setMinGasReserve";
import { shouldBehaveLikeSetPermission } from "./effects/setPermission";
import { shouldBehaveLikeTransferOwnership } from "./effects/transferOwnership";

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

    describe("setPermission", function () {
      shouldBehaveLikeSetPermission();
    });

    describe("transferOwnership", function () {
      shouldBehaveLikeTransferOwnership();
    });
  });
}
