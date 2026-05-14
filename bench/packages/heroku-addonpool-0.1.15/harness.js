var esl = require("esl_symbolic");
var Root = require("heroku-addonpool");
var root = Root("sss",esl.string("payload"),{});
root.setup();
