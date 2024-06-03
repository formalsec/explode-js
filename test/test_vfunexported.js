let exec = require('child_process').exec;

module.exports = function f(x) {
  return exec(x);
};
