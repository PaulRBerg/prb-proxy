export enum OwnableErrors {
  NotOwner = "Ownable__NotOwner",
  OwnerZeroAddress = "Ownable__OwnerZeroAddress",
}

export enum PanicCodes {
  Assert = "0x1",
  ArithmeticOverflowOrUnderflow = "0x11",
  DivisionByZero = "0x12",
}

export enum PRBProxyErrors {
  ExecutionReverted = "PRBProxy__ExecutionReverted",
  TargetInvalid = "PRBProxy__TargetInvalid",
  TargetZeroAddress = "PRBProxy__TargetZeroAddress",
}

export enum PRBProxyRegistryErrors {
  ProxyAlreadyDeployed = "PRBProxyRegistry__ProxyAlreadyDeployed",
}
