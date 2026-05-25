const { deobfuscate } = require('js-deobfuscator');
const esl = require("esl_symbolic");
const source = esl.string("source");
deobfuscate(source);
