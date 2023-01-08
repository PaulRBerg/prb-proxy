import { baseContext } from "../shared/contexts";
import { integrationTestPrbProxyRegistry } from "./prbProxyRegistry/PRBProxyRegistry.test";

baseContext("PRBProxy Solidity", function () {
  integrationTestPrbProxyRegistry();
});
