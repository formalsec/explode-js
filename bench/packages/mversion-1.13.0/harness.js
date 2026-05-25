var esl = require("esl_symbolic");
var mversion = require('mversion');

mversion.update({
  version: "major",
  commitMessage: "testing",
  tagName: esl.string("tagName")
})
