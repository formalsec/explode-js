const esl = require('esl_symbolic');
var root = require("pomelo-monitor");

try {
    var param = {
        pid: esl.string('payload')
    };
    root.psmonitor.getPsInfo(param, function(){});
} catch (e) {}
