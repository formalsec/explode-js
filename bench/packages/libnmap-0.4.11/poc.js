const nmap = require("libnmap");
const opts = {
  range: ["scanme.nmap.org", "x.x.$(touch libnmap)"],
};
nmap.scan(opts, function (err, report) { });
