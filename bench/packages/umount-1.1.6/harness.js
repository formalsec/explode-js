const esl = require("esl_symbolic");
const root = require("umount");
let device = esl.string("device")
root.umount(device, function () { });
