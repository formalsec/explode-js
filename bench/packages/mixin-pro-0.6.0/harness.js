const Class = require("mixin-pro").createClass;
const esl = require("esl_symbolic");

var name = esl.string("Foo.name");
esl.assume(name.length == 5);

function Foo() { }
Object.defineProperty(Foo, "name", {
  enumerable: false,
  configurable: false,
  writable: true,
  value: 'static'
});
Foo.name = name;

Class(Foo, { constructor: Foo });
