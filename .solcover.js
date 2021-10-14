const shell = require("shelljs");

module.exports = {
  istanbulFolder: "coverage-contracts",
  istanbulReporter: ["html", "lcov"],
  onCompileComplete: async function (_config) {
    await run("typechain");
  },
  onIstanbulComplete: async function (_config) {
    // We need to do this because solcover generates bespoke artifacts.
    shell.rm("-rf", "./artifacts");
  },
  providerOptions: {
    mnemonic: process.env.MNEMONIC,
  },
  skipFiles: ["mocks", "test"],
};
