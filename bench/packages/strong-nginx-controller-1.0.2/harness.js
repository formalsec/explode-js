var esl = require("esl_symbolic");
require.cache[require.resolve('core-js-pure/features/symbol/index.js')] = { exports: esl.lazy_object() };

var Root = require("strong-nginx-controller");
var baseDir = "";
var nginxPath = "./";
var controlEndpoint = {
  hostname: "abd",
  port: 123
}
var listenEndpoint = 12;
var nginxRoot = "";
var root = new Root(baseDir, nginxPath, controlEndpoint, listenEndpoint, nginxRoot);
var action = esl.string("action");
root._nginxCmd(action, function () { });
