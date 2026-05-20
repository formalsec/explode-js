const esl = require("esl_symbolic");
const scp = require("scp");
let options = {
  file: esl.string("file"),
  user: esl.string("user"),
  host: esl.string("host"),
  port: esl.string("port"),
  path: esl.string("path")
};
scp.send(options, function (err) { });
