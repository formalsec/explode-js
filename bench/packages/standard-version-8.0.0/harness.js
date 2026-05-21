const esl = require("esl_symbolic");
const standardVersion = require('standard-version')

standardVersion({
  noVerify: true,
  infile: 'foo.txt',
  releaseCommitMessageFormat: esl.string("releaseCommitMessageFormat")
})
