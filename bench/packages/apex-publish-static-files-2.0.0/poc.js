
const publisher = require("apex-publish-static-files");
publisher.publish({
  connectString: ";touch apex-publish-static-files; #",
  directory: "./",
  appID: 111,
});
