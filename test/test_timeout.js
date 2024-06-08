'use strict';

function template(literal, data) {
  var tmpl = literal.replace(/(\$\{)/gm, '$1data.');

  return eval('`' + tmpl + '`');
}

function encodeStatements(statements, data) {
  if (!statements) {
    throw new SyntaxError('Must include statements to encode');
  }

  if (!data) {
    return statements;
  }

  var output = template(JSON.stringify(statements), data);
  output = JSON.parse(output);

  Object.defineProperty(output, 'encoded', {
    __proto__: null,
    value: true
  });

  return output;
}

module.exports = encodeStatements;

let esl_symbolic = require("esl_symbolic");
esl_symbolic.sealProperties(Object.prototype);
// Vuln: code-injection
let statements = esl_symbolic.string("statements");
let data = esl_symbolic.any("data");
module.exports(statements, data);
