const esl = require("esl_symbolic");
require.cache["fs"] = {
  exports: {
    lstat: function (from, cb) {
      return cb(null, { isDirectory: function () { return true; } });
    }
  }
};

const fsPath = require('fs-path');
const from = "./"; // normal
const dist = esl.string("dist");
fsPath.copy(from, dist, () => { })
