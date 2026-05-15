var esl = require("esl_symbolic");
require.cache[require.resolve("debug")] = { exports : esl.lazy_object() };

var launchpad = require("launchpad/lib/local/instance");
var tst = new launchpad.Instance(esl.string("cmd"), esl.lazy_object(), esl.lazy_object(), { process: esl.string("process") });
tst.getPid(function () { });
