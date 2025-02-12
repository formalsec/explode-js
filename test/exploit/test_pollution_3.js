
function extend(target, obj) {
  Object.keys(obj).forEach(function (key) {
    src = target[key];
    val = obj[key];

    /* Prevents recursion */
    if (val === target) {
      return;
    } else if (typeof val !== 'object' || val === null) {
      target[key] = val;
      return;
    } else if (typeof src !== 'object' || src === null || Array.isArray(src)) {
      target[key] = extend({}, val);
      return;
    } else {
      target[key] = extend(src, val);
      return;
    }
  });
  return target
}

let esl_symbolic = require('esl_symbolic');
esl_symbolic.sealProperties(Object.prototype);
let p = esl_symbolic.polluted_object(depth=2);
extend({}, p);
console.log(({}).toString);
