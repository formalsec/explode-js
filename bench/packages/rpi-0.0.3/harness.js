var esl = require("esl_symbolic");
var RPI = require("rpi");
new RPI.GPIO(esl.string("payload"), '123');
