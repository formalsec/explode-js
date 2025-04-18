Testing toy example:

Vulnerable function is exported:
  $ explode-js instrument --mode symbolic --filename toy/vfunexported.js toy/vfunexported.json -o -
  ⚒ Generating 1 template(s):
  ├── 📄 -
  let exec = require('child_process').exec;
  
  moduke.exports = function f(x) {
    return exec(x);
  };
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: command-injection
  var x = esl_symbolic.string("x");
  module.exports(x);

Vulnerable function is returned by an exported function:
  $ explode-js instrument --mode symbolic toy/vfunretbyexport.json -o -
  ⚒ Generating 2 template(s):
  ├── 📄 -
  function f1(a) {
    return function f2(b) {
      if (b > 0) {
        eval(a);
      }
    };
  };
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: code-injection
  var a = esl_symbolic.string("a");
  var ret_f1 = f1(a);
  var b = esl_symbolic.number("b");
  ret_f1(b);
  ├── 📄 -
  function f1(a) {
    return function f2(b) {
      if (b > 0) {
        eval(a);
      }
    };
  };
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: code-injection
  var a = esl_symbolic.string("a");
  var ret_f1 = f1(a);
  var b = esl_symbolic.number("b");
  ret_f1(b);

Vulnerable function is a property of an exported object:
  $ explode-js instrument --mode symbolic --filename toy/vfunpropofexportedobj.js toy/vfunpropofexportedobj.json -o -
  ⚒ Generating 1 template(s):
  ├── 📄 -
  let Obj = (function () {
    function Obj(source) { this.source = source; }
  
    Obj.prototype.f = function (obj) {
      if (obj.cond > 0) {
        eval(this.source);
      }
    }
  
    return Obj;
  })();
  
  module.exports.Obj = Obj;
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: code-injection
  var source = esl_symbolic.string("source");
  var ret_module_exports_Obj = module.exports.Obj(source);
  var obj = { cond: esl_symbolic.number("cond") };
  ret_module_exports_Obj.f(obj);

Sequence of exported functions
  $ explode-js instrument --mode symbolic --filename toy/example-20.js toy/example-20.json -o -
  ⚒ Generating 1 template(s):
  ├── 📄 -
  var target = "";
  
  function f(x) {
    target = x;
  }
  
  function eval_target() {
    return eval(target);
  }
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: code-injection
  var x = esl_symbolic.string("x");
  f(x);
  eval_target();

Vulnerability is in the top-level
  $ explode-js instrument --mode symbolic --filename toy/toplevel.js toy/toplevel.json -o -
  ⚒ Generating 1 template(s):
  ├── 📄 -
  // testing taint from parameter to eval function call
  // paremeter passed as argument to process.argv
  
  const process = require('process');
  const x = process.argv[2];
  eval(x);
  
  var esl_symbolic = require("esl_symbolic");
  // Vuln: code-injection
  
