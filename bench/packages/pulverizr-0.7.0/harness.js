var esl = require("esl_symbolic");
require.cache[require.resolve("temp")] = {
  exports: {
    open: function (name, cb) {
      return cb(null, { path: "./" })
    }
  }
};


var root = require("pulverizr");

var inputs = []
var job = root.createJob(inputs, {});
job.compress(esl.string("payload"));
job.run();
