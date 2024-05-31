let exec = require('child_process').exec;

module.exports = function f(source) {
  if (Array.isArray(source)) {
    return exec(source.join(' '));
  }
  return exec(source);
};
