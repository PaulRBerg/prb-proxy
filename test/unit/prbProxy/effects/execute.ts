import { BigNumber } from "@ethersproject/bignumber";
import { AddressZero, MaxUint256, Zero } from "@ethersproject/constants";
import { parseEther } from "@ethersproject/units";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";

import { getRandomSalt } from "../../../shared/create2";
import { OwnableErrors, PRBProxyErrors, PanicCodes } from "../../../shared/errors";
import { bn } from "../../../shared/numbers";

export default function shouldBehaveLikeExecute(): void {
  let owner: SignerWithAddress;

  beforeEach(function () {
    owner = this.signers.alice;
  });

  context("when the caller is not the owner", function () {
    let raider: SignerWithAddress;

    beforeEach(function () {
      raider = this.signers.bob;
    });

    it.skip("reverts", async function () {
      const data: string = "0x";
      await expect(this.contracts.prbProxy.connect(raider).execute(AddressZero, data)).to.be.revertedWith(
        OwnableErrors.NotOwner,
      );
    });
  });

  context("when the caller is the owner", function () {
    context("when the target is the zero address", function () {
      it("reverts", async function () {
        const data: string = "0x";
        await expect(this.contracts.prbProxy.connect(owner).execute(AddressZero, data)).to.be.revertedWith(
          PRBProxyErrors.TargetZeroAddress,
        );
      });
    });

    context("when the target is not the zero address", function () {
      context("when the target is not a contract", function () {
        it.skip("reverts", async function () {
          const target: string = "0x0000000000000000000000000000000000000001";
          const data: string = "0x";
          await expect(this.contracts.prbProxy.connect(owner).execute(target, data)).to.be.revertedWith(
            PRBProxyErrors.TargetInvalid,
          );
        });
      });

      context("when the target is a contract", function () {
        context("when the gas stipend calculation results into an underflow", function () {
          const gasLimit: BigNumber = bn("2e6");

          beforeEach(async function () {
            await this.contracts.prbProxy.connect(owner).setMinGasReserve(gasLimit.add(1));
          });

          it("reverts", async function () {
            const target: string = this.contracts.targetEcho.address;
            const data: string = this.contracts.targetEcho.interface.encodeFunctionData("echoUint256", [Zero]);
            await expect(this.contracts.prbProxy.connect(owner).execute(target, data, { gasLimit })).to.be.revertedWith(
              PanicCodes.ArithmeticOverflowOrUnderflow,
            );
          });
        });

        context("when the gas stipend calculation does not result into an underflow", function () {
          context("when the delegate call does not succeed", function () {
            context("when the exception is a panic", function () {
              let target: string;

              beforeEach(async function () {
                target = this.contracts.targetPanic.address;
              });

              it("panics due to assert", async function () {
                const data: string = this.contracts.targetPanic.interface.encodeFunctionData("panicAssert");
                await expect(this.contracts.prbProxy.connect(owner).execute(target, data)).to.be.revertedWith(
                  PanicCodes.Assert,
                );
              });

              it("panics due to division by zero", async function () {
                const data: string = this.contracts.targetPanic.interface.encodeFunctionData("panicDivisionByZero");
                await expect(this.contracts.prbProxy.connect(owner).execute(target, data)).to.be.revertedWith(
                  PanicCodes.DivisionByZero,
                );
              });

              it("panics due to arithmetic overflow", async function () {
                const data: string = this.contracts.targetPanic.interface.encodeFunctionData("panicArithmeticOverflow");
                await expect(this.contracts.prbProxy.connect(owner).execute(target, data)).to.be.revertedWith(
                  PanicCodes.ArithmeticOverflowOrUnderflow,
                );
              });

              it("panics due to arithmetic underflow", async function () {
                const data: string =
                  this.contracts.targetPanic.interface.encodeFunctionData("panicArithmeticUnderflow");
                await expect(this.contracts.prbProxy.connect(owner).execute(target, data)).to.be.revertedWith(
                  PanicCodes.ArithmeticOverflowOrUnderflow,
                );
              });
            });

            context("when the exception is an error", function () {
              let target: string;

              beforeEach(async function () {
                target = this.contracts.targetRevert.address;
              });

              it("reverts due to lack of payable modifier", async function () {
                const data: string =
                  this.contracts.targetRevert.interface.encodeFunctionData("revertLackPayableModifier");
                await expect(
                  this.contracts.prbProxy.connect(owner).execute(target, data, { value: parseEther("3.14") }),
                ).to.be.revertedWith(PRBProxyErrors.ExecutionReverted);
              });

              // Improve this when https://github.com/nomiclabs/hardhat/issues/1618 gets fixed.
              it("reverts with custom error", async function () {
                const data: string = this.contracts.targetRevert.interface.encodeFunctionData("revertWithCustomError");
                await expect(this.contracts.prbProxy.connect(owner).execute(target, data)).to.be.reverted;
              });

              it("reverts with nothing", async function () {
                const data: string = this.contracts.targetRevert.interface.encodeFunctionData("revertWithNothing");
                await expect(this.contracts.prbProxy.connect(owner).execute(target, data)).to.be.revertedWith(
                  PRBProxyErrors.ExecutionReverted,
                );
              });

              it("reverts with reason", async function () {
                const data: string = this.contracts.targetRevert.interface.encodeFunctionData("revertWithReason");
                await expect(this.contracts.prbProxy.connect(owner).execute(target, data)).to.be.revertedWith(
                  "This is a reason",
                );
              });

              it("reverts with require", async function () {
                const data: string = this.contracts.targetRevert.interface.encodeFunctionData("revertWithRequire");
                await expect(this.contracts.prbProxy.connect(owner).execute(target, data)).to.be.revertedWith(
                  PRBProxyErrors.ExecutionReverted,
                );
              });
            });
          });

          context("when the delegate call succeeds", function () {
            let target: string;

            beforeEach(async function () {
              target = this.contracts.targetEcho.address;
            });

            context("when ether is sent", function () {
              it("returns the ether amount back", async function () {
                const amount: BigNumber = parseEther("3.14");
                const data: string = this.contracts.targetEcho.interface.encodeFunctionData("echoMsgValue");
                const response: string = await this.contracts.prbProxy
                  .connect(owner)
                  .callStatic.execute(target, data, { value: amount });
                expect(amount).to.equal(bn(response));
              });
            });

            context("when ether is not sent", function () {
              it("returns the response as address", async function () {
                const input: string = "0x0000000000000000000000000000000000000001";
                const data: string = this.contracts.targetEcho.interface.encodeFunctionData("echoAddress", [input]);
                const response: string = await this.contracts.prbProxy.connect(owner).callStatic.execute(target, data);
                const decodedResponse: string = this.contracts.targetEcho.interface
                  .decodeFunctionResult("echoAddress", response)
                  .toString();
                expect(input).to.equal(decodedResponse);
              });

              it("returns the response as array", async function () {
                const input: BigNumber[] = [bn("3"), bn("1"), bn("4")];
                const data: string = this.contracts.targetEcho.interface.encodeFunctionData("echoArray", [input]);
                const response: string = await this.contracts.prbProxy.connect(owner).callStatic.execute(target, data);
                const decodedResponse: BigNumber[] = <BigNumber[]>(
                  this.contracts.targetEcho.interface.decodeFunctionResult("echoArray", response)[0]
                );
                const rawInput = input.map(x => x.toNumber());
                const rawResponse = decodedResponse.map(x => x.toNumber());
                expect(rawInput).to.have.all.members(rawResponse);
              });

              it("returns the response as bytes", async function () {
                const input: string = getRandomSalt() + "cafe";
                const data: string = this.contracts.targetEcho.interface.encodeFunctionData("echoBytes", [input]);
                const response: string = await this.contracts.prbProxy.connect(owner).callStatic.execute(target, data);
                const decodedResponse: string = this.contracts.targetEcho.interface
                  .decodeFunctionResult("echoBytes", response)
                  .toString();
                expect(input).to.equal(decodedResponse);
              });

              it("returns the response as bytes32", async function () {
                const input: string = getRandomSalt();
                const data: string = this.contracts.targetEcho.interface.encodeFunctionData("echoBytes32", [input]);
                const response: string = await this.contracts.prbProxy.connect(owner).callStatic.execute(target, data);
                expect(input).to.equal(response);
              });

              it("returns the response as string", async function () {
                const input: string = "This is a string";
                const data: string = this.contracts.targetEcho.interface.encodeFunctionData("echoString", [input]);
                const response: string = await this.contracts.prbProxy.connect(owner).callStatic.execute(target, data);
                const decodedResponse: string = this.contracts.targetEcho.interface
                  .decodeFunctionResult("echoString", response)
                  .toString();
                expect(input).to.equal(decodedResponse);
              });

              it("returns the response as struct", async function () {
                const input = { foo: bn("3"), bar: bn("1"), baz: bn("4") };
                const data: string = this.contracts.targetEcho.interface.encodeFunctionData("echoStruct", [input]);
                const response: string = await this.contracts.prbProxy.connect(owner).callStatic.execute(target, data);
                const decodedResponse = <typeof input>(
                  this.contracts.targetEcho.interface.decodeFunctionResult("echoStruct", response)[0]
                );
                expect(input.foo).to.equal(decodedResponse.foo);
                expect(input.bar).to.equal(decodedResponse.bar);
                expect(input.baz).to.equal(decodedResponse.baz);
              });

              it("returns the response as uint8", async function () {
                const input: BigNumber = bn("127");
                const data: string = this.contracts.targetEcho.interface.encodeFunctionData("echoUint8", [input]);
                const response: string = await this.contracts.prbProxy.connect(owner).callStatic.execute(target, data);
                expect(input).to.equal(bn(response));
              });

              it("returns the response as uint256", async function () {
                const input: BigNumber = MaxUint256;
                const data: string = this.contracts.targetEcho.interface.encodeFunctionData("echoUint256", [input]);
                const response: string = await this.contracts.prbProxy.connect(owner).callStatic.execute(target, data);
                expect(input).to.equal(bn(response));
              });
            });
          });
        });
      });
    });
  });
}
