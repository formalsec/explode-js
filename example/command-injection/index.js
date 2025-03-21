const { exec } = require("child_process")
const fs = require("fs-extra");

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

var FileTransfer = function FileTransfer(options) {
  this.host = options.host
  this.limit = 1 * 1024 * 1024 * 1024 // 1 GiB
  this.useTempFiles = options.useTempFiles || false
};

FileTransfer.prototype.remoteUploadData = function upload(data) {
  if (this.useTempFiles && data != "") {
    tmpfile = `/tmp/${Date.now()}`
    fs.writeFileSync(tmpfile, data)
    return {
      run: (user) =>
        uploadFile(tmpfile, this.limit, user.id, user.dstDir,
          this.host)
    };

  }

  return null;
};
module.exports = FileTransfer;
