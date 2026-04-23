var A = require("mosc");
const esl = require("esl_symbolic");

let a = new A({});
let key = "";
let properties = esl.string("properties");
a.parse_properties(key, properties, {}, {});
