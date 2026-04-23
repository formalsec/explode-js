const Class = require("mixin-pro").createClass;
const esl = require("esl_symbolic");

function Foo() { }
Object.defineProperty(Foo, "name", {
  enumerable: false,
  configurable: false,
  writable: true,
  value: 'static'
});
Foo.name = esl.string("Foo.name");

Class(Foo, { constructor: Foo });
