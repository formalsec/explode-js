const root = require("adb-driver");
const esl = require('esl_symbolic');
root.execADBCommand([esl.string('payload')]);
