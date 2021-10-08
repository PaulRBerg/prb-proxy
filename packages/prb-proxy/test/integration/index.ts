import { baseContext } from "../shared/contexts";
import { integrationTestPrbProxy } from "./prbProxy/PRBProxy";
import { integrationTestPrbProxyFactory } from "./prbProxyFactory/PRBProxyFactory";
import { integrationTestPrbProxyRegistry } from "./prbProxyRegistry/PRBProxyRegistry";

baseContext("Integration Tests", function () {
  integrationTestPrbProxy();
  integrationTestPrbProxyFactory();
  integrationTestPrbProxyRegistry();
});
