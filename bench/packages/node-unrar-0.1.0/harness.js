const Unrar = require("node-unrar");
const esl = require("esl_symbolic");
var rar = new Unrar("/path/to/file.rar");
rar._execute([], esl.string("payload"));
