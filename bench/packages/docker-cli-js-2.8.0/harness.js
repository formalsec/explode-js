var esl = require("esl_symbolic");
var dockerCLI = require('docker-cli-js');
var Docker = dockerCLI.Docker;

var docker = new Docker();
docker.command(esl.string("payload"), function (err, data) {
  console.log('data = ', data);
});
