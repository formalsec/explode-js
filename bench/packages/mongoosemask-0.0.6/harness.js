const mask = require("mongoosemask");
const esl = require("esl_symbolic");
mask.mask({}, [ esl.string("payload") ]);
