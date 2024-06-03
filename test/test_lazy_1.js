const esl_symbolic = require('esl_symbolic');
const sausage = require('sausage');
const exec = require('child_process').exec;

let x = esl_symbolic.string("x");
let sanitized_sausage = sausage.escape(x);
exec("sausage-validator " + sanitized_sausage)
