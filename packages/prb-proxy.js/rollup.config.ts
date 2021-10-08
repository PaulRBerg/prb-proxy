import { nodeResolve } from "@rollup/plugin-node-resolve";
import commonjs from "rollup-plugin-commonjs";
import { terser } from "rollup-plugin-terser";

import pkg from "./package.json";

export default [
  {
    input: pkg.main,
    output: {
      exports: "named",
      file: "./dist/browser/prb-proxy.min.js",
      format: "iife",
      name: "PRBProxy",
      sourcemap: false,
    },
    plugins: [
      nodeResolve({
        browser: true,
      }),
      commonjs({
        namedExports: { PRBProxy: ["PRBProxy"] },
      }),
      terser(),
    ],
  },
];
