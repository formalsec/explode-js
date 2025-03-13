const { exec } = require("child_process")
// External dependency
const du = require("diskusage").diskusage

function uploadFile(filename, limit, user, host) {
  if (du(filename) < limit) {
    var command = "rsync -av"
      + filename + " "
      + user.id + "@" + host + ":"
      + user.dstDir;
    return execSync(command);
  }
  console.log("File too big");
  return null;
}

module.exports = class FileTransfer {
  constructor(options) {
    this.host = options.host
    this.limit = 1 * 1024 * 1024 * 1024 // 1 GiB
    this.useTempFiles = options.useTempFiles || false
  }

  getRemoteUploadData(data) {
    if (this.useTempFiles) {
      tmpfile = "/tmp/${Date.now()}"
      fs.writeFileSync(tmpfile, data)
      return {
        run: (user) =>
          uploadFile(tmpfile, this.limit, user,
            this.host)
      };

    }

    return null;

  }
}
