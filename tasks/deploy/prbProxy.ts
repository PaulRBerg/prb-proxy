import { TransactionRequest, TransactionResponse } from "@ethersproject/abstract-provider";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";

import { DETERMINISTIC_DEPLOYMENT_PROXY_ADDRESS } from "../../helpers/constants";
import { PRBProxy__factory } from "../../typechain/factories/PRBProxy__factory";

task("deploy:contract:prb-proxy").setAction(async function (_, { ethers }): Promise<void> {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  const deployer: SignerWithAddress = signers[0];

  const prbProxyFactory: PRBProxy__factory = new PRBProxy__factory(deployer);
  const deploymentTx: TransactionRequest = prbProxyFactory.getDeployTransaction();
  deploymentTx.to = DETERMINISTIC_DEPLOYMENT_PROXY_ADDRESS;
  const txResponse: TransactionResponse = await deployer.sendTransaction(deploymentTx);
  await txResponse.wait();
});
