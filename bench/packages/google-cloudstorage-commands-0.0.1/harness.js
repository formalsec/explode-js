var root = require("google-cloudstorage-commands");
const esl_symbolic = require("esl_symbolic");
var payload = esl_symbolic.string("payload");
var path = esl_symbolic.string("path");
root.upload(path, payload, true);
