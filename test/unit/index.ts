import { baseContext } from "../shared/contexts";
import { unitTestPrbProxyFactory } from "./prbProxyFactory/PRBProxyFactory";

baseContext("Unit Tests", function () {
  unitTestPrbProxyFactory();
});
