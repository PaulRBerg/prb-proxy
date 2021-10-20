import type { BigNumber } from "@ethersproject/bignumber";
import { One } from "@ethersproject/constants";
import { expect } from "chai";

export function shouldBehaveLikeVersionGetter(): void {
  it("returns the correct version", async function () {
    const version: BigNumber = await this.contracts.prbProxyFactory.version();
    expect(One).to.equal(version);
  });
}
