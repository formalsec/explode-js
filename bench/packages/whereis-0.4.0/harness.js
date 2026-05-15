const esl = require("esl_symbolic");
const whereis = require("whereis");
let filename = esl.string("filename");
whereis(filename, () => { });
