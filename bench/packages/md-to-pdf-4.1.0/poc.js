const esl = require("esl_symbolic");
const mdToPdf = require('md-to-pdf');

const maliciousMarkdown = esl.string("payload");
mdToPdf.mdToPdf({ content: maliciousMarkdown }, {});
