import { hexZeroPad } from "@ethersproject/bytes";
import { AddressZero } from "@ethersproject/constants";
import { expect } from "earljs";
import forEach from "mocha-each";

import { computeFinalSalt } from "../src/salts";
import { DEPLOYER_ADDRESS, SALT_ONE, SALT_ZERO } from "./shared/constants";

export function shouldBehaveLikeSalts(): void {
  context("when the deployer is not an address", function () {
    it("throws an error", function () {
      const deployer: string = "foo";
      const salt: string = SALT_ZERO;
      expect(() => computeFinalSalt(deployer, salt)).toThrow(expect.stringMatching("invalid address"));
    });
  });

  context("when the deployer is an address", function () {
    context("when the salt is not 32 bytes length", function () {
      const testSets = ["0x01", hexZeroPad("0x00", 30), hexZeroPad("0x00", 34)];

      forEach(testSets).it("takes %.8s... and throws an error", function (salt: string) {
        const deployer: string = DEPLOYER_ADDRESS;
        expect(() => computeFinalSalt(deployer, salt)).toThrow(expect.stringMatching("incorrect data length"));
      });
    });

    context("when the salt is 32 bytes length", function () {
      const testSets = [
        [AddressZero, SALT_ZERO, "0xad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5"],
        [AddressZero, SALT_ONE, "0xa6eef7e35abe7026729641147f7915573c7e97b47efa546f5f6e3230263bcb49"],
        [
          AddressZero,
          "0x250cf77c5e9ae4bc917c7f2cb1b42e3e5d7cd29de5199c2ac358ecb811311a59",
          "0x39813af9ef58284ab410fff46ad31ede626bf2ea5057543e761f6e60e03c0f33",
        ],
        [DEPLOYER_ADDRESS, SALT_ZERO, "0xab5b4c7b1f080a1009980b72695b134c2bc26e2404d7d8c0aad8e0108b6614fe"],
        [DEPLOYER_ADDRESS, SALT_ONE, "0x30d8ff48ad1f00de01113f04032d08d51f95396e349fd9a495ebedba63074e67"],
        [
          DEPLOYER_ADDRESS,
          "0x250cf77c5e9ae4bc917c7f2cb1b42e3e5d7cd29de5199c2ac358ecb811311a59",
          "0xe214b913f06976f771c70af97ff9972652453e81f56215893e0ef2f58cdfaac3",
        ],
      ];

      forEach(testSets).it(
        "takes %.6s... and %.8s... and returns %.8s...",
        function (deployer: string, salt: string, expected: string) {
          const result: string = computeFinalSalt(deployer, salt);
          expect(expected).toEqual(result);
        },
      );
    });
  });
}
