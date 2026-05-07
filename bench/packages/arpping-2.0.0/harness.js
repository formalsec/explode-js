const esl = require("esl_symbolic");
const Arpping = require("arpping");
let arpping = new Arpping();
arpping.ping([esl.string("payload")]);
