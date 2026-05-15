const esl = require("esl_symbolic");
const egf = require("@thi.ng/egf");
egf.BUILTINS.gpg("foo", esl.string("paylod"), { opts: { decrypt: true } });
