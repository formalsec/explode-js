const standardVersion = require('standard-version')

standardVersion({
  noVerify: true,
  infile: 'foo.txt',
  releaseCommitMessageFormat: "bla `touch exploit`"
})
