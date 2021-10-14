import type { Provider } from "@ethersproject/abstract-provider";
import type { Signer } from "@ethersproject/abstract-signer";

import { PRB_PROXY_FACTORY_ADDRESS, PRB_PROXY_REGISTRY_ADDRESS } from "./constants";
import { PRBProxyFactory__factory } from "./types/factories/PRBProxyFactory__factory";
import { PRBProxyRegistry__factory } from "./types/factories/PRBProxyRegistry__factory";
import type { PRBProxyFactory } from "./types/PRBProxyFactory";
import { PRBProxyRegistry } from "./types/PRBProxyRegistry";

export function getFactory(signerOrProvider: Provider | Signer): PRBProxyFactory {
  const factory: PRBProxyFactory = PRBProxyFactory__factory.connect(PRB_PROXY_FACTORY_ADDRESS, signerOrProvider);
  return factory;
}

export function getRegistry(signerOrProvider: Provider | Signer): PRBProxyRegistry {
  const registry: PRBProxyRegistry = PRBProxyRegistry__factory.connect(PRB_PROXY_REGISTRY_ADDRESS, signerOrProvider);
  return registry;
}
