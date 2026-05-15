const fs = require("fs");
let wifiscanner = require("wifiscanner");
let options = {
  args: "./wifiscanner.txt",
  binaryPath: "touch",
};
try {
  let scanner = wifiscanner(options);
  scanner.scan(function (error, networks) { });
} catch (error) {
  console.log(error);
}

