Test toy examples:
  $ instrumentation2 symbolic toy/vfunexported.json toy/vfunexported.js -o -
  Genrating -
  let exec = require('child_process').exec;
  
  moduke.exports = function f(x) {
    return exec(x);
  };
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: command-injection
  var x = esl_symbolic.string("x");
  module.exports(x);
  $ instrumentation2 symbolic toy/vfunretbyexport.json -o -
  Genrating -
  Genrating -
  function f1(a) {
    return function f2(b) {
      if (b > 0) {
        eval(a);
      }
    };
  };
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: code-injection
  var a = esl_symbolic.string("a");
  var ret_f1 = f1(a);
  var b = esl_symbolic.number("b");
  ret_f1(b);
  function f1(a) {
    return function f2(b) {
      if (b > 0) {
        eval(a);
      }
    };
  };
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: code-injection
  var a = esl_symbolic.string("a");
  var ret_f1 = f1(a);
  var b = esl_symbolic.number("b");
  ret_f1(b);
  $ instrumentation2 symbolic toy/vfunpropofexportedobj.json toy/vfunpropofexportedobj.js -o -
  Genrating -
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
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: code-injection
  var source = esl_symbolic.string("source");
  var ret_module_exports_Obj = module.exports.Obj(source);
  var obj = { cond: esl_symbolic.number("cond") };
  ret_module_exports_Obj.f(obj);
  $ instrumentation2 symbolic toy/example-20.json toy/example-20.js -o -
  Genrating -
  var target = "";
  
  function f(x) {
    target = x;
  }
  
  function eval_target() {
    return eval(target);
  }
  
  var esl_symbolic = require("esl_symbolic");
  esl_symbolic.sealProperties(Object.prototype);
  // Vuln: code-injection
  var x = esl_symbolic.string("x");
  f(x);
  eval_target();
