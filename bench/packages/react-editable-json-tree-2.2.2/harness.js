const parse = require("react-editable-json-tree/dist/utils/parse").default;
const esl = require("esl_symbolic");
const payload = esl.string("payload");
esl.assume(payload.indexOf("function") == 0);
parse(payload);

