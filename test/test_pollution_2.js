
function merge(a, b) {
  for (var p in b) {
    try {
      if (b[p].constructor === Object) {
        a[p] = merge(a[p], b[p]);
      } else {
        a[p] = b[p];
      }
    } catch (e) {
      a[p] = b[p];
    }
  }
  return a;
}

let esl_symbolic = require("esl_symbolic");
esl_symbolic.sealProperties(Object.prototype);
let polluted = esl_symbolic.polluted_object(depth=3);
merge({}, polluted);
console.log(({}).toString);
