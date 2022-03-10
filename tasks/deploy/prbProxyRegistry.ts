import * as core from "@actions/core";
import { TransactionRequest, TransactionResponse } from "@ethersproject/abstract-provider";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task, types } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { DETERMINISTIC_DEPLOYMENT_PROXY_ADDRESS } from "../../helpers/constants";
import { PRBProxyRegistry__factory } from "../../src/types/factories/PRBProxyRegistry__factory";

task("deploy:contract:prb-proxy-registry")
  .addParam("factory", "Address of PRBProxyFactory contract")
  .addOptionalParam("confirmations", "How many block confirmations to wait for", 0, types.int)
  .addOptionalParam("printAddress", "Print the address in the console", true, types.boolean)
  .addOptionalParam("setOutput", "Set the contract address as an output in GitHub Actions", false, types.boolean)
  .setAction(async function (taskArgs: TaskArguments, { ethers }): Promise<string> {
    const signers: SignerWithAddress[] = await ethers.getSigners();
    const deployer: SignerWithAddress = signers[0];

    const prbProxyRegistryFactory: PRBProxyRegistry__factory = new PRBProxyRegistry__factory(deployer);
    const deploymentTx: TransactionRequest = prbProxyRegistryFactory.getDeployTransaction(taskArgs.factory);
    deploymentTx.to = DETERMINISTIC_DEPLOYMENT_PROXY_ADDRESS;
    const prbProxyRegistryAddress: string = await deployer.call(deploymentTx);
    const txResponse: TransactionResponse = await deployer.sendTransaction(deploymentTx);
    await txResponse.wait(taskArgs.confirmations);

    if (taskArgs.setOutput) {
      core.setOutput("prb-proxy-registry", prbProxyRegistryAddress);
    }
    if (taskArgs.printAddress) {
      console.table([{ name: "PRBProxyRegistry", address: prbProxyRegistryAddress }]);
    }
    return prbProxyRegistryAddress;
  });
