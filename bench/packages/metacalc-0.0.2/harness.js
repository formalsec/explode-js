const esl = require("esl_symbolic");
const { Sheet } = require('metacalc');

const sheet = new Sheet();

sheet.cells['A1'] = esl.string("payload");
console.log(sheet.values['A1']);
