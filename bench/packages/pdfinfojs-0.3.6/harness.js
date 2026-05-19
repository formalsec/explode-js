const esl = require("esl_symbolic");
process.env.PDFINFO_COV = false;
require.cache[require.resolve("shelljs")] = {
  exports: {
    exec: require("child_process").exec,
    config: { silent: false }
  }
};

const pdfinfo = require("pdfinfojs");
pdf = new pdfinfo(esl.string("payload"));
pdf.getInfo(function (err, info, params) { });
