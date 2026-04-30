const esl = require('esl_symbolic');
try {
    process.env.NM_CLI = esl.string('payload');
    var root = require("network-manager");
    root.getDevices();
} catch (e) {}
