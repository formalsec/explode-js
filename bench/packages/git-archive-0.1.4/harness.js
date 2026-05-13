const esl = require("esl_symbolic");
require.cache["fs"] = {
  exports: { exists: function(path, cb) { cb(true); } }
}

const archive = require("git-archive");
archive({
  commit : esl.string("commit"),
  outputPath: esl.string("outputPath"),
  repoPath: esl.string("repoPath")
})
