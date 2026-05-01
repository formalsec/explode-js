const SamsungRemote = require("samsung-remote");
try {
  var remote = new SamsungRemote({ ip: "127.0.0.1; touch samsung-remote;" });
  remote.isAlive(function (err) {});
} catch (e) {}
