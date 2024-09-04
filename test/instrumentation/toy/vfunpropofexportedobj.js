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
