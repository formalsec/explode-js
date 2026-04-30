const Qpdf = require("node-qpdf");
const esl = require("esl_symbolic");
const stream = Qpdf.encrypt(esl.string("payload"), { password: "dummy" });
