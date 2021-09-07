export function getCloneBytecode(implementation: string): string {
  return (
    "0x3d602d80600a3d3981f3363d3d373d3d3d363d73" +
    implementation.replace("0x", "").toLowerCase() +
    "5af43d82803e903d91602b57fd5bf3"
  );
}

export function getCloneDeployedBytecode(implementation: string): string {
  return "0x363d3d373d3d3d363d73" + implementation.replace("0x", "").toLowerCase() + "5af43d82803e903d91602b57fd5bf3";
}
