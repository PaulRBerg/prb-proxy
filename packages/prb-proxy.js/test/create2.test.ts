import { AddressZero } from "@ethersproject/constants";
import { expect } from "earljs";
import forEach from "mocha-each";

import { computeProxyAddress } from "../src/create2";
import { DEPLOYER_ADDRESS, SEED_ONE, SEED_ZERO } from "./shared/constants";

export function shouldBehaveLikeCreate2(): void {
  const testSets = [
    [AddressZero, SEED_ZERO, "0x2986c7e03ba6dC7915c46A5437e40B2aFeA73FEA"],
    [AddressZero, SEED_ONE, "0xB02421B2E1CAD0e14F6922909bED7F6b6f5c98Ed"],
    [
      AddressZero,
      "0x250cf77c5e9ae4bc917c7f2cb1b42e3e5d7cd29de5199c2ac358ecb811311a59",
      "0x80692179353c150b1FCCD037913c619314BF2495",
    ],
    [DEPLOYER_ADDRESS, SEED_ZERO, "0x7d4f0FbaC3149Be762085d36B992e270E38aB927"],
    [DEPLOYER_ADDRESS, SEED_ONE, "0x4F1283760aC6Df752E0B86Fd9a00121CCB9Fe6d2"],
    [
      DEPLOYER_ADDRESS,
      "0x250cf77c5e9ae4bc917c7f2cb1b42e3e5d7cd29de5199c2ac358ecb811311a59",
      "0xF3560DB65CBd9d09575aaDeb81fC128B81c93f9B",
    ],
  ];

  forEach(testSets).it(
    "takes %.6s... and %.8s... and returns %.6s...",
    function (deployer: string, seed: string, expected: string) {
      const result: string = computeProxyAddress(deployer, seed);
      expect(expected).toEqual(result);
    },
  );
}
