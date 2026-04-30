const metadata = require("im-metadata");
try {
  metadata("./foo.jpg;touch im-metadata", { exif: true }, function (error, metadata) {});
} catch (err) {}
