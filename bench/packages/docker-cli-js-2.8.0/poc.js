var dockerCLI = require('docker-cli-js');
var DockerOptions = dockerCLI.Options;
var Docker = dockerCLI.Docker;

var docker = new Docker();
docker.command(`image ls; touch success`, function (err, data) {
  console.log('data = ', data);
});
