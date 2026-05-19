var esl = require("esl_symbolic");
var root = require("promise-probe");

var options = { sampleRate: esl.string("sampleRate"), seconds: esl.string("seconds") };
root.createMuteOgg(esl.string("outputFile"), options);
