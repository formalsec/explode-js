let esl = require("esl_symbolic");
// Stub problematic behaviour
process.env.DEBUG = false;

let root = require("node-notifier");
var notifier = new root.NotifySend({ suppressOsdCheck: true });
var payload = esl.string("payload");
esl.assume(payload != "");
var options = { title: "HACKED", message: [payload] };
notifier.notify(options)
