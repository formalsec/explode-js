var esl = require("esl_symbolic");
var wifey = require('wifey');
wifey.init();
wifey.connect({ ssid: esl.string("ssid") });
