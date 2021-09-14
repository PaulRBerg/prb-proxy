export enum OwnableErrors {
  NotOwner = "Ownable__NotOwner",
}

export enum PanicCodes {
  Assert = "0x1",
  ArithmeticOverflowOrUnderflow = "0x11",
  DivisionByZero = "0x12",
}

export enum PRBProxyErrors {
  AlreadyInitialized = "PRBProxy__AlreadyInitialized",
  ExecutionReverted = "PRBProxy__ExecutionReverted",
  TargetInvalid = "PRBProxy__TargetInvalid",
  TargetZeroAddress = "PRBProxy__TargetZeroAddress",
}

export enum PRBProxyFactoryErrors {
  CloneFailed = "PRBProxyFactory__CloneFailed",
}

export enum PRBProxyRegistryErrors {
  ProxyAlreadyExists = "PRBProxyRegistry__ProxyAlreadyExists",
}
