const esl = require("esl_symbolic");
process.env.PDFINFO_COV = false;

const pdfinfo = require("pdfinfojs");
pdf = new pdfinfo(esl.string("payload"));
pdf.getInfo(function (err, info, params) { });
