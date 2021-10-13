import { expect } from "chai";
import forEach from "mocha-each";

import { computeProxyAddress } from "../../src/create2";
import { DEPLOYER_ADDRESS, SEED_ONE, SEED_ZERO } from "../shared/constants";

export function shouldBehaveLikeCreate2(): void {
  const testSets = [
    [DEPLOYER_ADDRESS, SEED_ZERO, "0x5D1a61e935edE5871bB8874B1b9108E3B8251e8c"],
    [DEPLOYER_ADDRESS, SEED_ONE, "0x3E88a453f396705D317A90e1022e907387fFB8fE"],
    [
      DEPLOYER_ADDRESS,
      "0x250cf77c5e9ae4bc917c7f2cb1b42e3e5d7cd29de5199c2ac358ecb811311a59",
      "0x5480BB8322570260e8d85b138A9A6658fbD34a06",
    ],
  ];

  forEach(testSets).it(
    "takes %.6s... and %.8s... and returns %.6s...",
    function (deployer: string, seed: string, expected: string) {
      const result: string = computeProxyAddress(deployer, seed);
      expect(expected).to.equal(result);
    },
  );
}
