import { shouldBehaveLikeCreate2 } from "./create2";
import { shouldBehaveLikeSalts } from "./salts";

describe("PRBProxy TypeScript", function () {
  describe("create2", function () {
    shouldBehaveLikeCreate2();
  });

  describe("salts", function () {
    shouldBehaveLikeSalts();
  });
});
