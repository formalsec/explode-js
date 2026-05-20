const esl = require("esl_symbolic");
const ps = require("ps");
ps.lookup({ pid: esl.string("pid") }, function (err, proc) {});
