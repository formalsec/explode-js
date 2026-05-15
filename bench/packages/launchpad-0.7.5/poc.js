var launchpad = require("launchpad/lib/local/instance");
var tst = new launchpad.Instance('node', {}, {}, { process: "s'; touch launchpad; # " });
tst.getPid(function () { });
