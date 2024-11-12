var exec = require('child_process').exec;

function merge_recursive(base, extend) {
  if (typeOf(base) !== 'object')
    return extend;

  for (var key in extend) {
    if (typeOf(base[key]) === 'object' && typeOf(extend[key]) === 'object') {
      base[key] = merge_recursive(base[key], extend[key]);
    } else {
      base[key] = extend[key];
    }
  }
  return base;
}

function typeOf(input) {
  return ({}).toString.call(input).slice(8, -1).toLowerCase();
}

var merge = (() => {
  /**
   * Merge one or more objects
   * @param bool? clone
   * @param mixed,... arguments
   * @return object
   */

  var Public = function(clone) {

    return merge(clone === true, false, arguments);

  }, publicName = 'merge';

  /**
   * Merge two or more objects recursively
   * @param bool? clone
   * @param mixed,... arguments
   * @return object
   */

  Public.recursive = function(clone) {

    return merge(clone === true, true, arguments);

  };

  /**
   * Clone the input removing any reference
   * @param mixed input
   * @return mixed
   */

  Public.clone = function(input) {

    var output = input,
      type = typeOf(input),
      index, size;

    if (type === 'array') {

      output = [];
      size = input.length;

      for (index = 0; index < size; ++index)

        output[index] = Public.clone(input[index]);

    } else if (type === 'object') {

      output = {};

      for (index in input)

        output[index] = Public.clone(input[index]);

    }

    return output;

  };

  function merge(clone, recursive, argv) {
    var result = argv[0],
      size = argv.length;

    if (clone || typeOf(result) !== 'object')
      result = {};

    for (var index = 0; index < size; ++index) {
      var item = argv[index],
        type = typeOf(item);
      if (type !== 'object') continue;
      for (var key in item) {
        if (key === '__proto__') continue;
        var sitem = clone ? Public.clone(item[key]) : item[key];
        if (recursive) {
          result[key] = merge_recursive(result[key], sitem);
        } else {
          result[key] = sitem;
        }
      }
    }
    return result;
  }

  return Public;
})();

var numberIsNan = (() => {
  return Number.isNaN || function(x) {
    return x !== x;
  };
})();

function createArg(key, val, separator) {
  key = key.replace(/[A-Z]/g, '-$&').toLowerCase();
  return '--' + key + (val ? separator + val : '');
}

function match(arr, val) {
  return arr.some(function(x) {
    return x instanceof RegExp ? x.test(val) : x === val;
  });
}

function createAliasArg(key, val) {
  return '-' + key + (val ? ' ' + val : '');
}



var dargs = (() => {
  return function(input, opts) {
    var args = [];
    var extraArgs = [];

    opts = opts || {};

    var separator = opts.useEquals === false ? ' ' : '=';

    Object.keys(input).forEach(function(key) {
      var val = input[key];
      var argFn = createArg;

      if (Array.isArray(opts.excludes) && match(opts.excludes, key)) {
        return;
      }

      if (Array.isArray(opts.includes) && !match(opts.includes, key)) {
        return;
      }

      if (typeof opts.aliases === 'object' && opts.aliases[key]) {
        key = opts.aliases[key];
        argFn = createAliasArg;
      }

      if (key === '_') {
        if (!Array.isArray(val)) {
          throw new TypeError('Expected key \'_\' to be an array, but found ' + (typeof val));
        }

        extraArgs = val;
        return;
      }

      if (val === true) {
        args.push(argFn(key, ''));
      }

      if (val === false && !opts.ignoreFalse) {
        args.push(argFn('no-' + key));
      }

      if (typeof val === 'string') {
        args.push(argFn(key, val, separator));
      }

      if (typeof val === 'number' && !numberIsNan(val)) {
        args.push(argFn(key, String(val), separator));
      }

      if (Array.isArray(val)) {
        val.forEach(function(arrVal) {
          args.push(argFn(key, arrVal, separator));
        });
      }
    });

    extraArgs.forEach(function(extraArgVal) {
      args.push(String(extraArgVal));
    });

    return args;
  };
})();

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
