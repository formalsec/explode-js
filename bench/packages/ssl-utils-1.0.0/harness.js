var esl = require('esl_symbolic');
// Stub problematic behaviour
require.cache[require.resolve("tmp")] = {
  exports: {
    file: function (opts, cb) {
      cb(null, "./");
    }
  }
}

var ssl = require('ssl-utils');
ssl.createCertRequest({}, esl.string("payload"), "", () => { })
