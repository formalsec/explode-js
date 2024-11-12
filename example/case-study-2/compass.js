var exec  = require('child_process').exec;
var merge = require('merge');
var dargs = require('dargs');

var generateCommand = function(options) {
  var compassCommand = options.compassCommand;
  var excludes = ['compassCommand'];
  var args = dargs(options, { excludes: excludes });
  var command = [compassCommand, 'compile'].concat(args).join(' ');
  return command;
};

function Compass() {
  this.defaultOptions = {
    compassCommand: 'compass'
  };
}

Compass.prototype.compile = function(options) {
  var compassOptions = merge(this.defaultOptions, options || {});
  var command = generateCommand(compassOptions);

  return new Promise(function(resolve, reject) {
    exec(command, function(error, stdout, stderr) {
      if (error) {
        if (stdout) { console.log(stdout); }
        if (stderr) { console.log(stderr); }
        reject(error);
      } else {
        resolve(compassOptions.cssDir);
      }
    });
  });
};

module.exports = Compass;
