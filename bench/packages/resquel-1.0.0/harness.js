var Symbolic = require('esl_symbolic');
var util = require('./node_modules/resquel/src/util');

var req = {
  body:   { data: { firstName: "Robert'); DROP TABLE students;--", lastName: 'Smith' } },
  params: { customerId: Symbolic.string('payload') },
  query:  {}
};

var data     = util.getRequestData(req);
var replacer = util.queryReplace(data);

// Call the replacer directly — args[1] is the lodash path to the value
var id = replacer(null, 'params.customerId');

var query = "SELECT * FROM customers WHERE id=" + id;
Symbolic.sinkCall('sql-injection', 'resquel', query);
