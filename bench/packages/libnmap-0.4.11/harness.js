const esl = require("esl_symbolic");
const nmap = require("libnmap");
const opts = {
  range: ["scanme.nmap.org", esl.string("payload")],
};
nmap.scan(opts, function (err, report) { });
