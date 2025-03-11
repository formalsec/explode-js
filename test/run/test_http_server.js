var http = require("http");
var fs = require("fs");

var server = http.createServer(function(request, response) {
  var path = "./" + request.url;
  fs.readFile(path, function(_error, data) {
    response.end(data);
  })
});

server.listen("8888");
