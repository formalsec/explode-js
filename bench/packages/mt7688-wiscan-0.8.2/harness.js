var esl = require("esl_symbolic");
var wiscan = require('mt7688-wiscan');
wiscan.scan(esl.string("payload"), function(){});
