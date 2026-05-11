const esl = require("esl_symbolic");
const check = require('bwm-ng').check;
function bwmCb(interface, downSpeed, upSpeed) {}
check(bwmCb, [ esl.string("payload") ]);
