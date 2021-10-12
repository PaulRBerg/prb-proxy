export function getEnvVar(key: string): string {
  if (!process.env[key]) {
    throw new Error(`Please set ${key} as an env variable`);
  }
  return process.env[key] || "";
}
