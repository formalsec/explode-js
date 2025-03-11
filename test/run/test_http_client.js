var http = require('http');
var util = require('util');

var url = "./exploited";
var port = "8888";

http.get(util.format("http://localhost:%s/%s", port, url), function(res) {
  var data = "";
  res.on("data", (chunk) => {
    data += chunk;
  });

  res.on("end", () => {
    console.log(data);
  });
});
