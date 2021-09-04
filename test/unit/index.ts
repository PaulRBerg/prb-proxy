import { baseContext } from "../shared/contexts";
import { unitTestPrbProxy } from "./prbProxy/PRBProxy";
import { unitTestPrbProxyFactory } from "./prbProxyFactory/PRBProxyFactory";

baseContext("Unit Tests", function () {
  unitTestPrbProxy();
  unitTestPrbProxyFactory();
});
