const validator = require("is-my-json-valid");
const esl = require("esl_symbolic");
var prop = esl.string("prop");
var schema = {
  type: "object",
  properties: {
    [prop]: {
    required: true,
    type: "string",
   },
  },
};
let validate = validator(schema);
validate({});
