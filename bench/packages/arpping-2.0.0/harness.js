const Arpping = require("arpping");
const esl = require('esl_symbolic');
let arpping = new Arpping();
arpping.ping([esl.string('payload')]);
