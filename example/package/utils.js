const { exec } = require("child_process")

function uploadFile(filename, limit, userid, userdir, host) {
  if (fs.statSync(filename).size < limit) {
    var command = "rsync -av "
      + filename + " "
      + userid + "@" + host + ":"
      + userdir;
    return exec(command);
  }
  console.log("File too big");
  return null;
}

module.exports = uploadFile;
