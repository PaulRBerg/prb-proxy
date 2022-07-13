import { baseContext } from "../shared/contexts";
import { integrationTestPrbProxy } from "./prbProxy/PRBProxy.test";
import { integrationTestPrbProxyRegistry } from "./prbProxyRegistry/PRBProxyRegistry.test";

baseContext("PRBProxy Solidity", function () {
  integrationTestPrbProxy();
  integrationTestPrbProxyRegistry();
});
