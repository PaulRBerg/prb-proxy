module.exports = {
  istanbulFolder: "coverage-contracts",
  istanbulReporter: ["html", "lcov"],
  providerOptions: {
    mnemonic: process.env.MNEMONIC,
  },
  skipFiles: ["mocks", "test"],
};
