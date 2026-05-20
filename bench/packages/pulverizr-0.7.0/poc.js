var root = require("pulverizr");

var inputs = []
var job = root.createJob(inputs, {});
job.compress('" touch success #');
job.run();
