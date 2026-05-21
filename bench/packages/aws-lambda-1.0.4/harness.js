// {"FunctionName": "& touch Song &",
// "PATH": "./"}
var esl = require("esl_symbolic");
var aws = esl.lazy_object();
aws.Lambda = function Lambda(obj) { };
require.cache[require.resolve("aws-sdk")] = { exports: aws };

var yaml = esl.lazy_object();
yaml.Type = function Type(tag, obj) { };
require.cache[require.resolve("js-yaml")] = { exports: yaml };

var root = require("aws-lambda");
root.deploy("aws-lambda-config");
