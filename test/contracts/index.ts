import { baseContext } from "../shared/contexts";
import { integrationTestPrbProxy } from "./prbProxy/PRBProxy";
import { integrationTestPrbProxyFactory } from "./prbProxyFactory/PRBProxyFactory";
import { integrationTestPrbProxyRegistry } from "./prbProxyRegistry/PRBProxyRegistry";

baseContext("PRBProxy Solidity", function () {
  integrationTestPrbProxy();
  integrationTestPrbProxyFactory();
  integrationTestPrbProxyRegistry();
});
