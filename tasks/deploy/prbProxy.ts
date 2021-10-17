import * as core from "@actions/core";
import { TransactionRequest, TransactionResponse } from "@ethersproject/abstract-provider";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task, types } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { DETERMINISTIC_DEPLOYMENT_PROXY_ADDRESS } from "../../helpers/constants";
import { PRBProxy__factory } from "../../src/types/factories/PRBProxy__factory";

task("deploy:contract:prb-proxy")
  .addOptionalParam("confirmations", "How many block confirmations to wait for", 0, types.int)
  .addOptionalParam("printAddress", "Print the address in the console", true, types.boolean)
  .addOptionalParam("setOutput", "Set the contract address as an output in GitHub Actions", false, types.boolean)
  .setAction(async function (taskArgs: TaskArguments, { ethers }): Promise<string> {
    const signers: SignerWithAddress[] = await ethers.getSigners();
    const deployer: SignerWithAddress = signers[0];

    const prbProxyFactory: PRBProxy__factory = new PRBProxy__factory(deployer);
    const deploymentTx: TransactionRequest = prbProxyFactory.getDeployTransaction();
    deploymentTx.to = DETERMINISTIC_DEPLOYMENT_PROXY_ADDRESS;
    const prbProxyAddress: string = await deployer.call(deploymentTx);
    const txResponse: TransactionResponse = await deployer.sendTransaction(deploymentTx);
    await txResponse.wait(taskArgs.confirmations);

    if (taskArgs.setOutput) {
      core.setOutput("prb-proxy", prbProxyAddress);
    }
    if (taskArgs.printAddress) {
      console.table([{ name: "PRBProxy", address: prbProxyAddress }]);
    }
    return prbProxyAddress;
  });
