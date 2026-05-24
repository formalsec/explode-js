const esl = require("esl_symbolic");
require.cache[require.resolve("mz/child_process")] = { exports: require("child_process") };

class Socket {
  constructor() {
    console.log("Socket stub");
  }
  setTimeout(a, b) { }
  connect(a, b, c) { }
  once(a, cb) {
    // call cb to resolve promise
    cb()
  }
  destroy() { }
}

require.cache["net"] = { exports: { Socket: Socket } };

const find = require("local-devices");
let userInput = esl.string("userInput");
esl.assume(userInput != "");
find(userInput);
