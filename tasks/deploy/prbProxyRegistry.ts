import { TransactionRequest, TransactionResponse } from "@ethersproject/abstract-provider";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";
import { TaskArguments } from "hardhat/types";

import { DETERMINISTIC_DEPLOYMENT_PROXY_ADDRESS } from "../../helpers/constants";
import { PRBProxyRegistry__factory } from "../../typechain/factories/PRBProxyRegistry__factory";

task("deploy:contract:prb-proxy-registry")
  .addOptionalParam("factory", "Address of PRBProxyFactory contract")
  .setAction(async function (taskArgs: TaskArguments, { ethers }): Promise<void> {
    const signers: SignerWithAddress[] = await ethers.getSigners();
    const deployer: SignerWithAddress = signers[0];

    const prbProxyRegistryFactory: PRBProxyRegistry__factory = new PRBProxyRegistry__factory(deployer);
    const deploymentTx: TransactionRequest = prbProxyRegistryFactory.getDeployTransaction(taskArgs.factory);
    deploymentTx.to = DETERMINISTIC_DEPLOYMENT_PROXY_ADDRESS;
    const txResponse: TransactionResponse = await deployer.sendTransaction(deploymentTx);
    await txResponse.wait();
  });
