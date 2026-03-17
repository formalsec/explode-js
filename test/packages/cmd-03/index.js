const fs = require("fs-extra");
const uploadFile = require("./utils.js");

var FileTransfer = function FileTransfer(options) {
  this.host = options.host
  this.limit = 1 * 1024 * 1024 * 1024 // 1 GiB
  this.useTempFiles = options.useTempFiles || false
};

FileTransfer.prototype.remoteUploadData = function upload(data, userId, usrDir) {
  if (this.useTempFiles && data != "") {
    tmpfile = `/tmp/${Date.now()}`
    fs.writeFileSync(tmpfile, data)
    return uploadFile(tmpfile, this.limit, userId, usrDir, this.host)
  }

  return null;
};
module.exports = FileTransfer;
