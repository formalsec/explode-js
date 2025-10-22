const { assert } = require("./utils");

let obj = {};
obj.__proto__.foo = "bar";
assert(({}).foo == "bar");

let obj2 = { "__proto__" : { bar : "baz" } };
assert(({}).bar == undefined);
assert(obj2.bar == "baz");

let x = "__proto__";
let obj3 = { [x] : { baz : "qux" } };
assert(obj3.baz == undefined);
assert(obj3.__proto__.baz = "qux");
