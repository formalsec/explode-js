const esl = require("esl_symbolic");
var exec = require("child_process").execSync;
require.cache["child_process"] = {
  exports: {
    execSync: function (cmd) {
      if (cmd === 'iw dev 2>/dev/null') {
        return [ esl.string("output") ];
      }
      return exec(cmd);
    }
  }

}


const si = require("systeminformation");

si.wifiConnections();
