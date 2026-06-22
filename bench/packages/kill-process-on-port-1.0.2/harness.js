const Symbolic = require("esl_symbolic");

require.cache[require.resolve("portfinder")] = {
  exports:
  {
    getPortPromise: async function (options) {
      return new Promise((resolve, reject) => {
        resolve(null);
      });
    }
  }
};

require.cache[require.resolve("inquirer")] = { exports: Symbolic.lazy_object() };

const lib = require('kill-process-on-port');

async function run() {
  await lib.killProcessOnPort(Symbolic.string("port"), false);
}

run();
