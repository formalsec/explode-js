const esl = require("esl_symbolic");
const { quote } = require("shell-quote");

const cp = require("child_process");
cp.execSync(quote([ esl.string("payload") ]));
