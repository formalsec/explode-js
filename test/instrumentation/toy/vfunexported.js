let exec = require('child_process').exec;

moduke.exports = function f(x) {
  return exec(x);
};
