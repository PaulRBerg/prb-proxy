import { unitTestPrbProxyRegistry } from "../integration/prbProxyRegistry/PRBProxyRegistry";
import { baseContext } from "../shared/contexts";

baseContext("Integration Tests", function () {
  unitTestPrbProxyRegistry();
});
